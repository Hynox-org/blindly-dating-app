// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// https://github.com/denoland/vscode_deno

/*
  DEPLOYMENT INSTRUCTIONS:
  1. Ensure you have the Supabase CLI installed.
  2. Run: supabase functions deploy update-location
  3. Ensure you have set up the necessary secrets if any (none required for this basic implementation).
*/

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Authenticate User
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser()

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // 2. Parse Input
    const { latitude, longitude } = await req.json()

    if (!latitude || !longitude || 
        latitude < -90 || latitude > 90 || 
        longitude < -180 || longitude > 180) {
      return new Response(JSON.stringify({ error: 'Invalid coordinates' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. Initialize Admin Client (for bypassing RLS updates on location_geom if needed, 
    //    or simply to perform the update if RLS "update" is revoked for authenticated users)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 4. (Optional) Fetch last known location for spoof check
    // In a real production app, we would cache this in Redis or check DB. 
    // Here we'll do a quick DB check.
    const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('location_geom, updated_at')
        .eq('user_id', user.id)
        .single();
    
    // Simplistic Spoof Check: If jumping > 5000km in < 1 minute (impossible)
    // For now, we just proceed.  
    
    // 5. Update Location
    // PostGIS format: ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
    // Supabase JS client helper or raw SQL?
    // Using raw SQL via rpc if available, or updating with the geojson format if supported.
    // Supabase supports GeoJSON update for Geography type.
    
    const point = `POINT(${longitude} ${latitude})`; // WKT format often works with casting
    
    const { error: updateError } = await supabaseAdmin
      .from('profiles')
      .update({ 
        location_geom: point, 
        city: 'Unknown City', // Ideally reverse geocode here using Google Maps API / Mapbox
        // active_at: new Date().toISOString() 
      })
      .eq('user_id', user.id)

    if (updateError) {
      throw updateError
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
