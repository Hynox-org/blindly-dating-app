-- Checks for the Veriff verification pipeline: update_veriff_session() and the
-- verification half of recalculate_trust_score().
--
-- Wrapped in a rollback so it never mutates real verification state. Borrows an
-- existing profile rather than creating one (profiles.user_id FKs to
-- auth.users, and faking an auth user is more setup than the test is worth).
BEGIN;

DO $$
DECLARE
  me_profile   uuid;
  sess         text := 'test-session-' || gen_random_uuid()::text;
  res          json;
  raised       boolean := false;
  v_attempts   int;
  v_row        record;
  v_auth_id    uuid;
BEGIN
  SELECT id INTO me_profile FROM profiles ORDER BY id LIMIT 1;
  IF me_profile IS NULL THEN
    RAISE NOTICE 'no profiles, skipping';
    RETURN;
  END IF;

  -- Clear any real decisions for this profile so the test drives the state
  -- machine from a known starting point. Rolled back at the end.
  DELETE FROM veriff_verifications WHERE profile_id = me_profile;

  INSERT INTO veriff_verifications (profile_id, veriff_session_id, session_url, status)
  VALUES (me_profile, sess, 'https://example.invalid/session', 'created');

  ---------------------------------------------------------------------------
  -- 1. approved -> verified, full_verified, all 40 verification points.
  ---------------------------------------------------------------------------
  res := public.update_veriff_session(
           sess, 'approved', 0.12, NULL, 9001,
           '["risk_a"]'::jsonb, '{"verification":{"status":"approved"}}'::jsonb,
           'attempt-1');

  ASSERT (res->>'is_verified')::boolean,
    '1. approved did not verify: ' || res::text;
  ASSERT res->>'verification_level' = 'full_verified',
    '1. approved did not set full_verified: ' || res::text;
  ASSERT (res->'breakdown'->>'verification')::int = 40,
    '1. approved is not worth 40 points: ' || res::text;

  -- The profile row itself, not just the returned json. This is the assertion
  -- that would have caught the original bug: update_veriff_session() granted
  -- the badge, then recalculate_trust_score() revoked it in the same call.
  SELECT is_verified, verification_level INTO v_row FROM profiles WHERE id = me_profile;
  ASSERT v_row.is_verified, '1. profiles.is_verified was not persisted';
  ASSERT v_row.verification_level = 'full_verified', '1. profiles.verification_level was not persisted';

  -- Decision detail is stored, not discarded.
  SELECT * INTO v_row FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_row.decision_code = 9001, '1. decision_code not stored';
  ASSERT v_row.attempt_id = 'attempt-1', '1. attempt_id not stored';
  ASSERT v_row.risk_score = 0.12, '1. risk_score not stored';
  ASSERT v_row.risk_labels = '["risk_a"]'::jsonb, '1. risk_labels not stored';
  v_attempts := v_row.attempt_count;

  ---------------------------------------------------------------------------
  -- 2. review after approval must NOT strip a badge already earned, and must
  --    not grant one either -- it is not a conclusive decision.
  ---------------------------------------------------------------------------
  res := public.update_veriff_session(sess, 'review', NULL, NULL, 9121);
  ASSERT (res->>'is_verified')::boolean,
    '2. review stripped an existing badge: ' || res::text;

  res := public.update_veriff_session(sess, 'resubmission_requested', NULL,
           'Document is blurry', 9103);
  ASSERT (res->>'is_verified')::boolean,
    '2. resubmission_requested stripped an existing badge: ' || res::text;

  -- The row holds one status, updated in place, so an inconclusive webhook
  -- landing on a decided session must not erase the decision itself.
  SELECT status INTO v_row FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_row.status = 'approved',
    '2. a conclusive status was overwritten by an inconclusive one: ' || v_row.status;

  ---------------------------------------------------------------------------
  -- 3. A later decline overrides the earlier approval.
  ---------------------------------------------------------------------------
  res := public.update_veriff_session(sess, 'declined', 0.91, 'Face mismatch', 9102);
  ASSERT NOT (res->>'is_verified')::boolean,
    '3. decline did not revoke the badge: ' || res::text;
  ASSERT res->>'verification_level' = 'unverified',
    '3. decline did not reset verification_level: ' || res::text;
  ASSERT (res->'breakdown'->>'verification')::int = 0,
    '3. declined profile still scored verification points: ' || res::text;

  SELECT is_verified INTO v_row FROM profiles WHERE id = me_profile;
  ASSERT NOT v_row.is_verified, '3. profiles.is_verified was not revoked';

  ---------------------------------------------------------------------------
  -- 4. expired / abandoned are conclusive-but-unverified.
  ---------------------------------------------------------------------------
  res := public.update_veriff_session(sess, 'expired', NULL, NULL, 9104);
  ASSERT NOT (res->>'is_verified')::boolean, '4. expired verified the user';
  res := public.update_veriff_session(sess, 'abandoned', NULL, NULL, 9104);
  ASSERT NOT (res->>'is_verified')::boolean, '4. abandoned verified the user';

  ---------------------------------------------------------------------------
  -- 5. attempt_count counts APPLIED decisions -- not webhooks, and not the
  --    two ignored inconclusive ones. Starts at 1 on insert.
  ---------------------------------------------------------------------------
  SELECT attempt_count INTO v_attempts FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_attempts = 5,
    '5. attempt_count is ' || v_attempts || ', expected 5 (one per applied decision)';

  ---------------------------------------------------------------------------
  -- 6. An unrecognised status is rejected outright rather than written through.
  ---------------------------------------------------------------------------
  BEGIN
    PERFORM public.update_veriff_session(sess, 'success', NULL, NULL, NULL);
  EXCEPTION WHEN OTHERS THEN raised := true;
  END;
  ASSERT raised, '6. SECURITY: an unknown status was accepted';

  ---------------------------------------------------------------------------
  -- 7. A decision for an unknown session touches nothing. This is the shape of
  --    a forged or replayed webhook that survived HMAC (it cannot, but the RPC
  --    must not fall over or write anything either way).
  ---------------------------------------------------------------------------
  res := public.update_veriff_session('no-such-session-' || gen_random_uuid()::text,
                                      'approved', NULL, NULL, 9001);
  ASSERT res->>'error' = 'Unknown session',
    '7. unknown session did not return an error: ' || res::text;

  SELECT is_verified INTO v_row FROM profiles WHERE id = me_profile;
  ASSERT NOT v_row.is_verified,
    '7. SECURITY: a decision for an unknown session verified a real profile';

  ---------------------------------------------------------------------------
  -- 8. Approving again re-grants the badge (the state machine is not one-way).
  ---------------------------------------------------------------------------
  res := public.update_veriff_session(sess, 'approved', 0.05, NULL, 9001);
  ASSERT (res->>'is_verified')::boolean, '8. re-approval did not restore the badge';

  ---------------------------------------------------------------------------
  -- 9. Session reuse. A stale session must never be handed back: the URL is
  --    dead and the user would be stuck retrying it forever.
  ---------------------------------------------------------------------------
  SELECT user_id INTO v_auth_id FROM profiles WHERE id = me_profile;

  -- Fresh, never opened -> reuse (avoids minting a session per tap).
  UPDATE veriff_verifications
  SET status = 'created', created_at = now(), attempt_count = 1
  WHERE veriff_session_id = sess;
  ASSERT public.get_active_veriff_session(v_auth_id)->>'id' = sess,
    '9a. a brand new session was not reused';

  -- Same status, but old enough that it was abandoned or silently submitted.
  UPDATE veriff_verifications
  SET created_at = now() - interval '2 hours' WHERE veriff_session_id = sess;
  ASSERT public.get_active_veriff_session(v_auth_id) IS NULL,
    '9b. a stale created session was reused -- user retries a dead URL forever';

  -- Resubmission MUST reuse the original session; Veriff requires it.
  UPDATE veriff_verifications
  SET status = 'resubmission_requested', created_at = now() - interval '2 hours'
  WHERE veriff_session_id = sess;
  ASSERT public.get_active_veriff_session(v_auth_id)->>'id' = sess,
    '9c. resubmission did not reuse the original session';

  -- ...but not past Veriff's 7-day session lifetime.
  UPDATE veriff_verifications
  SET created_at = now() - interval '8 days' WHERE veriff_session_id = sess;
  ASSERT public.get_active_veriff_session(v_auth_id) IS NULL,
    '9d. an expired resubmission session was reused';

  -- A decided session is finished; never hand it back.
  UPDATE veriff_verifications
  SET status = 'declined', created_at = now() WHERE veriff_session_id = sess;
  ASSERT public.get_active_veriff_session(v_auth_id) IS NULL,
    '9e. a declined session was reused';

  ---------------------------------------------------------------------------
  -- 10. Lifecycle events. A submitted session must be distinguishable from an
  --     untouched one, or the app offers "Start verification" over an attempt
  --     already in manual review.
  ---------------------------------------------------------------------------
  UPDATE veriff_verifications
  SET status = 'created', created_at = now(), attempt_count = 1
  WHERE veriff_session_id = sess;

  res := public.update_veriff_session(sess, 'submitted');
  SELECT status, attempt_count INTO v_row
  FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_row.status = 'submitted', '10a. submitted was not recorded';
  ASSERT v_row.attempt_count = 1,
    '10b. a lifecycle event counted as an attempt (would trip the reuse cap)';
  ASSERT NOT (res->>'is_verified')::boolean, '10c. submitted verified the user';

  -- Spent session: reusing its URL would strand the user on an erroring SDK.
  ASSERT public.get_active_veriff_session(v_auth_id) IS NULL,
    '10d. a submitted session was handed back for reuse';

  -- Lifecycle must not walk backwards over a later state.
  PERFORM public.update_veriff_session(sess, 'started');
  SELECT status INTO v_row FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_row.status = 'submitted', '10e. a late started event un-submitted the session';

  -- ...nor over a decision.
  PERFORM public.update_veriff_session(sess, 'approved', 0.05, NULL, 9001);
  PERFORM public.update_veriff_session(sess, 'submitted');
  SELECT status INTO v_row FROM veriff_verifications WHERE veriff_session_id = sess;
  ASSERT v_row.status = 'approved', '10f. a late submitted event erased a verdict';

  SELECT is_verified INTO v_row FROM profiles WHERE id = me_profile;
  ASSERT v_row.is_verified, '10g. a late submitted event revoked the badge';

  RAISE NOTICE 'veriff verification checks passed';
