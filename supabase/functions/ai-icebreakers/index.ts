import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Only fields that are safe to hand to a third-party LLM. No location, no
// birth_date, no religion/politics, no trust/verification, no media.
const PROFILE_FIELDS =
  'id,display_name,city,work_title,education_school,languages,causes_communities,qualities,star_sign,relationship_type,pronouns,current_mode'

type Card = { question: string; observation: string; fun_fact: string }

async function loadProfile(admin: any, profileId: string) {
  const { data: profile, error } = await admin
    .from('profiles')
    .select(PROFILE_FIELDS)
    .eq('id', profileId)
    .single()
  if (error) throw new Error(`profile ${profileId}: ${error.message}`)

  // The mode the user is actually presenting right now; their other mode's
  // bio/prompts describe a different persona and would produce off-key lines.
  const { data: mode } = await admin
    .from('profile_modes')
    .select(
      'bio,mode,' +
        'profile_mode_prompts(user_response,prompt_templates(prompt_text)),' +
        'profile_mode_interestchips(interest_chips(label)),' +
        'profile_mode_lifestylechips(lifestyle_chips(label))',
    )
    .eq('profile_id', profileId)
    .eq('mode', profile.current_mode)
    .eq('is_active', true)
    .maybeSingle()

  return {
    name: profile.display_name,
    city: profile.city,
    work: profile.work_title,
    school: profile.education_school,
    languages: profile.languages,
    causes: profile.causes_communities,
    qualities: profile.qualities,
    star_sign: profile.star_sign,
    looking_for: profile.relationship_type,
    pronouns: profile.pronouns,
    bio: mode?.bio,
    prompts: (mode?.profile_mode_prompts ?? []).map((p: any) => ({
      q: p.prompt_templates?.prompt_text,
      a: p.user_response,
    })),
    interests: (mode?.profile_mode_interestchips ?? []).map((c: any) => c.interest_chips?.label),
    lifestyle: (mode?.profile_mode_lifestylechips ?? []).map((c: any) => c.lifestyle_chips?.label),
  }
}

async function generate(sender: unknown, recipient: unknown): Promise<{ both_profiles: Card; recipient_only: Card }> {
  const prompt = `You write opening messages for a dating app. The sender is about to message the recipient for the first time.

SENDER: ${JSON.stringify(sender)}
RECIPIENT: ${JSON.stringify(recipient)}

Write two sets of three openers, each addressed TO the recipient, in the sender's voice.
- "both_profiles": lean on something the two of them share or contrast.
- "recipient_only": use ONLY the recipient's profile. Ignore the sender entirely.

Each set has:
- "question": an open question about something specific in their profile.
- "observation": a warm, specific remark about their profile. Not a compliment on looks.
- "fun_fact": a light, playful line that invites a reply.

Rules: under 25 words each. Casual, human, no emoji, no pet names, no "Hey [name]!" openers,
nothing about their body or appearance, never invent facts not in the profiles.

Return only JSON: {"both_profiles":{"question":"","observation":"","fun_fact":""},"recipient_only":{"question":"","observation":"","fun_fact":""}}`

  const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${Deno.env.get('GROQ_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      temperature: 0.9,
      max_tokens: 600,
      response_format: { type: 'json_object' },
      messages: [{ role: 'user', content: prompt }],
    }),
  })

  if (!res.ok) throw new Error(`groq ${res.status}: ${await res.text()}`)
  const body = await res.json()
  const parsed = JSON.parse(body.choices[0].message.content)

  // JSON mode guarantees valid JSON, not our shape.
  for (const set of ['both_profiles', 'recipient_only']) {
    for (const key of ['question', 'observation', 'fun_fact']) {
      if (typeof parsed?.[set]?.[key] !== 'string') throw new Error(`model returned bad shape at ${set}.${key}`)
    }
  }
  return parsed
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const json = (payload: unknown, status = 200) =>
    new Response(JSON.stringify(payload), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status,
    })

  try {
    const { match_id, refresh } = await req.json()
    if (!match_id) return json({ success: false, error: 'Missing match_id' }, 400)

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

    // Derive both sides from the match rather than trusting client-supplied ids,
    // which would otherwise let anyone dump any two profiles into the prompt.
    const { data: me } = await admin.from('profiles').select('id').eq('user_id', user.id).single()
    const { data: match } = await admin
      .from('matches')
      .select('id,user_a_id,user_b_id,status,icebreakers')
      .eq('id', match_id)
      .single()

    if (!match || (match.user_a_id !== me?.id && match.user_b_id !== me?.id)) {
      return json({ success: false, error: 'Not your match' }, 403)
    }
    if (match.status !== 'active') return json({ success: false, error: 'Match is not active' }, 403)

    const senderId = me.id
    const recipientId = match.user_a_id === senderId ? match.user_b_id : match.user_a_id

    // Cached per sender: the two directions produce different copy.
    const cache = match.icebreakers ?? {}
    if (!refresh && cache[senderId]) return json({ success: true, icebreakers: cache[senderId], cached: true })

    const [sender, recipient] = await Promise.all([
      loadProfile(admin, senderId),
      loadProfile(admin, recipientId),
    ])
    const icebreakers = await generate(sender, recipient)

    await admin
      .from('matches')
      .update({ icebreakers: { ...cache, [senderId]: icebreakers } })
      .eq('id', match_id)

    return json({ success: true, icebreakers })
  } catch (e) {
    console.error('🚨 ai-icebreakers:', e.message)
    return json({ success: false, error: e.message }, 500)
  }
})
