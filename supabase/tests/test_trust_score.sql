-- Checks for recalculate_trust_score. Run against a database with profiles.
-- Wrapped in a rollback so it never mutates real scores.
BEGIN;

DO $$
DECLARE
  me_user       uuid;
  me_profile    uuid;
  other_profile uuid;
  res           json;
  blocked       boolean := false;
BEGIN
  SELECT user_id, id INTO me_user, me_profile FROM profiles ORDER BY id LIMIT 1;
  SELECT id INTO other_profile FROM profiles WHERE id <> me_profile LIMIT 1;

  IF me_profile IS NULL THEN
    RAISE NOTICE 'no profiles, skipping';
    RETURN;
  END IF;

  -- Score is bounded and the breakdown sums to the total.
  res := public.recalculate_trust_score(me_profile);
  ASSERT (res->>'trust_score')::int BETWEEN 0 AND 100,
    'trust_score out of range: ' || res::text;
  ASSERT (res->>'trust_score')::int =
           (res->'breakdown'->>'verification')::int
         + (res->'breakdown'->>'media')::int
         + (res->'breakdown'->>'substance')::int
         - (res->'breakdown'->>'safety_penalty')::int,
    'breakdown does not sum to total: ' || res::text;

  -- is_verified is derived from the verifications table, never from the score.
  ASSERT (res->>'is_verified')::boolean = EXISTS (
           SELECT 1 FROM verifications
           WHERE profile_id = me_profile
             AND verification_type = 'liveness' AND status = 'verified'),
    'is_verified is not derived from verifications: ' || res::text;

  -- An authenticated caller may not recalculate someone else's profile.
  IF other_profile IS NOT NULL THEN
    PERFORM set_config('request.jwt.claims', json_build_object('sub', me_user)::text, true);
    PERFORM set_config('role', 'authenticated', true);
    BEGIN
      PERFORM public.recalculate_trust_score(other_profile);
    EXCEPTION WHEN insufficient_privilege THEN blocked := true;
    END;
    ASSERT blocked, 'SECURITY: cross-profile recalculation was permitted';
    PERFORM set_config('role', 'postgres', true);
  END IF;

  RAISE NOTICE 'trust score checks passed';
END $$;

ROLLBACK;
