-- Runnable check for get_discovery_prospects.
--   psql "$DATABASE_URL" -f supabase/tests/test_discovery_prospects.sql
--
-- The whole thing is one atomic DO block that ends in a deliberate RAISE, so
-- every seeded row is rolled back whether it passes or fails. A "PASS" message
-- in the error output is success; any other message names the broken assertion.
--
-- Assertions are scoped to the seeded ids on purpose: this runs against a
-- database that already has real profiles in it.

DO $$
DECLARE
  me      UUID := gen_random_uuid();
  near    UUID := gen_random_uuid();  -- 1km away, trust 10
  near2   UUID := gen_random_uuid();  -- 1km away, trust 90 -> must sort first
  far     UUID := gen_random_uuid();  -- ~800km away, outside the 50km filter
  swiped  UUID := gen_random_uuid();  -- I passed on them
  likedme UUID := gen_random_uuid();  -- they liked me (belongs in Liked You)
  blocked UUID := gen_random_uuid();  -- blocked me
  seed    UUID[];
  ids     UUID[];
  n       INT;
  log     TEXT := '';
BEGIN
  PERFORM set_config('request.jwt.claims', json_build_object('sub', me::text)::text, TRUE);
  seed := ARRAY[near, near2, far, swiped, likedme, blocked];

  INSERT INTO auth.users (id, email)
  SELECT u, u::text || '@test.invalid'
    FROM unnest(ARRAY[me, near, near2, far, swiped, likedme, blocked]) u;

  INSERT INTO profiles (id, user_id, display_name, gender, birth_date,
                        location_geom, is_active, is_deleted, trust_score)
  VALUES
    (me,      me,      'Me',      'M', '1995-01-01', ST_Point(77.5946,12.9716)::geography, TRUE, FALSE, 50),
    (near,    near,    'Near',    'F', '2001-01-01', ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 10),
    (near2,   near2,   'Near2',   'F', '1985-01-01', ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 90),
    (far,     far,     'Far',     'F', '1995-01-01', ST_Point(85.0000,12.9716)::geography, TRUE, FALSE, 99),
    (swiped,  swiped,  'Swiped',  'F', '1995-01-01', ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 99),
    (likedme, likedme, 'LikedMe', 'F', '1995-01-01', ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 99),
    (blocked, blocked, 'Blocked', 'F', '1995-01-01', ST_Point(77.6046,12.9716)::geography, TRUE, FALSE, 99);

  INSERT INTO profile_modes (profile_id, mode, is_active, filters)
  SELECT p, 'date', TRUE,
         '{"genderPreference":"Women","minAge":18,"maxAge":60,"distanceLimit":50}'::jsonb
    FROM unnest(ARRAY[me, near, near2, far, swiped, likedme, blocked]) p;

  INSERT INTO swipes (actor_id, target_id, action_type) VALUES (me, swiped, 'pass');
  INSERT INTO swipes (actor_id, target_id, action_type) VALUES (likedme, me, 'like');
  INSERT INTO match_blocks (user_a_id, user_b_id) VALUES (blocked, me);

  SELECT array_agg(profile_id ORDER BY ord) INTO ids FROM (
    SELECT profile_id, row_number() OVER () ord FROM get_discovery_prospects('date', 500)
  ) r WHERE profile_id = ANY(seed);

  ASSERT array_length(ids,1) = 2, format('expected 2 seeded, got %s', array_length(ids,1));
  ASSERT ids[1] = near2, 'trust tiebreak failed: higher trust must come first at equal distance';
  ASSERT ids[2] = near,  'second row wrong';
  ASSERT NOT (far     = ANY(ids)), 'out-of-radius leaked';
  ASSERT NOT (swiped  = ANY(ids)), 'already-swiped leaked';
  ASSERT NOT (likedme = ANY(ids)), 'liked-me leaked';
  ASSERT NOT (blocked = ANY(ids)), 'blocked leaked';
  log := 'exclusions+order OK ';

  UPDATE profile_modes SET filters = filters || '{"genderPreference":"Men"}'::jsonb
   WHERE profile_id = me;
  SELECT count(*) INTO n FROM get_discovery_prospects('date', 500) WHERE profile_id = ANY(seed);
  ASSERT n = 0, format('gender filter ignored: %s', n);

  UPDATE profile_modes SET filters = filters || '{"genderPreference":"Women","minAge":60,"maxAge":70}'::jsonb
   WHERE profile_id = me;
  SELECT count(*) INTO n FROM get_discovery_prospects('date', 500) WHERE profile_id = ANY(seed);
  ASSERT n = 0, format('age filter ignored: %s', n);

  -- age band selects, not just excludes: Near is ~25, Near2 is ~41
  UPDATE profile_modes SET filters = filters || '{"minAge":20,"maxAge":30}'::jsonb
   WHERE profile_id = me;
  SELECT array_agg(profile_id) INTO ids
    FROM get_discovery_prospects('date', 500) WHERE profile_id = ANY(seed);
  ASSERT ids = ARRAY[near], format('age band 20-30 should return only Near, got %s', ids);

  UPDATE profile_modes SET filters = filters || '{"minAge":35,"maxAge":45}'::jsonb
   WHERE profile_id = me;
  SELECT array_agg(profile_id) INTO ids
    FROM get_discovery_prospects('date', 500) WHERE profile_id = ANY(seed);
  ASSERT ids = ARRAY[near2], format('age band 35-45 should return only Near2, got %s', ids);

  UPDATE profile_modes SET filters = filters || '{"minAge":18,"maxAge":60,"distanceLimit":200}'::jsonb
   WHERE profile_id = me;
  SELECT count(*) INTO n FROM get_discovery_prospects('date', 500) WHERE profile_id = ANY(seed);
  ASSERT n = 3, format('distanceLimit 200 should reach Far: expected 3 seeded, got %s', n);
  log := log || 'filters OK';

  RAISE EXCEPTION 'TEST_RESULT: PASS -- %', log;
END $$;
