-- ============================================================================
-- Swipe deck hardening.
--
-- 1. get_discovery_prospects served every non-deleted photo, moderation status
--    ignored, and returned profiles with no photos at all (the client papered
--    over those with a ui-avatars placeholder). Rejected media is now excluded
--    and a profile needs at least one usable photo to enter the deck.
--
--    Convention matches rewrite_trust_score / veriff: exclude 'rejected'
--    rather than require 'approved', because nothing auto-approves yet.
--
-- 2. undo_last_swipe deleted "the newest like or pass by me", ignoring which
--    profile the UI actually put back and skipping super likes entirely — so
--    undoing a super like deleted an unrelated earlier swipe. It also left
--    behind the match row that handle_mutual_like had just created.
--    It now takes the target, covers super likes, and drops the match it
--    undoes — unless that match already has a chat, in which case the undo is
--    refused rather than silently destroying a live conversation.
-- ============================================================================

-- ------------------------------------------------------------------ prospects
CREATE OR REPLACE FUNCTION public.get_discovery_prospects(
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
  voice_intro_duration INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me        UUID;
  v_mode      TEXT;
  v_geom      geography;
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
BEGIN
  -- ---------------------------------------------------------------- caller
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  v_mode := LOWER(TRIM(p_mode));
  IF v_mode NOT IN ('date', 'bff') THEN
    RAISE EXCEPTION 'Invalid mode: %', p_mode;
  END IF;

  SELECT p.id, COALESCE(p.passport_location_geom, p.location_geom)
    INTO v_me, v_geom
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
  WITH candidates AS (
    SELECT
      p.id AS c_id,
      pm.id AS c_mode_id,
      p AS c_p,
      pm AS c_pm,
      ST_Distance(v_geom, COALESCE(p.passport_location_geom, p.location_geom)) / 1000.0 AS c_distance
    FROM profiles p
    JOIN profile_modes pm
      ON pm.profile_id = p.id
     AND pm.mode      = v_mode
     AND pm.is_active = TRUE
    WHERE p.id <> v_me
      AND p.is_active  = TRUE
      AND p.is_deleted = FALSE

      -- location required, and within the radius
      AND COALESCE(p.passport_location_geom, p.location_geom) IS NOT NULL
      AND ST_DWithin(
            v_geom,
            COALESCE(p.passport_location_geom, p.location_geom),
            v_distance_km * 1000
          )

      -- a card with no showable photo is not a card
      AND EXISTS (
        SELECT 1 FROM profile_mode_media m
         WHERE m.profile_mode_id = pm.id
           AND m.media_type = 'photo'
           AND m.is_deleted = FALSE
           AND m.moderation_status <> 'rejected'
      )

      -- already interacted, either direction: I swiped them, or they liked me
      -- (a like from them belongs in Liked You, and a mutual match implies
      --  swipe rows both ways, so matches are covered here too)
      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE (s.actor_id = v_me  AND s.target_id = p.id)
            OR (s.actor_id = p.id  AND s.target_id = v_me
                AND s.action_type IN ('like', 'super_like'))
      )

      -- blocked, either direction
      AND NOT EXISTS (
        SELECT 1 FROM match_blocks b
         WHERE (b.user_a_id = v_me AND b.user_b_id = p.id)
            OR (b.user_a_id = p.id AND b.user_b_id = v_me)
      )

      -- age
      AND p.birth_date IS NOT NULL
      AND DATE_PART('year', AGE(NOW(), p.birth_date))::INT BETWEEN v_min_age AND v_max_age

      -- gender: NB matches both preferences, symmetrically
      AND (
            v_gender_pref = 'Everyone'
        OR (v_gender_pref = 'Women' AND p.gender::TEXT IN ('F', 'NB'))
        OR (v_gender_pref = 'Men'   AND p.gender::TEXT IN ('M', 'NB'))
      )

      -- optional single-value filters
      AND (v_religion     IS NULL OR p.religion          ILIKE v_religion)
      AND (v_relationship IS NULL OR p.relationship_type ILIKE v_relationship)
      AND (v_orientation  IS NULL OR p.sexual_orientation ILIKE v_orientation)
      AND (v_intention    IS NULL OR p.dating_intention  ILIKE v_intention)

      -- optional list filters: any overlap counts
      AND (
        v_languages = '{}'
        OR COALESCE(p.languages, '{}') && v_languages
      )
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
         AND m.moderation_status <> 'rejected'
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
         AND m.moderation_status <> 'rejected'
       ORDER BY m.created_at DESC LIMIT 1
    )::TEXT,
    (
      SELECT m.duration_seconds FROM profile_mode_media m
       WHERE m.profile_mode_id = c.c_mode_id
         AND m.media_type = 'voice_intro'
         AND m.is_deleted = FALSE
         AND m.moderation_status <> 'rejected'
       ORDER BY m.created_at DESC LIMIT 1
    )::INT
  FROM candidates c
  ORDER BY c.c_distance ASC, COALESCE((c.c_p).trust_score, 0) DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_discovery_prospects(TEXT, INT) TO authenticated;

