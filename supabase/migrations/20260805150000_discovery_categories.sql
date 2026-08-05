-- ============================================================================
-- Discovery landing feed (the category carousels on discover_screen).
--
-- Replaces: AWS Lambda (us-east-1) + discovery-trigger + smart-discovery
--           + process-discovery-batch + daily_discovery_matches + pg_cron job
--           + get_discovery_candidates + append_seen_profiles.
--
-- The 24h batch behaviour is preserved without any of that: today's pool is
-- picked by a hash seeded on current_date, so it is stable for the whole day
-- and rotates at midnight, per user.
--
-- Returns ids only. Callers hydrate with hydrate_discovery_profiles, which
-- already returns every field including swipe_action (the heart).
-- ============================================================================

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
  v_me          UUID;
  v_mode        TEXT;
  v_geom        geography;
  v_filters     JSONB;
  v_gender_pref TEXT   := 'Everyone';
  v_min_age     INT    := 18;
  v_max_age     INT    := 60;
  v_distance_km FLOAT  := 50;
  v_religion    TEXT;
  v_orientation TEXT;
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

  v_gender_pref := COALESCE(v_filters->>'genderPreference', 'Everyone');
  v_min_age     := COALESCE(ROUND((v_filters->>'minAge')::NUMERIC)::INT, 18);
  v_max_age     := COALESCE(ROUND((v_filters->>'maxAge')::NUMERIC)::INT, 60);
  v_distance_km := COALESCE((v_filters->>'distanceLimit')::FLOAT, 50);
  v_religion    := NULLIF(TRIM(v_filters->>'religion'), '');
  v_orientation := NULLIF(TRIM(v_filters->>'sexualOrientation'), '');

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
      -- back with swipe_action='liked' so the UI can draw the heart. Only
      -- passes, blocks and settled matches are removed.
      AND NOT EXISTS (
        SELECT 1 FROM swipes s
         WHERE s.actor_id = v_me AND s.target_id = p.id
           AND s.action_type NOT IN ('like', 'super_like'))
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
      AND (v_religion    IS NULL OR p.religion           ILIKE v_religion)
      AND (v_orientation IS NULL OR p.sexual_orientation ILIKE v_orientation)
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
   WHERE a.cap <= p_per_category;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_discovery_categories(TEXT, INT, INT) TO authenticated;
