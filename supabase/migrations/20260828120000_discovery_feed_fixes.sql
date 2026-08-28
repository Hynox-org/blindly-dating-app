-- ============================================================================
-- Discovery page fixes.
--
-- 1. hydrate_discovery_profiles never returned distance_km, so every card on
--    the Discover carousels rendered "0.0 km away" — and so did the Likes
--    screen, which opens the same card. It also had no migration of its own
--    and existed only in the live database; this file is now its source.
--
-- 2. get_discovery_categories returned its rows with no ORDER BY, so the
--    carousels arrived in an undefined order: "Nearby" was not reliably
--    nearest-first, "Recently Active" not reliably most-recent-first.
--
-- 3. get_discovery_categories honoured six of the ten saved filters. The
--    other four (relationship type, dating intention, languages, interests)
--    were written by the filter screen, read by the swipe deck, and silently
--    ignored here — the same saved filter produced two different feeds.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. hydrate_discovery_profiles: + distance_km
--    Return type changes, so it has to be dropped first.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.hydrate_discovery_profiles(jsonb);

CREATE FUNCTION public.hydrate_discovery_profiles(payload jsonb)
RETURNS TABLE(
  profile_id           uuid,
  display_name         text,
  age                  integer,
  distance_km          double precision,
  gender               text,
  work_title           text,
  bio                  text,
  mode_id              uuid,
  image_urls           text[],
  voice_intro_url      text,
  voice_intro_duration integer,
  swipe_action         text,
  is_verified          boolean,
  verification_level   text,
  trust_score          integer,
  hometown             text,
  work_company         text,
  education_level      text,
  educated_at          text,
  height_cm            integer,
  languages            text[],
  drinking             text,
  smoking              text,
  exercise             text,
  religion             text,
  star_sign            text,
  politics             text,
  kids                 text,
  relationship_type    text,
  qualities            text[],
  causes_communities   text[],
  looking_for          text[],
  interests            text[],
  lifestyle            text[],
  prompts              jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions'
AS $function$
DECLARE
  v_profile_ids uuid[];
  v_mode        text;
  my_profile_id uuid;
  v_geom        geography;
BEGIN
  -- 1. Extract params from JSON payload
  SELECT ARRAY(SELECT jsonb_array_elements_text(payload->'p_ids')::uuid) INTO v_profile_ids;
  v_mode := (payload->>'p_mode')::text;

  -- 2. Caller's profile id *and* the point we measure distance from. Passport
  --    location wins when set, matching every other discovery query.
  SELECT p.id, COALESCE(p.passport_location_geom, p.location_geom)
    INTO my_profile_id, v_geom
    FROM public.profiles p
   WHERE p.user_id = auth.uid();

  -- 3. Return aggregated JSON-ready rows
  RETURN QUERY
  SELECT
    p.id as profile_id,
    p.display_name::text,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date))::int as age,

    -- NULL when either side has no location; the client falls back to 0.
    (ST_Distance(v_geom, COALESCE(p.passport_location_geom, p.location_geom))
       / 1000.0)::double precision as distance_km,

    p.gender::text,
    p.work_title::text,
    pm.bio::text,
    pm.id as mode_id,

    COALESCE(
      ARRAY(
        SELECT pmm.media_url
        FROM public.profile_mode_media pmm
        WHERE pmm.profile_mode_id = pm.id
          AND pmm.media_type = 'photo'
          AND pmm.is_deleted = false
        ORDER BY pmm.is_primary DESC, pmm.created_at DESC
        LIMIT 3
      ),
      '{}'::text[]
    ) as image_urls,

    (
      SELECT vmm.media_url
      FROM public.profile_mode_media vmm
      JOIN public.profile_modes vpm ON vpm.id = vmm.profile_mode_id
      WHERE vpm.profile_id = p.id
        AND vmm.media_type = 'voice_intro'
        AND vmm.is_deleted = false
      ORDER BY vmm.created_at DESC
      LIMIT 1
    )::text as voice_intro_url,

    (
      SELECT vmm.duration_seconds
      FROM public.profile_mode_media vmm
      JOIN public.profile_modes vpm ON vpm.id = vmm.profile_mode_id
      WHERE vpm.profile_id = p.id
        AND vmm.media_type = 'voice_intro'
        AND vmm.is_deleted = false
      ORDER BY vmm.created_at DESC
      LIMIT 1
    )::int as voice_intro_duration,

    (
      SELECT
        CASE s.action_type::text
          WHEN 'like' THEN 'liked'
          WHEN 'pass' THEN 'passed'
          WHEN 'super_like' THEN 'super_liked'
          ELSE s.action_type::text
        END
      FROM public.swipes s
      WHERE s.actor_id = my_profile_id AND s.target_id = p.id
      ORDER BY s.created_at DESC
      LIMIT 1
    ) as swipe_action,

    p.is_verified,
    p.verification_level::text,
    p.trust_score::int,
    p.hometown_city::text as hometown,
    p.work_company::text,
    p.education_level::text,
    p.educated_at::text,
    p.height_cm::int,
    p.languages::text[],
    p.drinking::text,
    p.smoking::text,
    p.exercise::text,
    p.religion::text,
    p.star_sign::text,
    p.politics::text,
    p.kids_preference::text as kids,
    p.relationship_type::text,
    p.qualities::text[],
    p.causes_communities::text[],

    pm.looking_for::text[],

    COALESCE(
      ARRAY(
        SELECT ic.label
        FROM public.profile_mode_interestchips pmic
        JOIN public.interest_chips ic ON ic.id = pmic.chip_id
        WHERE pmic.profile_mode_id = pm.id
      ),
      '{}'::text[]
    ) as interests,

    COALESCE(
      ARRAY(
        SELECT lc.label
        FROM public.profile_mode_lifestylechips pmlc
        JOIN public.lifestyle_chips lc ON lc.id = pmlc.chip_id
        WHERE pmlc.profile_mode_id = pm.id
      ),
      '{}'::text[]
    ) as lifestyle,

    COALESCE(
      (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', pmp.id,
            'prompt_template_id', pmp.prompt_template_id,
            'prompt_text', pt.prompt_text,
            'user_response', pmp.user_response
          )
        )
        FROM public.profile_mode_prompts pmp
        JOIN public.prompt_templates pt ON pt.id = pmp.prompt_template_id
        WHERE pmp.profile_mode_id = pm.id
      ),
      '[]'::jsonb
    ) as prompts

  FROM public.profiles p
  LEFT JOIN LATERAL (
    SELECT m.id, m.bio, m.looking_for
    FROM public.profile_modes m
    WHERE m.profile_id = p.id
      AND m.is_active = true
      AND (m.mode = v_mode OR m.mode = 'default')
    ORDER BY CASE WHEN m.mode = v_mode THEN 1 ELSE 2 END ASC,
             m.created_at DESC
    LIMIT 1
  ) pm ON true

  WHERE p.id = ANY(v_profile_ids)
    AND p.is_deleted = false
    AND p.is_active = true;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.hydrate_discovery_profiles(jsonb) TO authenticated;


