import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Profiles get edited. A report older than this is recomputed rather than served.
const CACHE_TTL_DAYS = 7

const BAND_LABELS: Record<string, string> = {
  strong: 'Strong match',
  good: 'Good match',
  some: 'Some common ground',
  low: 'Not much in common',
  unknown: 'Not enough to go on yet',
}

type Explanation = { headline: string; points: string[]; caveat: string }

// The model is handed the finished breakdown and asked only to phrase it.
// It never sees the raw profiles, and it is never asked for the number --
// otherwise the words and the band would drift apart between calls.
async function explain(breakdown: any): Promise<Explanation> {
  const prompt = `You explain a compatibility result to a user of a dating app. The result has ALREADY been calculated. Your only job is to put it into words.

RESULT: ${JSON.stringify(breakdown)}

The bands mean: strong > good > some > low. "unknown" means there wasn't enough profile data.
"reciprocity" is whether each person fits the other's stated filters -- mutual interest in each other's terms, not just similarity.

Write:
- "headline": one short line naming the overall band in plain words. Max 8 words.
- "points": 2 to 4 bullets, each under 20 words, each grounded in a SPECIFIC value from the result (a shared interest, a matching intention, the distance, a lifestyle difference). At least one bullet must name something they genuinely have in common if the result contains one. If a dimension banded low, say so plainly in one bullet rather than hiding it.
- "caveat": one honest line, under 20 words, that this is based on profile answers and says nothing about real chemistry.

Rules: never state or imply a percentage or number of any kind. Never invent a fact that is not in the result. Never mention filters, algorithms, weights, scores, or field names. Warm and plain, no emoji, no hype, second person ("you both").

Return only JSON: {"headline":"","points":["",""],"caveat":""}`

  const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${Deno.env.get('GROQ_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      temperature: 0.6,
      max_tokens: 500,
      response_format: { type: 'json_object' },
      messages: [{ role: 'user', content: prompt }],
    }),
  })

  if (!res.ok) throw new Error(`groq ${res.status}: ${await res.text()}`)
  const parsed = JSON.parse((await res.json()).choices[0].message.content)

  // JSON mode guarantees valid JSON, not our shape.
  if (typeof parsed?.headline !== 'string') throw new Error('model returned bad shape at headline')
  if (typeof parsed?.caveat !== 'string') throw new Error('model returned bad shape at caveat')
  if (!Array.isArray(parsed?.points) || parsed.points.some((p: unknown) => typeof p !== 'string')) {
    throw new Error('model returned bad shape at points')
  }
  return { headline: parsed.headline, points: parsed.points.slice(0, 4), caveat: parsed.caveat }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const json = (payload: unknown, status = 200) =>
    new Response(JSON.stringify(payload), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status,
    })

  try {
    const { target_profile_id, refresh } = await req.json()
    if (!target_profile_id) return json({ success: false, error: 'Missing target_profile_id' }, 400)

    // The user's own client, so get_compatibility runs as them: auth.uid()
    // drives which profile is "me" and enforces the block check. Passing a
    // viewer id in from the caller would let anyone diff any two profiles.
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } },
    )
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) return json({ success: false, error: 'Unauthorized' }, 401)

    const admin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { data: me } = await admin.from('profiles').select('id').eq('user_id', user.id).single()
    if (!me) return json({ success: false, error: 'Profile not found' }, 404)

    if (!refresh) {
      const { data: cached } = await admin
        .from('compatibility_reports')
        .select('band, score, breakdown, explanation, created_at')
        .eq('viewer_id', me.id)
        .eq('target_id', target_profile_id)
        .maybeSingle()

      const fresh =
        cached?.explanation &&
        Date.now() - new Date(cached.created_at).getTime() < CACHE_TTL_DAYS * 864e5

      if (fresh) {
        return json({
          success: true,
          cached: true,
          band: cached.band,
          band_label: BAND_LABELS[cached.band] ?? BAND_LABELS.unknown,
          breakdown: cached.breakdown,
          explanation: cached.explanation,
        })
      }
    }

    const { data: breakdown, error: rpcError } = await supabaseClient.rpc('get_compatibility', {
      p_target_profile_id: target_profile_id,
    })
    if (rpcError) return json({ success: false, error: rpcError.message }, 400)

    const explanation = await explain(breakdown)

    await admin.from('compatibility_reports').upsert(
      {
        viewer_id: me.id,
        target_id: target_profile_id,
        band: breakdown.band,
        score: breakdown.score ?? 0,
        breakdown,
        explanation,
        created_at: new Date().toISOString(),
      },
      { onConflict: 'viewer_id,target_id' },
    )

    return json({
      success: true,
      cached: false,
      band: breakdown.band,
      band_label: BAND_LABELS[breakdown.band] ?? BAND_LABELS.unknown,
      breakdown,
      explanation,
    })
  } catch (e) {
    console.error('🚨 compatibility-explanation:', e.message)
    return json({ success: false, error: e.message }, 500)
  }
})
