-- ============================================================================
-- Swipe deck, with spotlight.
--
-- Same function, same hydrated shape, plus one column (is_spotlight) and one
-- rule: profiles holding a live spotlight in the viewer's district come first.
--
-- What a spotlight buys, precisely:
--   * it IGNORES the viewer's saved filters — age, distance, religion,
--     languages, interests, dating intention, relationship type. That is the
--     product: you pay to reach people who did not ask for you.
--   * it does NOT ignore the viewer's gender preference. Someone who set
--     "show me women" still only sees women. Paying does not buy your way past
--     that, and treating it as a filter would make spotlight a report magnet.
--   * it does NOT ignore safety or state: already swiped either way, already
--     matched, or blocked either way still removes the card. A spotlight
--     re-surfaces you to people who have not answered yet, never to people who
--     already said no.
--
-- Ordering among spotlights is md5(their id || my id) — stable for a given
-- pair, different for every viewer, so each buyer lands at the top of the deck
-- for roughly their share of the district rather than the first buyer taking
-- the top slot off everyone.
--
-- Capped at v_spot_cap per fetch. Past the cap, a spotlight profile is simply
-- an ordinary candidate for that fetch and has to pass the filters like anyone
-- else — the deck stays swipeable when spotlight sells well.
--
-- Return type changes, so the function has to be dropped first.
-- ============================================================================

DROP FUNCTION IF EXISTS public.get_discovery_prospects(TEXT, INT);

