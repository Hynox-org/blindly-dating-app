-- meta_payload was overwritten on every write, including lifecycle events that
-- carry almost nothing ({"source":"veriff-decision","sessionState":"submitted"}).
-- The decision payload is the ONLY place the real rejection detail lives --
-- reason, reasonCode, riskLabels, per-document comments -- so losing it means
-- the app can never tell the user why they were rejected, and support has
-- nothing to look at either.
--
-- Rule: a payload that carries a decision replaces what is stored; anything
-- thinner is kept out. Lifecycle events now update status only.

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
  v_lifecycle  constant text[] := ARRAY['started', 'submitted'];
  v_profile_id uuid;
  v_current    text;
  -- A payload worth keeping: it carries the decision Veriff made.
  v_has_decision boolean := p_payload ? 'verification';
BEGIN
  IF p_status NOT IN ('approved', 'declined', 'resubmission_requested',
                      'review', 'expired', 'abandoned',
                      'started', 'submitted') THEN
    RAISE EXCEPTION 'Unknown Veriff status: %', p_status
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

  -- Lifecycle must not walk backwards over a later state either.
  IF p_status = ANY (v_lifecycle)
     AND v_current IN ('submitted', 'review', 'resubmission_requested')
     AND NOT (v_current = 'submitted' AND p_status = 'submitted') THEN
    RAISE NOTICE 'Ignoring lifecycle % for session % already at %',
      p_status, p_session_id, v_current;
    RETURN recalculate_trust_score(v_profile_id);
  END IF;

  UPDATE veriff_verifications
  SET status        = p_status,
      risk_score    = COALESCE(p_risk_score, risk_score),
      -- Keep the last real reason rather than blanking it: a decision without
      -- one (Veriff often sends reason = null) must not erase the explanation
      -- the user was already given.
      fail_reason   = COALESCE(p_fail_reason, fail_reason),
      decision_code = COALESCE(p_code, decision_code),
      attempt_id    = COALESCE(p_attempt_id, attempt_id),
      risk_labels   = CASE WHEN jsonb_array_length(COALESCE(p_risk_labels, '[]'::jsonb)) > 0
                           THEN p_risk_labels ELSE risk_labels END,
      -- The rejection detail lives here and nowhere else. Only a payload that
      -- actually carries a decision may replace it.
      meta_payload  = CASE WHEN v_has_decision THEN p_payload ELSE meta_payload END,
      attempt_count = attempt_count + CASE WHEN p_status = ANY (v_lifecycle) THEN 0 ELSE 1 END,
      updated_at    = now()
  WHERE veriff_session_id = p_session_id;

  -- is_verified / verification_level / trust_score are all derived here.
  RETURN recalculate_trust_score(v_profile_id);
END;
$$;

REVOKE ALL ON FUNCTION public.update_veriff_session(text, text, numeric, text, integer, jsonb, jsonb, text)
  FROM anon, authenticated, public;
