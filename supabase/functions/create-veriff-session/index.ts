// File: supabase/functions/create-veriff-session/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    // 1. CORS & METHOD CHECK
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
    if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 })

    // 2. AUTH CHECK: Get the user from the Request Header
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized: User not logged in')

    // 3. PREPARE VERIFF REQUEST
    const veriffApiKey = Deno.env.get('VERIFF_API_KEY')
    const veriffSharedSecret = Deno.env.get('VERIFF_SHARED_SECRET') // OR 'VERIFF_SECRET_KEY'
    
    if (!veriffApiKey || !veriffSharedSecret) {
      throw new Error('Server Config Error: Missing Veriff Keys')
    }

    // Parse Body (Optional: You can pass first/last name if you have it)
    const { firstName, lastName } = await req.json().catch(() => ({}))

    // 4. CALL VERIFF API
    // We send the 'vendorData' as the User ID so the webhook can link it back!
    const veriffBody = {
      verification: {
        callback: Deno.env.get('SUPABASE_URL') + '/functions/v1/veriff-webhook',
        person: {
          firstName: firstName,
          lastName: lastName
        },
        vendorData: user.id // <--- CRITICAL: Links Veriff Session to Your DB Profile
      }
    }

    // Calculate Signature (Security Requirement for Veriff API)
    // Veriff requires X-AUTH-CLIENT header (API Key)
    // (For session creation, signature isn't strictly required if using API Key, 
    // but sending the JSON body correctly is key)
    
    const veriffResponse = await fetch('https://stationapi.veriff.com/v1/sessions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-AUTH-CLIENT': veriffApiKey
      },
      body: JSON.stringify(veriffBody)
    })

    if (!veriffResponse.ok) {
      const errorText = await veriffResponse.text()
      throw new Error(`Veriff API Error: ${errorText}`)
    }

    const veriffData = await veriffResponse.json()
    const sessionUrl = veriffData.verification.url
    const sessionId = veriffData.verification.id

    // 5. SAVE TO DATABASE (Create the Pending Row)
    // We use Service Role to bypass RLS for the Insert if needed, 
    // but calling the RPC is safer.
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { error: dbError } = await supabaseAdmin.rpc('create_veriff_session', {
      p_auth_id: user.id,
      p_session_id: sessionId,
      p_url: sessionUrl
    })

    if (dbError) throw new Error(`Database Error: ${dbError.message}`)

    // 6. RETURN URL TO FLUTTER
    return new Response(JSON.stringify({ url: sessionUrl, id: sessionId }), {
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

// CORS Headers helper
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}