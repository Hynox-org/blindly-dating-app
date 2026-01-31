// File: supabase/functions/veriff-webhook/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 })
    }

    const payload = await req.json()
    console.log('📦 Webhook received:', JSON.stringify(payload))

    // 1. CHECK: Is this a "Decision" (has verification object) or "Event" (action)?
    // Decisions look like: { status: 'success', verification: { ... } }
    // Events look like: { id: '...', action: 'started', ... }
    
    let sessionId = ''
    let status = ''
    let verificationData = null

    if (payload.verification) {
      // CASE A: It is a DECISION (Approved/Declined)
      sessionId = payload.verification.id
      status = payload.verification.status
      verificationData = payload.verification
    } else if (payload.action) {
      // CASE B: It is an EVENT (Started/Submitted)
      sessionId = payload.id // In events, the session ID is at the root 'id'
      status = payload.action
      // Events don't have the full verification details, so we pass minimal data
      verificationData = { 
        riskScore: { score: 0 },
        reason: null,
        reasonCode: null,
        riskLabels: [],
        document: null
      }
    } else {
      // CASE C: Unknown payload (Ignore it safely)
      console.log('⚠️ Ignoring unknown payload type')
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    // 2. NORMALIZATION: Map Veriff status to our DB Enum
    // Veriff sends: 'success', 'resubmission_requested', 'declined', 'started', 'submitted'
    let dbStatus = status
    if (dbStatus === 'success') dbStatus = 'approved'

    // 3. CALL DATABASE
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const rpcParams = {
      p_session_id: sessionId,
      p_status: dbStatus,
      p_risk_score: verificationData?.riskScore?.score || 0,
      p_fail_reason: verificationData?.reason || null,
      p_fail_code: verificationData?.reasonCode || null,
      p_risk_labels: verificationData?.riskLabels || [],
      p_payload: payload, // Save the full JSON regardless of type
      
      // Document Details (Only present in Decisions)
      p_doc_type: verificationData?.document?.type || null,
      p_doc_number: verificationData?.document?.number || null,
      p_doc_country: verificationData?.document?.country || null
    }

    const { error } = await supabaseAdmin.rpc('update_veriff_session', rpcParams)

    if (error) {
      console.error('❌ Database RPC Error:', error)
      // We still return 200 to Veriff so they stop retrying failed events
      return new Response(JSON.stringify({ error: error.message }), { status: 200 })
    }

    console.log(`✅ Successfully handled '${status}' for session ${sessionId}`)

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('🚨 Fatal Error:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})