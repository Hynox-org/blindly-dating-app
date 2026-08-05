-- Runnable check for get_discovery_categories (the landing carousels).
--   psql "$DATABASE_URL" -f supabase/tests/test_discovery_categories.sql
--
-- One atomic DO block ending in a deliberate RAISE, so every seeded row rolls
-- back either way. "PASS" in the error output means success.

DO $$
DECLARE
  me      UUID := gen_random_uuid();
  liked   UUID := gen_random_uuid();  -- I liked them -> MUST stay (heart)
  passed  UUID := gen_random_uuid();  -- I passed     -> gone
  blocked UUID := gen_random_uuid();  -- blocked me   -> gone
  matched UUID := gen_random_uuid();  -- already matched -> gone
  likedme UUID := gen_random_uuid();  -- liked me -> belongs in Liked You
  plain   UUID := gen_random_uuid();  -- untouched -> stays
  seed UUID[]; got UUID[]; n INT; run1 TEXT; run2 TEXT; act TEXT; log TEXT := '';
BEGIN
  PERFORM set_config('request.jwt.claims', json_build_object('sub', me::text)::text, TRUE);
  seed := ARRAY[liked, passed, blocked, matched, likedme, plain];

  INSERT INTO auth.users (id, email) SELECT u, u::text || '@test.invalid'
    FROM unnest(ARRAY[me,liked,passed,blocked,matched,likedme,plain]) u;

  INSERT INTO profiles (id, user_id, display_name, gender, birth_date,
                        location_geom, is_active, is_deleted, trust_score, last_active)
  SELECT u, u, 'T'||row_number() over (), 'F', '1995-01-01',
         ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 50, now()
    FROM unnest(ARRAY[liked,passed,blocked,matched,likedme,plain]) u;

  INSERT INTO profiles (id, user_id, display_name, gender, birth_date,
                        location_geom, is_active, is_deleted, trust_score, last_active)
  VALUES (me, me, 'Me', 'M', '1995-01-01',
          ST_Point(77.5946,12.9716)::geography, TRUE, FALSE, 50, now());

  INSERT INTO profile_modes (profile_id, mode, is_active, filters)
  SELECT p, 'date', TRUE,
         '{"genderPreference":"Women","minAge":18,"maxAge":60,"distanceLimit":50}'::jsonb
    FROM unnest(ARRAY[me,liked,passed,blocked,matched,likedme,plain]) p;

  INSERT INTO swipes (actor_id, target_id, action_type) VALUES (me, liked, 'like');
  INSERT INTO swipes (actor_id, target_id, action_type) VALUES (me, passed, 'pass');
  INSERT INTO swipes (actor_id, target_id, action_type) VALUES (likedme, me, 'like');
  INSERT INTO match_blocks (user_a_id, user_b_id) VALUES (blocked, me);
  INSERT INTO matches (user_a_id, user_b_id, expires_at)
  VALUES (me, matched, now() + interval '1 day');

  SELECT array_agg(DISTINCT profile_id) INTO got
    FROM get_discovery_categories('date', 10, 50) WHERE profile_id = ANY(seed);

  ASSERT liked = ANY(got), 'a profile I LIKED must stay in the feed (for the heart)';
  ASSERT plain = ANY(got), 'untouched profile missing';
  ASSERT NOT (passed  = ANY(got)), 'passed profile leaked';
  ASSERT NOT (blocked = ANY(got)), 'blocked profile leaked';
  ASSERT NOT (matched = ANY(got)), 'matched profile leaked';
  ASSERT NOT (likedme = ANY(got)), 'liked-me profile leaked (belongs in Liked You)';
  log := 'exclusions OK ';

  -- the heart itself: hydrate must report the like
  SELECT swipe_action INTO act FROM hydrate_discovery_profiles(
    jsonb_build_object('p_ids', jsonb_build_array(liked::text), 'p_mode', 'date'));
  ASSERT act = 'liked', format('expected swipe_action=liked for the heart, got %s', act);
  log := log || 'heart OK ';

  -- nobody in two carousels
  SELECT count(*) INTO n FROM (
    SELECT profile_id FROM get_discovery_categories('date', 10, 50)
     GROUP BY profile_id HAVING count(*) > 1) d;
  ASSERT n = 0, format('%s profiles appear in more than one category', n);
  log := log || 'dedup OK ';

  -- the 24h promise: same day, same set
  SELECT string_agg(category||':'||profile_id, ',' ORDER BY category, profile_id) INTO run1
    FROM get_discovery_categories('date', 10, 50);
  SELECT string_agg(category||':'||profile_id, ',' ORDER BY category, profile_id) INTO run2
    FROM get_discovery_categories('date', 10, 50);
  ASSERT run1 = run2, 'feed is not stable across calls within the same day';
  ASSERT run1 IS NOT NULL AND run1 <> '', 'feed came back empty';
  log := log || 'stable OK';

  RAISE EXCEPTION 'TEST_RESULT: PASS -- %', log;
END $$;