-- ---------------------------------------------------------------------------
-- 2. get_discovery_categories: honour every saved filter, and return the
--    carousels in the order they were ranked in.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_discovery_categories(
  p_mode         TEXT,
  p_per_category INT DEFAULT 10,
  p_pool_size    INT DEFAULT 50
)
RETURNS TABLE (category TEXT, profile_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me           UUID;
  v_mode         TEXT;
  v_geom         geography;
  v_filters      JSONB;
  v_gender_pref  TEXT   := 'Everyone';
  v_min_age      INT    := 18;
  v_max_age      INT    := 60;
  v_distance_km  FLOAT  := 50;
  v_religion     TEXT;
  v_orientation  TEXT;
  v_relationship TEXT;
  v_intention    TEXT;
  v_interests    TEXT[] := '{}';
  v_languages    TEXT[] := '{}';
  -- How long a pass stays visible with an undo button on it. Long enough to
  -- take back a misfire, short enough that the feed is not full of people the
  -- user has already answered.
  v_undo_window  INTERVAL := INTERVAL '10 minutes';
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

  v_mode := LOWER(TRIM(p_mode));
  IF v_mode NOT IN ('date', 'bff') THEN RAISE EXCEPTION 'Invalid mode: %', p_mode; END IF;

  SELECT p.id, COALESCE(p.passport_location_geom, p.location_geom)
    INTO v_me, v_geom
    FROM profiles p
   WHERE p.user_id = auth.uid() AND p.is_active AND NOT p.is_deleted;

  IF v_me IS NULL   THEN RAISE EXCEPTION 'Profile not found'; END IF;
  IF v_geom IS NULL THEN RAISE EXCEPTION 'No location set';   END IF;

  SELECT pm.filters INTO v_filters
    FROM profile_modes pm WHERE pm.profile_id = v_me AND pm.mode = v_mode;
  v_filters := COALESCE(v_filters, '{}'::JSONB);

  v_gender_pref  := COALESCE(v_filters->>'genderPreference', 'Everyone');
  v_min_age      := COALESCE(ROUND((v_filters->>'minAge')::NUMERIC)::INT, 18);
  v_max_age      := COALESCE(ROUND((v_filters->>'maxAge')::NUMERIC)::INT, 60);
  v_distance_km  := COALESCE((v_filters->>'distanceLimit')::FLOAT, 50);
  v_religion     := NULLIF(TRIM(v_filters->>'religion'), '');
  v_orientation  := NULLIF(TRIM(v_filters->>'sexualOrientation'), '');
  -- Previously ignored here while the swipe deck honoured them.
  v_relationship := NULLIF(TRIM(v_filters->>'relationshipType'), '');
  v_intention    := NULLIF(TRIM(v_filters->>'datingIntention'), '');

  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedInterests', '[]'::JSONB)))
    INTO v_interests;
  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedLanguages', '[]'::JSONB)))
    INTO v_languages;

  -- Slider maxes at 200, where 200 means "anywhere".
  IF v_distance_km >= 200 THEN v_distance_km := 40075; END IF;

  RETURN QUERY
  WITH pool AS (
    SELECT
      p.id,
      p.trust_score,
      p.last_active,
      p.created_at,
      ST_Distance(v_geom, COALESCE(p.passport_location_geom, p.location_geom)) / 1000.0 AS dist_km,
      (SELECT count(*)
         FROM profile_mode_interestchips mine
         JOIN profile_mode_interestchips theirs ON theirs.chip_id = mine.chip_id
         JOIN profile_modes my_pm ON my_pm.id = mine.profile_mode_id
        WHERE my_pm.profile_id = v_me AND my_pm.mode = v_mode
          AND theirs.profile_mode_id = pm.id
      ) AS shared_interests
    FROM profiles p
    JOIN profile_modes pm
      ON pm.profile_id = p.id AND pm.mode = v_mode AND pm.is_active = TRUE
    WHERE p.id <> v_me
      AND p.is_active = TRUE
      AND p.is_deleted = FALSE
      AND COALESCE(p.passport_location_geom, p.location_geom) IS NOT NULL
      AND ST_DWithin(v_geom, COALESCE(p.passport_location_geom, p.location_geom), v_distance_km * 1000)

      -- Unlike the swipe deck, a profile I LIKED stays in the feed — it comes
      -- back with swipe_action='liked' so the UI can draw the heart. A pass
      -- stays too, but only for v_undo_window, which is what makes the card's
      -- undo button reachable after a refresh instead of only in-session.
      -- Blocks and everything else are removed outright.
      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE s.actor_id = v_me AND s.target_id = p.id
           AND s.action_type NOT IN ('like', 'super_like')
           AND (s.action_type <> 'pass'
                OR s.created_at < NOW() - v_undo_window))
      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE s.actor_id = p.id AND s.target_id = v_me
           AND s.action_type IN ('like', 'super_like'))
      AND NOT EXISTS (
        SELECT 1 FROM matches m
         WHERE (m.user_a_id = v_me AND m.user_b_id = p.id)
            OR (m.user_a_id = p.id AND m.user_b_id = v_me))
      AND NOT EXISTS (
        SELECT 1 FROM match_blocks b
         WHERE (b.user_a_id = v_me AND b.user_b_id = p.id)
            OR (b.user_a_id = p.id AND b.user_b_id = v_me))

      AND p.birth_date IS NOT NULL
      AND DATE_PART('year', AGE(NOW(), p.birth_date))::INT BETWEEN v_min_age AND v_max_age
      AND (v_gender_pref = 'Everyone'
        OR (v_gender_pref = 'Women' AND p.gender::TEXT IN ('F','NB'))
        OR (v_gender_pref = 'Men'   AND p.gender::TEXT IN ('M','NB')))
      AND (v_religion     IS NULL OR p.religion           ILIKE v_religion)
      AND (v_orientation  IS NULL OR p.sexual_orientation ILIKE v_orientation)

      -- Kept in step with get_discovery_prospects so one saved filter set
      -- means the same thing on both feeds.
      AND (v_relationship IS NULL OR p.relationship_type  ILIKE v_relationship)
      AND (v_intention    IS NULL OR p.dating_intention   ILIKE v_intention)
      AND (v_languages = '{}' OR COALESCE(p.languages, '{}') && v_languages)
      AND (
        v_interests = '{}'
        OR EXISTS (
          SELECT 1
            FROM profile_mode_interestchips pmic
            JOIN interest_chips ic ON ic.id = pmic.chip_id
           WHERE pmic.profile_mode_id = pm.id
             AND ic.label = ANY(v_interests)
        )
      )
  ),
  -- Today's batch. Seeded on current_date, so it is identical for every call
  -- today and rotates at midnight — the 24h feed, with no cron and no cache.
  today AS (
    SELECT * FROM pool
    ORDER BY md5(id::TEXT || v_me::TEXT || CURRENT_DATE::TEXT)
    LIMIT p_pool_size
  ),
  ranked AS (
    SELECT id, 'top_picks' AS cat, 1 AS priority,
           row_number() OVER (ORDER BY shared_interests DESC, trust_score DESC NULLS LAST, dist_km ASC) AS rn
      FROM today
    UNION ALL
    SELECT id, 'nearby', 2,
           row_number() OVER (ORDER BY dist_km ASC)
      FROM today
    UNION ALL
    SELECT id, 'shared_interests', 3,
           row_number() OVER (ORDER BY shared_interests DESC)
      FROM today WHERE shared_interests > 0
    UNION ALL
    SELECT id, 'recently_active', 4,
           row_number() OVER (ORDER BY last_active DESC NULLS LAST)
      FROM today WHERE last_active IS NOT NULL
    UNION ALL
    SELECT id, 'new_faces', 5,
           row_number() OVER (ORDER BY created_at DESC)
      FROM today
  ),
  -- Each profile goes to the one category where it ranks best, so nobody
  -- appears twice.
  -- ponytail: greedy single pass, so categories can come back uneven. Swap for
  -- a recursive assignment only if the UI needs exactly N in every row.
  assigned AS (
    SELECT DISTINCT ON (id) id, cat, rn
      FROM ranked
     ORDER BY id, rn ASC, priority ASC
  )
  SELECT a.cat, a.id
    FROM (SELECT cat, id, row_number() OVER (PARTITION BY cat ORDER BY rn) AS cap
            FROM assigned) a
   WHERE a.cap <= p_per_category
   -- Without this the client received the carousels in an undefined order,
   -- so "Nearby" was not actually nearest-first.
   ORDER BY a.cat, a.cap;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_discovery_categories(TEXT, INT, INT) TO authenticated;
