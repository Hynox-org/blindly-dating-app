-- Found by supabase/tests/test_veriff_verification.sql.
--
-- veriff_verifications holds ONE row per session, updated in place. A session
-- that had already been decided 'approved' could be overwritten by a later
-- inconclusive webhook ('review', 'resubmission_requested') for the same
-- session -- and since recalculate_trust_score() derives is_verified from the
-- latest *conclusive* status, that erased the approval and silently revoked
-- the user's badge with no decision ever having been reversed.
--
-- Also takes the row FOR UPDATE: Veriff retries can arrive concurrently.

CREATE OR REPLACE FUNCTION public.update_veriff_session(
  p_session_id  text,
  p_status      text,
  p_risk_score  numeric  DEFAULT NULL,
  p_fail_reason text     DEFAULT NULL,
  p_code        integer  DEFAULT NULL,
  p_risk_labels jsonb    DEFAULT '[]'::jsonb,
  p_payload     jsonb    DEFAULT '{}'::jsonb,
  p_attempt_id  text     DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_conclusive constant text[] := ARRAY['approved', 'declined', 'expired', 'abandoned'];
  v_profile_id uuid;
  v_current    text;
BEGIN
  IF p_status NOT IN ('approved', 'declined', 'resubmission_requested',
                      'review', 'expired', 'abandoned') THEN
    RAISE EXCEPTION 'Unknown Veriff decision status: %', p_status
      USING ERRCODE = '22023';
  END IF;

  -- FOR UPDATE: Veriff retries can land concurrently on the same session.
  SELECT profile_id, status INTO v_profile_id, v_current
  FROM veriff_verifications
  WHERE veriff_session_id = p_session_id
  FOR UPDATE;

  IF v_profile_id IS NULL THEN
    -- Unknown session: a forged or replayed webhook. Nothing to update.
    RETURN json_build_object('error', 'Unknown session', 'session_id', p_session_id);
  END IF;

  -- A session that already holds a conclusive verdict must not be overwritten
  -- by a later inconclusive one.
  IF v_current = ANY (v_conclusive) AND NOT (p_status = ANY (v_conclusive)) THEN
    RAISE NOTICE 'Ignoring % for session % already decided as %',
      p_status, p_session_id, v_current;
    RETURN recalculate_trust_score(v_profile_id);
  END IF;

  UPDATE veriff_verifications
  SET status        = p_status,
      risk_score    = COALESCE(p_risk_score, risk_score),
      fail_reason   = p_fail_reason,
      decision_code = p_code,
      attempt_id    = COALESCE(p_attempt_id, attempt_id),
      risk_labels   = COALESCE(p_risk_labels, risk_labels),
      meta_payload  = p_payload,
      attempt_count = attempt_count + 1,
      updated_at    = now()
  WHERE veriff_session_id = p_session_id;

  -- is_verified / verification_level / trust_score are all derived here.
  RETURN recalculate_trust_score(v_profile_id);
END;
$$;
