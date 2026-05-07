import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const authHeader = req.headers.get('Authorization')!;
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: authHeader } } }
        );

        let { mode } = await req.json();
        if (!mode) throw new Error("Missing required parameter: mode");
        mode = mode.toLowerCase();

        const token = authHeader.replace('Bearer ', '');
        const { data: { user } } = await supabase.auth.getUser(token);
        if (!user) throw new Error("Unauthorized");

        // 1. Get Profile Mode ID
        const { data: profile } = await supabase.from('profiles').select('id').eq('user_id', user.id).single();
        if (!profile) throw new Error("Profile not found");

        const { data: modeData } = await supabase
            .from('profile_modes')
            .select('id')
            .eq('profile_id', profile.id)
            .eq('mode', mode)
            .eq('is_active', true)
            .single();

        if (!modeData) throw new Error("Profile mode not found");

        // 2. Fetch from daily_discovery_matches (The Cache populated by Cron)
        const { data: cacheData, error: cacheError } = await supabase
            .from('daily_discovery_matches')
            .select('feed_data')
            .eq('profile_mode_id', modeData.id)
            .single();

        if (cacheError || !cacheData) {
            // Return empty structure if cache is not yet ready
            return new Response(JSON.stringify({ 
                data: { 
                    categories: { 
                        best_match: [], 
                        interests: [], 
                        location: [], 
                        age: [], 
                        lifestyle: [] 
                    } 
                } 
            }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            });
        }

        return new Response(JSON.stringify({ data: cacheData.feed_data }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });

    } catch (error: any) {
        console.error("Smart Discovery Cache Error:", error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        });
    }
});
