import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// CORS headers for browser/app preflight requests
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        // 1. Initialize Supabase Client securely
        const authHeader = req.headers.get('Authorization')!;
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: authHeader } } }
        );

        // 2. Parse exactly what we need from Flutter
        let { mode } = await req.json();

        if (!mode) {
            throw new Error("Missing required parameter: mode");
        }

        mode = mode.toLowerCase();

        // 3. Get the user's profile_mode_id and last_refreshed_at to see if we need a new batch
        const token = authHeader.replace('Bearer ', '');
        const { data: { user }, error: authError } = await supabase.auth.getUser(token);

        if (authError || !user) {
            throw new Error(`Unauthorized: ${authError?.message}`);
        }

        const { data: profile } = await supabase
            .from('profiles')
            .select('id')
            .eq('user_id', user.id)
            .single();

        if (!profile) {
            throw new Error("Profile not found");
        }

        const { data: modeData, error: modeError } = await supabase
            .from('profile_modes')
            .select('id, discovery_last_refreshed_at, discovery_seen_profiles')
            .eq('profile_id', profile.id)
            .eq('mode', mode)
            .eq('is_active', true)
            .single();

        if (modeError || !modeData) {
            throw new Error(`Could not find active profile mode: ${modeError?.message}`);
        }

        const profileModeId = modeData.id;
        const lastRefreshedRaw = modeData.discovery_last_refreshed_at;

        let shouldFetchNewBatch = true;
        if (lastRefreshedRaw) {
            const lastRefreshed = new Date(lastRefreshedRaw);
            const now = new Date();
            const diffInHours = (now.getTime() - lastRefreshed.getTime()) / (1000 * 60 * 60);
            if (diffInHours < 24) {
                shouldFetchNewBatch = false;
            }
        }

        // 4. If < 24 hours, Just return the Cache!
        if (!shouldFetchNewBatch) {
            const { data: cacheData, error: cacheError } = await supabase
                .from('daily_discovery_matches')
                .select('feed_data')
                .eq('profile_mode_id', profileModeId)
                .single();

            if (!cacheError && cacheData) {
                return new Response(JSON.stringify({ data: cacheData.feed_data }), {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                    status: 200,
                });
            }
            // If cache is missing for some reason, we fall through and fetch a new batch anyway
        }

        // ---------------------------------------------------------
        // --- 5. TIME FOR A NEW BATCH: Call SQL and ping AWS ---
        // ---------------------------------------------------------

        const { data: mlPayload, error: dbError } = await supabase.rpc(
            'get_discovery_ml_payload',
            { search_mode: mode }
        );

        if (dbError) {
            console.error("Database Error:", dbError);
            throw dbError;
        }

        // Safety edge case - empty candidates
        if (!mlPayload || !mlPayload.candidate_pool || mlPayload.candidate_pool.length === 0) {
            return new Response(JSON.stringify({
                data: {
                    categories: {
                        top_picks: [],
                        nearby: [],
                        shared_interests: [],
                        recently_active: [],
                        new_faces: []
                    }
                }
            }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 });
        }

        // 6. Send Payload to AWS (Mock URL for now since AWS is not yet configured)
        const AWS_API_URL = Deno.env.get('AWS_ML_ENDPOINT_URL') || 'https://mock.your-aws.com/api/discovery';

        let awsResponse;
        try {
            if (AWS_API_URL.includes('mock')) {
                const candidates = mlPayload.candidate_pool;
                awsResponse = {
                    categories: {
                        top_picks: candidates.slice(0, Math.min(5, candidates.length)).map((c: any) => c.profile_id),
                        nearby: candidates.slice(5, Math.min(10, candidates.length)).map((c: any) => c.profile_id),
                        shared_interests: candidates.slice(10, Math.min(15, candidates.length)).map((c: any) => c.profile_id),
                        recently_active: candidates.slice(15, Math.min(20, candidates.length)).map((c: any) => c.profile_id),
                        new_faces: candidates.slice(20, Math.min(25, candidates.length)).map((c: any) => c.profile_id)
                    }
                };
            } else {
                const response = await fetch(AWS_API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(mlPayload)
                });

                if (!response.ok) {
                    throw new Error(`AWS ML Error: ${response.status} ${response.statusText}`);
                }
                awsResponse = await response.json();
            }
        } catch (awsError) {
            console.error("Failed contacting AWS", awsError);
            throw new Error("Machine Learning service temporarily unavailable.");
        }

        // ---------------------------------------------------------
        // --- 7. SAVE TO CACHE & APPEND SEEN PROFILES ---
        // ---------------------------------------------------------

        // Upsert the new feed into the cache
        await supabase
            .from('daily_discovery_matches')
            .upsert({
                profile_mode_id: profileModeId,
                feed_data: awsResponse
            }, { onConflict: 'profile_mode_id' });

        // Extract all newly matched UUIDs
        const newlySeenUuids = new Set<string>();
        Object.values(awsResponse.categories as Record<string, string[]>).forEach(arr => {
            arr.forEach(id => newlySeenUuids.add(id));
        });

        // Append to the list of seen profiles and update the timestamp
        const existingSeen = modeData.discovery_seen_profiles || [];
        const combinedSeen = Array.from(new Set([...existingSeen, ...Array.from(newlySeenUuids)]));

        await supabase
            .from('profile_modes')
            .update({
                discovery_seen_profiles: combinedSeen,
                discovery_last_refreshed_at: new Date().toISOString()
            })
            .eq('id', profileModeId);


        // 8. Structure exactly how Flutter requires it natively.
        return new Response(JSON.stringify({ data: awsResponse }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });

    } catch (error: any) {
        console.error("Smart Discovery Error:", error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400, // Bad Request helps Flutter catch it properly
        });
    }
});