-- Keeps the "does this profile have a showable photo" check off a seq scan.
CREATE INDEX IF NOT EXISTS idx_media_mode_type_live
  ON public.profile_mode_media (profile_mode_id, media_type)
  WHERE is_deleted = FALSE AND moderation_status <> 'rejected';

-- ----------------------------------------------------------------------- undo
-- Signature changes (target argument), so the old one has to go or calls
-- become ambiguous.
DROP FUNCTION IF EXISTS public.undo_last_swipe();

CREATE FUNCTION public.undo_last_swipe(p_target_profile_id UUID DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me       UUID;
  v_swipe_id BIGINT;
  v_target   UUID;
BEGIN
  SELECT id INTO v_me
    FROM profiles
   WHERE user_id = auth.uid()
     AND is_deleted = FALSE;

  IF v_me IS NULL THEN
    RETURN FALSE;
  END IF;

  -- With a target: undo that exact card, whatever the action was.
  -- Without: the caller just means "my last swipe" (grid + detail screens).
  SELECT s.id, s.target_id
    INTO v_swipe_id, v_target
    FROM swipes s
   WHERE s.actor_id = v_me
     AND (p_target_profile_id IS NULL OR s.target_id = p_target_profile_id)
   ORDER BY s.created_at DESC, s.id DESC
   LIMIT 1;

  IF v_swipe_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- A mutual like may already have produced a match. Undoing is only honest
  -- while nobody has spoken yet; once a chat exists, refuse.
  IF EXISTS (
    SELECT 1 FROM matches m
     WHERE m.user_a_id = LEAST(v_me, v_target)
       AND m.user_b_id = GREATEST(v_me, v_target)
       AND m.chat_started = TRUE
  ) THEN
    RETURN FALSE;
  END IF;

  DELETE FROM matches
   WHERE user_a_id = LEAST(v_me, v_target)
     AND user_b_id = GREATEST(v_me, v_target);

  DELETE FROM swipes WHERE id = v_swipe_id;

  RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.undo_last_swipe(UUID) TO authenticated;

-- ---------------------------------------------------------------- self-swipe
-- record_swipe took any profile id from the client without checking it wasn't
-- the caller's own. The deck never offers you yourself, but the RPC is public:
-- a self "like" reached handle_mutual_like, which tried to match the user with
-- themselves and died on the different_users check (a 500 to the client), and
-- a self "pass" quietly wrote a junk row.
CREATE OR REPLACE FUNCTION public.record_swipe(p_target_profile_id uuid, p_action_type text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_actor_profile_id uuid;
  v_action_enum public.swipe_action_enum;
BEGIN
  SELECT id
  INTO v_actor_profile_id
  FROM public.profiles
  WHERE user_id = auth.uid()
    AND is_active = true
    AND is_deleted = false;

  IF v_actor_profile_id IS NULL THEN
    RETURN json_build_object('success', false, 'code', 'PROFILE_NOT_FOUND');
  END IF;

  IF p_target_profile_id IS NULL OR p_target_profile_id = v_actor_profile_id THEN
    RETURN json_build_object('success', false, 'code', 'INVALID_TARGET');
  END IF;

  BEGIN
    v_action_enum := p_action_type::public.swipe_action_enum;
  EXCEPTION
    WHEN others THEN
      RETURN json_build_object('success', false, 'code', 'INVALID_ACTION_TYPE');
  END;

  INSERT INTO public.swipes (actor_id, target_id, action_type)
  VALUES (v_actor_profile_id, p_target_profile_id, v_action_enum)
  ON CONFLICT (actor_id, target_id) DO NOTHING;

  RETURN json_build_object('success', true, 'action', v_action_enum);
END;
$function$;