END $$;

-- Structural checks: the legacy two-tier pipeline is gone, and no second
-- writer of profile verification state has crept back in.
DO $$
BEGIN
  ASSERT to_regclass('public.verifications') IS NULL,
    'legacy verifications table still exists';

  ASSERT NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'verification_type'),
    'legacy verification_type enum still exists';

  ASSERT NOT EXISTS (
    SELECT 1 FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    WHERE c.relname = 'veriff_verifications' AND NOT t.tgisinternal),
    'a trigger on veriff_verifications is a second writer of profile state';

  -- Only recalculate_trust_score may write these columns.
  ASSERT NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname <> 'recalculate_trust_score'
      AND p.prosrc ~* 'UPDATE\s+(public\.)?profiles[^;]*is_verified\s*='),
    'SECURITY: a second function writes profiles.is_verified';

  -- The webhook RPC is service_role only; an app user must never call it.
  -- Supabase's default privileges re-grant EXECUTE to authenticated on every
  -- CREATE FUNCTION, so these must be re-checked after any function change.
  ASSERT NOT has_function_privilege('authenticated',
           'public.update_veriff_session(text,text,numeric,text,integer,jsonb,jsonb,text)', 'EXECUTE'),
    'SECURITY: authenticated role can execute update_veriff_session';

  ASSERT NOT has_function_privilege('authenticated',
           'public.create_veriff_session(uuid,text,text)', 'EXECUTE'),
    'SECURITY: authenticated role can execute create_veriff_session';

  ASSERT NOT has_function_privilege('authenticated',
           'public.get_active_veriff_session(uuid)', 'EXECUTE'),
    'SECURITY: authenticated role can execute get_active_veriff_session';

  RAISE NOTICE 'veriff structural checks passed';
END $$;

ROLLBACK;
