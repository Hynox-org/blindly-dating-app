// Pulls the decision for the caller's own Veriff session and feeds it through
// the same RPC the webhook uses.
//
// The webhook is the primary path, but it depends on a URL configured in the
// Veriff Customer Portal -- if that is wrong or missing, decisions never arrive
// and the user is stuck on 'created' forever. This lets the app ask directly
// the moment the SDK returns, so the portal setting stops being a single point
// of failure.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const DECISION_STATUSES = [
  'approved',
  'declined',
  'resubmission_requested',
  'review',
  'expired',
  'abandoned',
]

// Session states that are not verdicts. Only these two are worth recording:
// 'created' is already the row's default, and every other value is a decision
// handled above.
const LIFECYCLE_STATUSES = ['started', 'submitted']

async function hmac(payload: string, secret: string) {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const mac = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(payload))
  return Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

/// Lifecycle state of the session itself, as opposed to its decision. Returns
/// null when Veriff is unreachable or reports anything we do not track -- a
/// best-effort enrichment must never fail the caller's request.
async function fetchSessionState(
  sessionId: string,
  apiKey: string,
  signature: string,
): Promise<string | null> {
  try {
    const res = await fetch(`https://stationapi.veriff.com/v1/sessions/${sessionId}`, {
      headers: {
        'Content-Type': 'application/json',
        'X-AUTH-CLIENT': apiKey,
        'X-HMAC-SIGNATURE': signature,
      },
    })
    if (!res.ok) {
      console.error(`Veriff session API ${res.status}`)
      return null
    }
    const state = (await res.json())?.verification?.status
    return LIFECYCLE_STATUSES.includes(state) ? state : null
  } catch (e) {
    console.error('Veriff session API unreachable:', e)
    return null
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status,
    })

  try {
    const apiKey = Deno.env.get('VERIFF_API_KEY')
    const secret = Deno.env.get('VERIFF_SHARED_SECRET')
    if (!apiKey || !secret) throw new Error('Veriff credentials missing from Supabase secrets')

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } },
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // The session id is looked up from the caller's own profile rather than
    // taken from the request body, so a user can only ever pull their own
    // decision.
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('user_id', user.id)
      .maybeSingle()

    if (!profile) return json({ error: 'Profile not found' }, 404)

    const { data: session } = await supabaseAdmin
      .from('veriff_verifications')
      .select('veriff_session_id, status')
      .eq('profile_id', profile.id)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle()

    if (!session) return json({ status: 'none' })

    const sessionId = session.veriff_session_id
    const signature = await hmac(sessionId, secret)

    // ponytail: bounded poll -- Veriff usually decides within seconds of
    // submission, but not always instantly. Five tries over ~10s covers the
    // common case; anything slower is left to the webhook and the client's
    // realtime subscription.
    for (let attempt = 0; attempt < 5; attempt++) {
      const res = await fetch(`https://stationapi.veriff.com/v1/sessions/${sessionId}/decision`, {
        headers: {
          'Content-Type': 'application/json',
          'X-AUTH-CLIENT': apiKey,
          'X-HMAC-SIGNATURE': signature,
        },
      })

      if (!res.ok) {
        const body = await res.text()
        console.error(`Veriff decision API ${res.status}: ${body}`)
        return json({ error: `Veriff returned ${res.status}` }, 502)
      }

      const payload = await res.json()
      const verification = payload.verification
      const status = verification?.status

      if (verification && DECISION_STATUSES.includes(status)) {
        const riskScore = typeof verification.riskScore === 'number'
          ? verification.riskScore
          : verification.riskScore?.score ?? null

        const { data, error } = await supabaseAdmin.rpc('update_veriff_session', {
          p_session_id: sessionId,
          p_status: status,
          p_risk_score: riskScore,
          p_fail_reason: verification.reason ?? null,
          p_code: verification.code ?? verification.reasonCode ?? null,
          p_risk_labels: verification.riskLabels ?? [],
          p_payload: payload,
          p_attempt_id: verification.attemptId ?? null,
        })

        if (error) {
          console.error('Database RPC Error:', error)
          return json({ error: error.message }, 500)
        }

        console.log(`Pulled '${status}' for session ${sessionId}`)
        return json({ status, result: data })
      }

      if (attempt < 4) await new Promise((r) => setTimeout(r, 2000))
    }

    // No verdict yet. Ask what state the session itself is in, so a submitted
    // session in manual review stops looking like one the user never opened --
    // otherwise the app offers "Start verification" over an in-flight attempt
    // and reopening it only errors. This is the only path that learns about a
    // submission when the portal's webhook URL is unset, so it is not optional.
    const lifecycle = await fetchSessionState(sessionId, apiKey, signature)
    if (lifecycle) {
      const { error } = await supabaseAdmin.rpc('update_veriff_session', {
        p_session_id: sessionId,
        p_status: lifecycle,
        p_payload: { source: 'veriff-decision', sessionState: lifecycle },
      })
      if (error) console.error('Database RPC Error (lifecycle):', error)
    }

    console.log(`No decision yet for session ${sessionId} (state=${lifecycle ?? 'unknown'})`)
    return json({ status: lifecycle ?? 'pending' })
  } catch (error) {
    console.error('Error:', error.message)
    return json({ error: error.message }, 400)
  }
})
