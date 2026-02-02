import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. AUTH CHECK
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. CHECK FOR EXISTING ACTIVE SESSION 🛑
    // This calls the SQL function we just created/updated
    const { data: existingSession, error: rpcError } = await supabaseAdmin.rpc('get_active_veriff_session', {
      p_auth_id: user.id
    })

    if (rpcError) {
      console.error('RPC Error:', rpcError) // Log but don't crash, proceed to create new
    }

    // ✅ REUSE LOGIC: If we found a valid session, return it immediately!
    if (existingSession && existingSession.url) {
      console.log('🔄 Reusing existing session:', existingSession.id)
      return new Response(JSON.stringify(existingSession), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 3. CREATE NEW SESSION (Only if no active one exists) 🆕
    console.log('✨ Creating NEW Veriff Session...')
    
    const veriffApiKey = Deno.env.get('VERIFF_API_KEY')
    if (!veriffApiKey) throw new Error('Veriff API Key missing')

    const { firstName, lastName } = await req.json().catch(() => ({}))

    const veriffResponse = await fetch('https://stationapi.veriff.com/v1/sessions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-AUTH-CLIENT': veriffApiKey
      },
      body: JSON.stringify({
        verification: {
          callback: Deno.env.get('SUPABASE_URL') + '/functions/v1/veriff-webhook',
          person: { 
            firstName: firstName || 'User', 
            lastName: lastName || '' 
          },
          vendorData: user.id,
          timestamp: new Date().toISOString()
        }
      })
    })

    if (!veriffResponse.ok) {
      const errText = await veriffResponse.text()
      console.error('Veriff API Error:', errText)
      throw new Error('Failed to create session with Veriff')
    }

    const veriffData = await veriffResponse.json()
    const sessionUrl = veriffData.verification.url
    const sessionId = veriffData.verification.id

    // 4. INSERT NEW ROW TO DATABASE
    const { error: dbError } = await supabaseAdmin.rpc('create_veriff_session', {
      p_auth_id: user.id,
      p_session_id: sessionId,
      p_url: sessionUrl
    })

    if (dbError) {
      console.error('DB Insert Error:', dbError)
      throw new Error('Database error saving session')
    }

    return new Response(JSON.stringify({ url: sessionUrl, id: sessionId }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('🚨 Error:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})