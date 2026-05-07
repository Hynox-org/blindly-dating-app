import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const LAMBDA_URL = "https://475ykquxpa6vw6n7rsgjcrfe340emors.lambda-url.ap-northeast-1.on.aws/";

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
            { auth: { persistSession: false } }
        );

        // 1. Get all active profile modes to refresh
        const { data: profileModes, error: pmError } = await supabase
            .from('profile_modes')
            .select('id, profile_id, mode')
            .eq('is_active', true);

        if (pmError) throw pmError;

        console.log(`Processing ${profileModes.length} profile modes`);

        // 2. Batch process to avoid Lambda/Edge timeouts
        const BATCH_SIZE = 10;
        const results = [];

        for (let i = 0; i < profileModes.length; i += BATCH_SIZE) {
            const batch = profileModes.slice(i, i + BATCH_SIZE);
            const batchPayload = [];

            // Fetch candidate pool for each in batch using official RPC
            for (const pm of batch) {
                const { data: payload, error: rpcError } = await supabase.rpc(
                    'get_discovery_candidates',
                    { 
                        target_profile_id: pm.profile_id, 
                        target_mode_input: pm.mode 
                    }
                );

                if (!rpcError && payload) {
                    batchPayload.push(payload);
                } else {
                    console.error(`Error fetching candidates for ${pm.profile_id} (${pm.mode}):`, rpcError);
                }
            }

            if (batchPayload.length === 0) continue;

            // 3. Call AWS Lambda Scoring Engine
            const lambdaResponse = await fetch(LAMBDA_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ batch: batchPayload }),
            });

            if (!lambdaResponse.ok) {
                console.error(`Lambda Error: ${lambdaResponse.statusText}`);
                continue;
            }

            const { results: lambdaResults } = await lambdaResponse.json();

            // 4. Save results and update seen profiles
            for (const res of lambdaResults) {
                if (res.status === 'ok') {
                    // Cache the results
                    await supabase
                        .from('daily_discovery_matches')
                        .upsert({
                            profile_mode_id: res.profile_mode_id,
                            feed_data: { categories: res.categories },
                            created_at: new Date().toISOString()
                        }, { onConflict: 'profile_mode_id' });

                    // Extract all newly shown UUIDs
                    const newlySeen = Object.values(res.categories).flat() as string[];
                    
                    // Update seen profiles via utility RPC
                    await supabase.rpc('append_seen_profiles', {
                        p_profile_mode_id: res.profile_mode_id,
                        p_new_seen: newlySeen
                    });

                    // Update refresh timestamp
                    await supabase
                        .from('profile_modes')
                        .update({ discovery_last_refreshed_at: new Date().toISOString() })
                        .eq('id', res.profile_mode_id);
                }
            }
            
            results.push(...lambdaResults);
        }

        return new Response(JSON.stringify({ 
            message: "Batch process complete", 
            processed: results.length 
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });

    } catch (error: any) {
        console.error("Batch Process Error:", error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        });
    }
});
