-- ============================================================================
-- Spotlight test suite.
--
-- Self-contained: builds its own users, profiles and modes, exercises
-- purchase_spotlight and get_discovery_prospects through every rule the
-- feature promises, then deletes everything it made.
--
-- Safe to run against a populated database:
--   * fixture ids live in their own namespace (eeeeeeee / ffffffff), so they
--     can never collide with real rows or with the seeded test profiles;
--   * fixtures sit at (77.0, 8.0) in district 'Testville', ~600 km from the
--     seeded Chennai profiles, so even a run that aborts half way cannot put
--     a stranger into anyone's real deck;
--   * cleanup runs first as well as last, so a previous crash self-heals.
--
-- Run:  psql -f supabase/tests/spotlight_test.sql
--   or  paste into the SQL editor. The last statement is the report; any row
--       with passed = false is a failure.
--
-- Cast of fixtures:
--   1        viewer, no filters                — the deck under test
--   2        viewer, "show me Women"           — gender rule
--   3..22    buyers in Testville               — 8..11 carry prior state
--   23       buyer in Otherville               — wrong district
--   24       buyer, bff mode                   — wrong mode
-- ============================================================================

DROP TABLE IF EXISTS public._spotlight_test_results;
CREATE TABLE public._spotlight_test_results (
  seq    SERIAL PRIMARY KEY,
  name   TEXT NOT NULL,
  passed BOOLEAN NOT NULL,
  detail TEXT
);

CREATE OR REPLACE FUNCTION public._spot_assert(
  p_name TEXT, p_ok BOOLEAN, p_detail TEXT DEFAULT NULL
) RETURNS void LANGUAGE sql AS $$
  INSERT INTO public._spotlight_test_results (name, passed, detail)
  VALUES (p_name, COALESCE(p_ok, FALSE), p_detail);
$$;


DO $suite$
DECLARE
  f_user TEXT := 'eeeeeeee-0000-4000-8000-%s';
  f_prof TEXT := 'ffffffff-0000-4000-8000-%s';
  f_date TEXT := 'eeeeeeee-1111-4000-8000-%s';
  f_bff  TEXT := 'eeeeeeee-2222-4000-8000-%s';

  n_fixtures CONSTANT INT := 24;

  v_viewer   UUID;
  v_viewer_w UUID;
  v_pkg_5    UUID;
  v_pkg_60   UUID;

  i        INT;
  n        INT;
  n2       INT;
  ok       BOOLEAN;
  ids_a    UUID[];
  ids_b    UUID[];
  t_start  TIMESTAMPTZ;
  t_end    TIMESTAMPTZ;
