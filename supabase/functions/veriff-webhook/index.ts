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

    // Decisions carry a `verification` object; events carry `action`
    // (started/submitted) and no decision. Events tell us nothing the client
    // stream doesn't already know, so they are acknowledged and dropped.
    const verification = payload.verification
    if (!verification) {
      console.log(`ℹ️ Ignoring non-decision payload (action=${payload.action ?? 'unknown'})`)
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    const status = verification.status
    if (!DECISION_STATUSES.includes(status)) {
      console.log(`⚠️ Unhandled decision status '${status}' — acknowledged, not stored`)
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

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