CREATE FUNCTION public.get_discovery_prospects(
  p_mode  TEXT,
  p_limit INT DEFAULT 20
)
RETURNS TABLE (
  profile_id           UUID,
  display_name         TEXT,
  age                  INT,
  distance_km          DOUBLE PRECISION,
  bio                  TEXT,
  mode_id              UUID,
  image_urls           TEXT[],
  gender               TEXT,
  work_title           TEXT,
  work_company         TEXT,
  education_level      TEXT,
  educated_at          TEXT,
  height_cm            INT,
  hometown_city        TEXT,
  languages            TEXT[],
  drinking             TEXT,
  smoking              TEXT,
  exercise             TEXT,
  religion             TEXT,
  star_sign            TEXT,
  politics             TEXT,
  kids                 TEXT,
  interests            TEXT[],
  lifestyle            TEXT[],
  relationship_type    TEXT,
  qualities            TEXT[],
  causes_communities   TEXT[],
  prompts              JSONB,
  looking_for          TEXT[],
  is_verified          BOOLEAN,
  verification_level   TEXT,
  trust_score          INT,
  voice_intro_url      TEXT,
  voice_intro_duration INT,
  is_spotlight         BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me        UUID;
  v_mode      TEXT;
  v_geom      geography;
  v_district  TEXT;
  v_filters   JSONB;

  v_gender_pref     TEXT   := 'Everyone';
  v_min_age         INT    := 18;
  v_max_age         INT    := 60;
  v_distance_km     FLOAT  := 50;
  v_interests       TEXT[] := '{}';
  v_languages       TEXT[] := '{}';
  v_religion        TEXT;
  v_relationship    TEXT;
  v_orientation     TEXT;
  v_intention       TEXT;

  -- How many paid cards may be pinned to the front of one fetch. Past this the
  -- deck stops being a deck.
  -- ponytail: flat cap. Make it a spotlight_packages-style setting only if it
  -- ever needs to differ per district.
  v_spot_cap        INT    := 10;
BEGIN
  -- ---------------------------------------------------------------- caller
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  v_mode := LOWER(TRIM(p_mode));
  IF v_mode NOT IN ('date', 'bff') THEN
    RAISE EXCEPTION 'Invalid mode: %', p_mode;
  END IF;

  SELECT p.id,
         COALESCE(p.passport_location_geom, p.location_geom),
         NULLIF(lower(btrim(p.district)), '')
    INTO v_me, v_geom, v_district
    FROM profiles p
   WHERE p.user_id = auth.uid()
     AND p.is_active = TRUE
     AND p.is_deleted = FALSE;

  IF v_me IS NULL THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF v_geom IS NULL THEN
    RAISE EXCEPTION 'No location set';
  END IF;

  -- --------------------------------------------------------------- filters
  SELECT pm.filters INTO v_filters
    FROM profile_modes pm
   WHERE pm.profile_id = v_me AND pm.mode = v_mode;

  v_filters := COALESCE(v_filters, '{}'::JSONB);

  v_gender_pref  := COALESCE(v_filters->>'genderPreference', 'Everyone');
  v_min_age      := COALESCE(ROUND((v_filters->>'minAge')::NUMERIC)::INT, 18);
  v_max_age      := COALESCE(ROUND((v_filters->>'maxAge')::NUMERIC)::INT, 60);
  v_distance_km  := COALESCE((v_filters->>'distanceLimit')::FLOAT, 50);
  v_religion     := NULLIF(TRIM(v_filters->>'religion'), '');
  v_relationship := NULLIF(TRIM(v_filters->>'relationshipType'), '');
  v_orientation  := NULLIF(TRIM(v_filters->>'sexualOrientation'), '');
  v_intention    := NULLIF(TRIM(v_filters->>'datingIntention'), '');

  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedInterests', '[]'::JSONB)))
    INTO v_interests;
  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedLanguages', '[]'::JSONB)))
    INTO v_languages;

  -- The distance slider maxes out at 200km, and 200 means "anywhere".
  IF v_distance_km >= 200 THEN
    v_distance_km := 40075;  -- earth's circumference; effectively unlimited
  END IF;

  -- ------------------------------------------------------------------ feed
  RETURN QUERY
  WITH
  -- Live spotlights in my district, my mode. Filters do not apply here; the
  -- exclusions below still do.
  spot_all AS (
    SELECT DISTINCT ON (p.id)
      p.id  AS c_id,
      pm.id AS c_mode_id,
      p     AS c_p,
      pm    AS c_pm,
      ST_Distance(v_geom, COALESCE(p.passport_location_geom, p.location_geom)) / 1000.0 AS c_distance
    FROM spotlight_purchases sp
    JOIN profiles p        ON p.id = sp.profile_id
    JOIN profile_modes pm  ON pm.profile_id = p.id
                          AND pm.mode = v_mode
                          AND pm.is_active = TRUE
    WHERE v_district IS NOT NULL
      AND sp.mode = v_mode
      AND sp.payment_status = 'completed'
      AND now() >= sp.starts_at
      AND now() <  sp.expires_at
      AND lower(btrim(sp.district)) = v_district

      AND p.id <> v_me
      AND p.is_active  = TRUE
      AND p.is_deleted = FALSE

      -- Gender preference is the one filter a spotlight does not override.
      AND (
            v_gender_pref = 'Everyone'
        OR (v_gender_pref = 'Women' AND p.gender::TEXT IN ('F', 'NB'))
        OR (v_gender_pref = 'Men'   AND p.gender::TEXT IN ('M', 'NB'))
      )

      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE (s.actor_id = v_me AND s.target_id = p.id)
            OR (s.actor_id = p.id AND s.target_id = v_me
                AND s.action_type IN ('like', 'super_like'))
      )
      AND NOT EXISTS (
        SELECT 1 FROM matches m
         WHERE (m.user_a_id = v_me AND m.user_b_id = p.id)
            OR (m.user_a_id = p.id AND m.user_b_id = v_me)
      )
      AND NOT EXISTS (
        SELECT 1 FROM match_blocks b
         WHERE (b.user_a_id = v_me AND b.user_b_id = p.id)
            OR (b.user_a_id = p.id AND b.user_b_id = v_me)
      )
    -- One card per profile no matter how many windows they have stacked.
    ORDER BY p.id
  ),
  spot AS (
    SELECT s.*, row_number() OVER (ORDER BY md5(s.c_id::TEXT || v_me::TEXT)) AS c_ord
      FROM spot_all s
     ORDER BY md5(s.c_id::TEXT || v_me::TEXT)
     LIMIT v_spot_cap
  ),
  -- The ordinary deck. Spotlights already pinned above are removed so nobody
  -- appears twice; spotlights past the cap are NOT removed, and compete here
  -- on the same terms as everyone else.
  normal AS (
    SELECT
      p.id  AS c_id,
      pm.id AS c_mode_id,
      p     AS c_p,
      pm    AS c_pm,
      ST_Distance(v_geom, COALESCE(p.passport_location_geom, p.location_geom)) / 1000.0 AS c_distance
    FROM profiles p
    JOIN profile_modes pm
      ON pm.profile_id = p.id
     AND pm.mode      = v_mode
     AND pm.is_active = TRUE
    WHERE p.id <> v_me
      AND p.is_active  = TRUE
      AND p.is_deleted = FALSE
      AND NOT EXISTS (SELECT 1 FROM spot WHERE spot.c_id = p.id)

      AND COALESCE(p.passport_location_geom, p.location_geom) IS NOT NULL
      AND ST_DWithin(
            v_geom,
            COALESCE(p.passport_location_geom, p.location_geom),
            v_distance_km * 1000
          )

      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE (s.actor_id = v_me  AND s.target_id = p.id)
            OR (s.actor_id = p.id  AND s.target_id = v_me
                AND s.action_type IN ('like', 'super_like'))
      )
      -- Matches imply swipe rows both ways today, but a match with no swipe
      -- row would have leaked through. Cheap to close, same check the
      -- categories feed already makes.
      AND NOT EXISTS (
        SELECT 1 FROM matches m
         WHERE (m.user_a_id = v_me AND m.user_b_id = p.id)
            OR (m.user_a_id = p.id AND m.user_b_id = v_me)
      )
      AND NOT EXISTS (
        SELECT 1 FROM match_blocks b
         WHERE (b.user_a_id = v_me AND b.user_b_id = p.id)
            OR (b.user_a_id = p.id AND b.user_b_id = v_me)
      )

      AND p.birth_date IS NOT NULL
      AND DATE_PART('year', AGE(NOW(), p.birth_date))::INT BETWEEN v_min_age AND v_max_age

      AND (
            v_gender_pref = 'Everyone'
        OR (v_gender_pref = 'Women' AND p.gender::TEXT IN ('F', 'NB'))
        OR (v_gender_pref = 'Men'   AND p.gender::TEXT IN ('M', 'NB'))
      )

      AND (v_religion     IS NULL OR p.religion           ILIKE v_religion)
      AND (v_relationship IS NULL OR p.relationship_type  ILIKE v_relationship)
      AND (v_orientation  IS NULL OR p.sexual_orientation ILIKE v_orientation)
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
    ORDER BY c_distance ASC, COALESCE(p.trust_score, 0) DESC
    LIMIT p_limit
  ),
  deck AS (
    SELECT c_id, c_mode_id, c_p, c_pm, c_distance, TRUE AS c_spot, c_ord
      FROM spot
    UNION ALL
    SELECT c_id, c_mode_id, c_p, c_pm, c_distance, FALSE,
           row_number() OVER (ORDER BY c_distance ASC,
                                       COALESCE((c_p).trust_score, 0) DESC)
      FROM normal
  )
  SELECT
    c.c_id,
    (c.c_p).display_name::TEXT,
    DATE_PART('year', AGE(NOW(), (c.c_p).birth_date))::INT,
    c.c_distance,
    COALESCE((c.c_pm).bio, '')::TEXT,
    c.c_mode_id,
    COALESCE(ARRAY(
      SELECT m.media_url FROM profile_mode_media m
       WHERE m.profile_mode_id = c.c_mode_id
         AND m.media_type = 'photo'
         AND m.is_deleted = FALSE
       ORDER BY m.is_primary DESC, m.display_order ASC
    ), '{}')::TEXT[],
    (c.c_p).gender::TEXT,
    (c.c_p).work_title::TEXT,
    (c.c_p).work_company::TEXT,
    (c.c_p).education_level::TEXT,
    (c.c_p).educated_at::TEXT,
    (c.c_p).height_cm::INT,
    (c.c_p).hometown_city::TEXT,
    COALESCE((c.c_p).languages, '{}')::TEXT[],
    (c.c_p).drinking::TEXT,
    (c.c_p).smoking::TEXT,
    (c.c_p).exercise::TEXT,
    (c.c_p).religion::TEXT,
    (c.c_p).star_sign::TEXT,
    (c.c_p).politics::TEXT,
    (c.c_p).kids_preference::TEXT,
    COALESCE(ARRAY(
      SELECT ic.label FROM profile_mode_interestchips pmic
        JOIN interest_chips ic ON ic.id = pmic.chip_id
       WHERE pmic.profile_mode_id = c.c_mode_id
    ), '{}')::TEXT[],
    COALESCE(ARRAY(
      SELECT lc.label FROM profile_mode_lifestylechips pmlc
        JOIN lifestyle_chips lc ON lc.id = pmlc.chip_id
       WHERE pmlc.profile_mode_id = c.c_mode_id
    ), '{}')::TEXT[],
    (c.c_p).relationship_type::TEXT,
    COALESCE((c.c_p).qualities, '{}')::TEXT[],
    COALESCE((c.c_p).causes_communities, '{}')::TEXT[],
    COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
               'prompt_template_id', pmp.prompt_template_id,
               'prompt_text',        pt.prompt_text,
               'user_response',      pmp.user_response,
               'display_order',      pmp.display_order
             ) ORDER BY pmp.display_order)
        FROM profile_mode_prompts pmp
        JOIN prompt_templates pt ON pt.id = pmp.prompt_template_id
       WHERE pmp.profile_mode_id = c.c_mode_id
    ), '[]'::JSONB),
    COALESCE((c.c_pm).looking_for, '{}')::TEXT[],
    COALESCE((c.c_p).is_verified, FALSE),
    COALESCE((c.c_p).verification_level::TEXT, 'unverified'),
    COALESCE((c.c_p).trust_score, 0),
    (
      SELECT m.media_url FROM profile_mode_media m
       WHERE m.profile_mode_id = c.c_mode_id
         AND m.media_type = 'voice_intro'
         AND m.is_deleted = FALSE
       ORDER BY m.created_at DESC LIMIT 1
    )::TEXT,
    (
      SELECT m.duration_seconds FROM profile_mode_media m
       WHERE m.profile_mode_id = c.c_mode_id
         AND m.media_type = 'voice_intro'
         AND m.is_deleted = FALSE
       ORDER BY m.created_at DESC LIMIT 1
    )::INT,
    c.c_spot
  FROM deck c
  ORDER BY c.c_spot DESC, c.c_ord
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_discovery_prospects(TEXT, INT) TO authenticated;
