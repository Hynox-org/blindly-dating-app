// File: supabase/functions/veriff-session/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const VERIFF_API_URL = "https://stationapi.veriff.com/v1/sessions";

console.log("Function 'veriff-session' up and running!")

serve(async (req) => {
  // 1. Handle CORS (Required so your Flutter app can talk to this)
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    // 2. Auth Check: Ensure the user is logged in
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) throw new Error('User not authenticated');

    // 3. Get Data from Flutter
    const { firstName, lastName } = await req.json();

    // 4. Prepare the Request for Veriff
    const payload = {
      verification: {
        callback: `${Deno.env.get('SUPABASE_URL')}/functions/v1/veriff-webhook`, // We'll build this listener next
        person: {
          firstName: firstName,
          lastName: lastName
        },
        vendorData: user.id, // IMPORTANT: We attach the User ID to track them later
        timestamp: new Date().toISOString()
      }
    };

    console.log("Sending request to Veriff...");

    // 5. Send to Veriff
    const apiKey = Deno.env.get('VERIFF_API_KEY');
    if (!apiKey) throw new Error("Missing VERIFF_API_KEY in secrets");

    const veriffResponse = await fetch(VERIFF_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-AUTH-CLIENT': apiKey, // Your Public API Key
      },
      body: JSON.stringify(payload),
    });

    const data = await veriffResponse.json();

    if (data.status !== 'created') {
      console.error("Veriff Error:", data);
      throw new Error(`Veriff rejected request: ${JSON.stringify(data)}`);
    }

    // 6. Return the Session URL to Flutter
    return new Response(
      JSON.stringify({ url: data.verification.url }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        } 
      }
    );

  } catch (error) {
    console.error("Function Error:", error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 400, 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        } 
      }
    )
  }
})