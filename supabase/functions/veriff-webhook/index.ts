// Veriff decision webhook.
//
// Runs with verify_jwt = false (Veriff cannot present a Supabase JWT), so the
// x-hmac-signature header is the ONLY thing standing between this endpoint and
// anyone forging an 'approved' decision. Never remove it.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DECISION_STATUSES = [
  'approved',
  'declined',
  'resubmission_requested',
  'review',
  'expired',
  'abandoned',
]

// Lifecycle events (no decision attached). 'submitted' is the one that matters:
// without it a session in manual review is indistinguishable from one the user
// never opened, and the app offers "Start verification" over an in-flight
// attempt. Veriff also sends 'started' and, on some plans, 'approved'/'declined'
// as event actions -- those are ignored here and taken from the decision
// payload instead, which carries the reason and risk data.
const EVENT_ACTIONS: Record<string, string> = {
  started: 'started',
  submitted: 'submitted',
}

async function isSignatureValid(rawBody: string, signature: string | null, secret: string) {
  if (!signature) return false

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const mac = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(rawBody))
  const expected = Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')

  // Constant-time compare.
  const given = signature.trim().toLowerCase()
  if (given.length !== expected.length) return false
  let diff = 0
  for (let i = 0; i < expected.length; i++) diff |= given.charCodeAt(i) ^ expected.charCodeAt(i)
  return diff === 0
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 })
  }

  try {
    const secret = Deno.env.get('VERIFF_SHARED_SECRET')
    if (!secret) {
      console.error('🚨 VERIFF_SHARED_SECRET not set — refusing to trust webhook')
      return new Response('Server misconfigured', { status: 500 })
    }

    // Signature is over the raw bytes, so read text before parsing.
    const rawBody = await req.text()
    const signature = req.headers.get('x-hmac-signature') ?? req.headers.get('x-auth-client-signature')

    if (!(await isSignatureValid(rawBody, signature, secret))) {
      console.error('🚨 Rejected webhook with bad HMAC signature')
      return new Response('Invalid signature', { status: 401 })
    }

    const payload = JSON.parse(rawBody)

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Decisions carry a `verification` object; lifecycle events carry `action`
    // and a top-level session `id`.
    const verification = payload.verification
    if (!verification) {
      const lifecycle = EVENT_ACTIONS[payload.action]
      if (!lifecycle || !payload.id) {
        console.log(`ℹ️ Ignoring event (action=${payload.action ?? 'unknown'})`)
        return new Response(JSON.stringify({ received: true }), { status: 200 })
      }

      const { data, error } = await supabaseAdmin.rpc('update_veriff_session', {
        p_session_id: payload.id,
        p_status: lifecycle,
        p_payload: payload,
        p_attempt_id: payload.attemptId ?? null,
      })

      if (error) {
        // 500 so Veriff retries. A dropped 'submitted' leaves the app showing
        // "Start verification" over an attempt that is already in review.
        console.error('❌ Database RPC Error (event):', error)
        return new Response(JSON.stringify({ error: error.message }), { status: 500 })
      }

      console.log(`✅ Recorded '${lifecycle}' for session ${payload.id}:`, JSON.stringify(data))
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    const status = verification.status
    if (!DECISION_STATUSES.includes(status)) {
      console.log(`⚠️ Unhandled decision status '${status}' — acknowledged, not stored`)
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    // riskScore is a float 0.0-1.0 on the decision; older payloads nest it.
    const riskScore = typeof verification.riskScore === 'number'
      ? verification.riskScore
      : verification.riskScore?.score ?? null

    const { data, error } = await supabaseAdmin.rpc('update_veriff_session', {
      p_session_id: verification.id,
      p_status: status,
      p_risk_score: riskScore,
      p_fail_reason: verification.reason ?? null,
      p_code: verification.code ?? verification.reasonCode ?? null,
      p_risk_labels: verification.riskLabels ?? [],
      p_payload: payload,
      p_attempt_id: verification.attemptId ?? null,
    })

    if (error) {
      // 500 so Veriff retries — a dropped decision leaves the user stuck.
      console.error('❌ Database RPC Error:', error)
      return new Response(JSON.stringify({ error: error.message }), { status: 500 })
    }

    console.log(`✅ Handled '${status}' for session ${verification.id}:`, JSON.stringify(data))

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('🚨 Fatal Error:', error.message)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