BEGIN
  -- ------------------------------------------------------------------ setup
  DELETE FROM auth.users WHERE email LIKE 'spot-test-%@blindly.test';

  SELECT id INTO v_pkg_5  FROM public.spotlight_packages WHERE code = 'spotlight_5m';
  SELECT id INTO v_pkg_60 FROM public.spotlight_packages WHERE code = 'spotlight_60m';
  IF v_pkg_5 IS NULL OR v_pkg_60 IS NULL THEN
    RAISE EXCEPTION 'spotlight_packages not seeded — apply the schema migration first';
  END IF;

  FOR i IN 1..n_fixtures LOOP
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      created_at, updated_at, raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      format(f_user, lpad(i::text, 12, '0'))::uuid,
      'authenticated', 'authenticated',
      format('spot-test-%s@blindly.test', lpad(i::text, 2, '0')),
      'x', now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
      '', '', '', ''
    );

    INSERT INTO public.profiles (
      id, user_id, display_name, birth_date, gender, location_geom,
      district, city, country, is_active, is_deleted, is_verified,
      verification_level, trust_score, last_active, current_mode
    ) VALUES (
      format(f_prof, lpad(i::text, 12, '0'))::uuid,
      format(f_user, lpad(i::text, 12, '0'))::uuid,
      'Spot Test ' || i,
      DATE '1995-01-01',
      (CASE WHEN i = 2 THEN 'F' WHEN i % 2 = 1 THEN 'M' ELSE 'F' END)::gender_enum,
      ST_SetSRID(ST_MakePoint(77.0, 8.0), 4326)::geography,
      CASE WHEN i = 23 THEN 'Otherville' ELSE 'Testville' END,
      'Testville', 'IN', TRUE, FALSE, TRUE, 'full_verified', 50, now(), 'date'
    );

    INSERT INTO public.profile_modes (id, profile_id, mode, bio, is_active, filters)
    VALUES (
      format(f_date, lpad(i::text, 12, '0'))::uuid,
      format(f_prof, lpad(i::text, 12, '0'))::uuid,
      'date', 'test', TRUE,
      CASE WHEN i = 2 THEN '{"genderPreference":"Women"}'::jsonb ELSE '{}'::jsonb END
    );

    INSERT INTO public.profile_modes (id, profile_id, mode, bio, is_active, filters)
    VALUES (
      format(f_bff, lpad(i::text, 12, '0'))::uuid,
      format(f_prof, lpad(i::text, 12, '0'))::uuid,
      'bff', 'test', TRUE, '{}'::jsonb
    );
  END LOOP;

  v_viewer   := format(f_prof, lpad('1', 12, '0'))::uuid;
  v_viewer_w := format(f_prof, lpad('2', 12, '0'))::uuid;

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  -- ============================================================ T01
  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('date', 20) WHERE is_spotlight;
  PERFORM public._spot_assert('T01 no purchases → nothing pinned', n = 0, format('pinned=%s', n));

  -- ============================================================ T02
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('3', 12, '0'))), true);
  PERFORM public.purchase_spotlight(v_pkg_60, 'date');
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  SELECT is_spotlight INTO ok
    FROM public.get_discovery_prospects('date', 20) LIMIT 1;
  PERFORM public._spot_assert('T02 live spotlight is card #1', COALESCE(ok, FALSE));

  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T02b the buyer is the one pinned', n = 1, format('found=%s', n));

  -- ============================================================ T03
  -- 1 km, ages 40-41, a religion nobody has: the paid card survives all of it.
  UPDATE public.profile_modes
     SET filters = '{"genderPreference":"Everyone","minAge":40,"maxAge":41,"distanceLimit":1,"religion":"Zoroastrian"}'::jsonb
   WHERE profile_id = v_viewer AND mode = 'date';

  SELECT count(*) FILTER (WHERE is_spotlight),
         count(*) FILTER (WHERE NOT is_spotlight)
    INTO n, n2
    FROM public.get_discovery_prospects('date', 20);
  PERFORM public._spot_assert('T03 spotlight survives impossible filters', n = 1, format('pinned=%s', n));
  PERFORM public._spot_assert('T03b ordinary deck is still filtered', n2 = 0, format('normal=%s', n2));

  UPDATE public.profile_modes SET filters = '{}'::jsonb
   WHERE profile_id = v_viewer AND mode = 'date';

  -- ============================================================ T04
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('2', 12, '0'))), true);
  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T04 male spotlight hidden from "show me Women"', n = 0, format('found=%s', n));

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('4', 12, '0'))), true);
  PERFORM public.purchase_spotlight(v_pkg_60, 'date');
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('2', 12, '0'))), true);
  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('4', 12, '0'))::uuid;
  PERFORM public._spot_assert('T04b female spotlight shown to "show me Women"', n = 1, format('found=%s', n));

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  -- ============================================================ T05
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('23', 12, '0'))), true);
  PERFORM public.purchase_spotlight(v_pkg_60, 'date');
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('23', 12, '0'))::uuid;
  PERFORM public._spot_assert('T05 another district is not pinned', n = 0, format('found=%s', n));

  -- ============================================================ T06/T07/T08
  INSERT INTO public.spotlight_purchases
    (profile_id, package_id, mode, district, amount_inr, payment_status, starts_at, expires_at)
  VALUES
    (format(f_prof, lpad('5', 12, '0'))::uuid, v_pkg_5, 'date', 'Testville', 250,
     'completed', now() - INTERVAL '2 hours', now() - INTERVAL '1 hour'),
    (format(f_prof, lpad('6', 12, '0'))::uuid, v_pkg_5, 'date', 'Testville', 250,
     'completed', now() + INTERVAL '1 hour', now() + INTERVAL '2 hours'),
    (format(f_prof, lpad('7', 12, '0'))::uuid, v_pkg_5, 'date', 'Testville', 250,
     'pending',   now() - INTERVAL '1 minute', now() + INTERVAL '1 hour');

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('5', 12, '0'))::uuid;
  PERFORM public._spot_assert('T06 expired window not pinned', n = 0, format('found=%s', n));

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('6', 12, '0'))::uuid;
  PERFORM public._spot_assert('T07 not-yet-started window not pinned', n = 0, format('found=%s', n));

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('7', 12, '0'))::uuid;
  PERFORM public._spot_assert('T08 unpaid window not pinned', n = 0, format('found=%s', n));

  -- ============================================================ T09..T12
  -- Buyers 8..11 all hold live spotlights, and all have prior state with the
  -- viewer that must beat the spotlight.
  FOR i IN 8..11 LOOP
    PERFORM set_config('request.jwt.claims',
      format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad(i::text, 12, '0'))), true);
    PERFORM public.purchase_spotlight(v_pkg_60, 'date');
  END LOOP;
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  INSERT INTO public.swipes (actor_id, target_id, action_type)
  VALUES (v_viewer, format(f_prof, lpad('8', 12, '0'))::uuid, 'pass');
  INSERT INTO public.swipes (actor_id, target_id, action_type)
  VALUES (format(f_prof, lpad('9', 12, '0'))::uuid, v_viewer, 'like');
  INSERT INTO public.match_blocks (user_a_id, user_b_id)
  VALUES (v_viewer, format(f_prof, lpad('10', 12, '0'))::uuid);
  INSERT INTO public.matches (user_a_id, user_b_id, expires_at)
  VALUES (v_viewer, format(f_prof, lpad('11', 12, '0'))::uuid, now() + INTERVAL '7 days');

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('8', 12, '0'))::uuid;
  PERFORM public._spot_assert('T09 someone I passed stays gone', n = 0, format('found=%s', n));

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('9', 12, '0'))::uuid;
  PERFORM public._spot_assert('T10 someone who liked me stays in Likes', n = 0, format('found=%s', n));

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('10', 12, '0'))::uuid;
  PERFORM public._spot_assert('T11 blocked stays gone', n = 0, format('found=%s', n));

  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('11', 12, '0'))::uuid;
  PERFORM public._spot_assert('T12 matched stays gone', n = 0, format('found=%s', n));

  -- ============================================================ T13
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('3', 12, '0'))), true);
  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T13 a buyer never sees themselves', n = 0, format('found=%s', n));

  -- ============================================================ T14
  -- Eligible-for-viewer-1 buyers so far: 3, 4. Add 12..22 and revive 5/6/7,
  -- which takes the pool to 16 — comfortably past the cap of 10.
  FOR i IN 12..22 LOOP
    PERFORM set_config('request.jwt.claims',
      format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad(i::text, 12, '0'))), true);
    PERFORM public.purchase_spotlight(v_pkg_60, 'date');
  END LOOP;

  UPDATE public.spotlight_purchases
     SET payment_status = 'completed',
         starts_at  = now() - INTERVAL '1 minute',
         expires_at = now() + INTERVAL '1 hour'
   WHERE profile_id IN (
     format(f_prof, lpad('5', 12, '0'))::uuid,
     format(f_prof, lpad('6', 12, '0'))::uuid,
     format(f_prof, lpad('7', 12, '0'))::uuid);

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  SELECT count(*) INTO n2
    FROM public.spotlight_purchases sp
   WHERE sp.district = 'Testville' AND sp.mode = 'date'
     AND sp.payment_status = 'completed'
     AND now() BETWEEN sp.starts_at AND sp.expires_at;
  PERFORM public._spot_assert('T14 pre-check: more live spotlights than the cap',
    n2 > 10, format('live=%s', n2));

  SELECT count(*) FILTER (WHERE is_spotlight) INTO n
    FROM public.get_discovery_prospects('date', 20);
  PERFORM public._spot_assert('T14b pinned cards capped at 10', n = 10, format('pinned=%s', n));

  SELECT count(*) INTO n FROM (
    SELECT profile_id FROM public.get_discovery_prospects('date', 20)
     GROUP BY profile_id HAVING count(*) > 1) d;
  PERFORM public._spot_assert('T14c no profile appears twice', n = 0, format('dupes=%s', n));

  -- ============================================================ T15/T16
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('3', 12, '0'))), true);
  SELECT starts_at, expires_at INTO t_start, t_end
    FROM public.spotlight_purchases
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid
   ORDER BY expires_at DESC LIMIT 1;
  PERFORM public.purchase_spotlight(v_pkg_5, 'date');

  SELECT count(*) INTO n FROM public.spotlight_purchases
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T15 buying again writes a second row', n = 2, format('rows=%s', n));

  SELECT bool_and(sp.starts_at = t_end) INTO ok
    FROM public.spotlight_purchases sp
   WHERE sp.profile_id = format(f_prof, lpad('3', 12, '0'))::uuid
     AND sp.starts_at > t_start;
  PERFORM public._spot_assert('T16 the new window starts where the old ended', COALESCE(ok, FALSE));

  SELECT max(expires_at) - min(starts_at) = INTERVAL '65 minutes' INTO ok
    FROM public.spotlight_purchases
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T16b 60 + 5 becomes 65 consecutive minutes', COALESCE(ok, FALSE));

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);
  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('3', 12, '0'))::uuid;
  PERFORM public._spot_assert('T15b stacked windows still show one card', n = 1, format('found=%s', n));

  -- ============================================================ T17
  SELECT bool_and(sp.amount_inr = pk.price_inr) INTO ok
    FROM public.spotlight_purchases sp
    JOIN public.spotlight_packages pk ON pk.id = sp.package_id
   WHERE sp.profile_id::text LIKE 'ffffffff-%';
  PERFORM public._spot_assert('T17 amount always matches the package price', COALESCE(ok, FALSE));

  -- ============================================================ T18
  SELECT count(*) INTO n
    FROM public.get_discovery_prospects('bff', 20) WHERE is_spotlight;
  PERFORM public._spot_assert('T18 date purchases do not pin in the bff deck', n = 0, format('pinned=%s', n));

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('24', 12, '0'))), true);
  PERFORM public.purchase_spotlight(v_pkg_60, 'bff');
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);
  SELECT count(*) INTO n FROM public.get_discovery_prospects('bff', 20)
   WHERE is_spotlight AND profile_id = format(f_prof, lpad('24', 12, '0'))::uuid;
  PERFORM public._spot_assert('T18b a bff purchase pins in the bff deck', n = 1, format('found=%s', n));

  -- ============================================================ T19
  UPDATE public.profiles SET is_active = FALSE
   WHERE id = format(f_prof, lpad('12', 12, '0'))::uuid;
  SELECT count(*) INTO n FROM public.get_discovery_prospects('date', 20)
   WHERE profile_id = format(f_prof, lpad('12', 12, '0'))::uuid;
  PERFORM public._spot_assert('T19 deactivating removes the card at once', n = 0, format('found=%s', n));
  UPDATE public.profiles SET is_active = TRUE
   WHERE id = format(f_prof, lpad('12', 12, '0'))::uuid;

  -- ============================================================ T20
  -- Viewer 2 drops its gender filter first, so the two viewers are comparing
  -- the same pool and only the shuffle can differ.
  UPDATE public.profile_modes SET filters = '{}'::jsonb
   WHERE profile_id = v_viewer_w AND mode = 'date';

  SELECT array_agg(profile_id ORDER BY ord) INTO ids_a FROM (
    SELECT profile_id, row_number() OVER () AS ord
      FROM public.get_discovery_prospects('date', 20) WHERE is_spotlight) x;

  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('2', 12, '0'))), true);
  SELECT array_agg(profile_id ORDER BY ord) INTO ids_b FROM (
    SELECT profile_id, row_number() OVER () AS ord
      FROM public.get_discovery_prospects('date', 20) WHERE is_spotlight) x;
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('1', 12, '0'))), true);

  PERFORM public._spot_assert('T20 both viewers see a full ten pinned',
    array_length(ids_a, 1) = 10 AND array_length(ids_b, 1) = 10,
    format('a=%s b=%s', array_length(ids_a, 1), array_length(ids_b, 1)));

  PERFORM public._spot_assert('T20b the two viewers get different orders',
    ids_a IS DISTINCT FROM ids_b);

  SELECT array_agg(profile_id ORDER BY ord) INTO ids_b FROM (
    SELECT profile_id, row_number() OVER () AS ord
      FROM public.get_discovery_prospects('date', 20) WHERE is_spotlight) x;
  PERFORM public._spot_assert('T20c one viewer gets a stable order twice', ids_a = ids_b);

  -- ============================================================ T21
  SELECT bool_and(ordered) INTO ok FROM (
    SELECT is_spotlight >= lead(is_spotlight) OVER (ORDER BY ord) AS ordered
      FROM (SELECT is_spotlight, row_number() OVER () AS ord
              FROM public.get_discovery_prospects('date', 20)) y) z
   WHERE ordered IS NOT NULL;
  PERFORM public._spot_assert('T21 no ordinary card outranks a spotlight', COALESCE(ok, TRUE));

  -- ============================================================ T22
  UPDATE public.profiles SET district = NULL
   WHERE id = format(f_prof, lpad('22', 12, '0'))::uuid;
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('22', 12, '0'))), true);
  BEGIN
    PERFORM public.purchase_spotlight(v_pkg_5, 'date');
    PERFORM public._spot_assert('T22 no district → purchase refused', FALSE, 'no exception raised');
  EXCEPTION WHEN OTHERS THEN
    PERFORM public._spot_assert('T22 no district → purchase refused',
      SQLERRM LIKE '%No district set%', SQLERRM);
  END;

  -- A viewer with no district simply sees no spotlights, and does not error.
  BEGIN
    SELECT count(*) FILTER (WHERE is_spotlight) INTO n
      FROM public.get_discovery_prospects('date', 20);
    PERFORM public._spot_assert('T22b no district → deck works, nothing pinned',
      n = 0, format('pinned=%s', n));
  EXCEPTION WHEN OTHERS THEN
    PERFORM public._spot_assert('T22b no district → deck works, nothing pinned', FALSE, SQLERRM);
  END;

  -- ============================================================ T23
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('13', 12, '0'))), true);
  BEGIN
    PERFORM public.purchase_spotlight('00000000-0000-0000-0000-000000000000'::uuid, 'date');
    PERFORM public._spot_assert('T23 unknown package refused', FALSE, 'no exception raised');
  EXCEPTION WHEN OTHERS THEN
    PERFORM public._spot_assert('T23 unknown package refused', SQLERRM ILIKE '%package%', SQLERRM);
  END;

  BEGIN
    PERFORM public.purchase_spotlight(v_pkg_5, 'flirt');
    PERFORM public._spot_assert('T23b invalid mode refused', FALSE, 'no exception raised');
  EXCEPTION WHEN OTHERS THEN
    PERFORM public._spot_assert('T23b invalid mode refused', SQLERRM ILIKE '%invalid mode%', SQLERRM);
  END;

  -- ============================================================ T24
  PERFORM set_config('request.jwt.claims',
    format('{"sub":"%s","role":"authenticated"}', format(f_user, lpad('3', 12, '0'))), true);
  SELECT count(*) INTO n FROM public.get_my_spotlight() WHERE mode = 'date';
  PERFORM public._spot_assert('T24 one live row per mode', n = 1, format('rows=%s', n));

  SELECT bool_and(seconds_remaining BETWEEN 3500 AND 3960) INTO ok
    FROM public.get_my_spotlight() WHERE mode = 'date';
  PERFORM public._spot_assert('T24b seconds_remaining reports the end of the stack',
    COALESCE(ok, FALSE));

  -- --------------------------------------------------------------- teardown
  PERFORM set_config('request.jwt.claims', '', true);
  DELETE FROM public.matches
   WHERE user_a_id::text LIKE 'ffffffff-%' OR user_b_id::text LIKE 'ffffffff-%';
  DELETE FROM public.match_blocks
   WHERE user_a_id::text LIKE 'ffffffff-%' OR user_b_id::text LIKE 'ffffffff-%';
  DELETE FROM public.swipes
   WHERE actor_id::text LIKE 'ffffffff-%' OR target_id::text LIKE 'ffffffff-%';
  DELETE FROM auth.users WHERE email LIKE 'spot-test-%@blindly.test';

  SELECT count(*) INTO n FROM public.profiles WHERE id::text LIKE 'ffffffff-%';
  PERFORM public._spot_assert('T99 fixtures cleaned up', n = 0, format('left=%s', n));

  SELECT count(*) INTO n FROM public.spotlight_purchases
   WHERE profile_id::text LIKE 'ffffffff-%';
  PERFORM public._spot_assert('T99b test purchases cleaned up', n = 0, format('left=%s', n));
END
$suite$;


SELECT
  seq,
  CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS result,
  name,
  detail
FROM public._spotlight_test_results
ORDER BY seq;
