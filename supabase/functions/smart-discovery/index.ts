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

        // ---------------------------------------------------------
        // --- 6. NATIVE ML SCORING & CATEGORIZATION ---
        // ---------------------------------------------------------

        const currentUser = mlPayload.current_user;
        const candidates = mlPayload.candidate_pool;

        // Helper: Extract Lat/Lon from POINT(lon lat)
        const extractCoords = (geomStr: string | null) => {
            if (geomStr && geomStr.startsWith('POINT(')) {
                const parts = geomStr.slice(6, -1).split(' ');
                return { lon: parseFloat(parts[0]), lat: parseFloat(parts[1]) };
            }
            return null;
        };

        // Helper: Haversine Distance (km)
        const haversine = (lat1: number, lon1: number, lat2: number, lon2: number) => {
            const R = 6371;
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLon = (lon2 - lon1) * Math.PI / 180;
            const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c;
        };

        // Helper: Jaccard Similarity for Arrays
        const jaccardSimilarity = (arr1: string[], arr2: string[]) => {
            if (!arr1 || !arr2 || arr1.length === 0 || arr2.length === 0) return 0;
            const set1 = new Set(arr1);
            const set2 = new Set(arr2);
            const intersection = new Set([...set1].filter(x => set2.has(x)));
            const union = new Set([...set1, ...set2]);
            return intersection.size / union.size;
        };

        // Helper: Recency Score (Decays over hours)
        const calculateRecencyScore = (lastActiveStr: string | null) => {
            if (!lastActiveStr) return 0;
            const lastActive = new Date(lastActiveStr).getTime();
            const now = new Date().getTime();
            const hoursDiff = (now - lastActive) / (1000 * 60 * 60);
            const score = Math.exp(-0.014 * hoursDiff); // Approx 48hr half-life
            return Math.max(0, Math.min(1, score));
        };

        const cuCoords = extractCoords(currentUser?.location_geom);
        const cuInterests = currentUser?.interests || [];
        const cuLifestyle = currentUser?.lifestyle || [];

        // Score all candidates
        const scoredCandidates = candidates.map((c: any) => {
            const cCoords = extractCoords(c.location_geom);
            let distanceKm = Infinity;
            let distScore = 0;

            if (cuCoords && cCoords) {
                distanceKm = haversine(cuCoords.lat, cuCoords.lon, cCoords.lat, cCoords.lon);
                distScore = Math.max(0, 1 - (distanceKm / 100)); // Max 1.0 at 0km, 0.0 at >100km
            }

            const intScore = jaccardSimilarity(cuInterests, c.interests || []);
            const lifeScore = jaccardSimilarity(cuLifestyle, c.lifestyle || []);
            const recScore = calculateRecencyScore(c.last_active_at);

            // Weights: 40% Interests, 25% Distance, 20% Lifestyle, 15% Recency
            const compositeScore = (0.4 * intScore) + (0.25 * distScore) + (0.2 * lifeScore) + (0.15 * recScore);

            return {
                id: c.profile_id,
                compositeScore,
                distanceKm,
                intScore,
                recScore
            };
        });

        // Smart Categorization Waterfall (Max 5 per category)
        const categories: Record<string, string[]> = {
            top_picks: [],
            nearby: [],
            shared_interests: [],
            recently_active: [],
            new_faces: []
        };
        const assignedIds = new Set<string>();
        const MAX_PER_CATEGORY = 5;

        // Helper to assign and deduplicate
        const assignCategory = (catKey: string, sortFn: (a: any, b: any) => number) => {
            const unassigned = scoredCandidates.filter((c: any) => !assignedIds.has(c.id));
            unassigned.sort(sortFn);
            const selected = unassigned.slice(0, MAX_PER_CATEGORY);
            selected.forEach((c: any) => {
                categories[catKey].push(c.id);
                assignedIds.add(c.id);
            });
        };

        assignCategory('top_picks', (a: any, b: any) => b.compositeScore - a.compositeScore);
        assignCategory('nearby', (a: any, b: any) => a.distanceKm - b.distanceKm);
        assignCategory('shared_interests', (a: any, b: any) => b.intScore - a.intScore);
        assignCategory('recently_active', (a: any, b: any) => b.recScore - a.recScore);

        // New Faces: Randomize remainder
        const unassigned = scoredCandidates.filter((c: any) => !assignedIds.has(c.id));
        const shuffled = unassigned.sort(() => 0.5 - Math.random());
        shuffled.slice(0, MAX_PER_CATEGORY).forEach((c: any) => {
            categories['new_faces'].push(c.id);
            assignedIds.add(c.id);
        });

        const awsResponse = { categories };

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
