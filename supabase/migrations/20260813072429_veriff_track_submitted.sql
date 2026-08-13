-- A submitted session was indistinguishable from an untouched one.
--
-- veriff_verifications only ever held 'created' until a VERDICT arrived. The
-- webhook dropped Veriff's lifecycle events (action=started/submitted) as
-- "nothing the client doesn't already know", and manual review at Veriff can
-- take hours. So: user submits -> leaves the screen -> comes back -> the row
-- still says 'created' -> the screen offers "Start verification" again, with no
-- sign of the attempt in flight. Starting again only reopens a submitted
-- session, which errors.
--
-- The two lifecycle statuses are now first-class. They are NOT decisions: they
-- never touch is_verified (recalculate_trust_score only counts approved /
-- declined / expired / abandoned) and they never overwrite one, because the
-- conclusive-downgrade guard below already refuses that.

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
  -- Lifecycle, not verdict: the user opened the SDK / finished uploading.
  v_lifecycle  constant text[] := ARRAY['started', 'submitted'];
  v_profile_id uuid;
  v_current    text;
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
  -- by a later inconclusive one. Covers a late 'submitted' event arriving after
  -- the decision it belongs to.
  IF v_current = ANY (v_conclusive) AND NOT (p_status = ANY (v_conclusive)) THEN
    RAISE NOTICE 'Ignoring % for session % already decided as %',
      p_status, p_session_id, v_current;
    RETURN recalculate_trust_score(v_profile_id);
  END IF;

  -- Lifecycle must not walk backwards either: a 'started' event that arrives
  -- out of order cannot un-submit a session, and neither may undo a 'review'.
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
      fail_reason   = CASE WHEN p_status = ANY (v_lifecycle)
                           THEN fail_reason ELSE p_fail_reason END,
      decision_code = COALESCE(p_code, decision_code),
      attempt_id    = COALESCE(p_attempt_id, attempt_id),
      risk_labels   = COALESCE(p_risk_labels, risk_labels),
      meta_payload  = p_payload,
      -- attempt_count means "decisions applied". Lifecycle events are not
      -- attempts; counting them would trip the reuse cap in
      -- get_active_veriff_session() and strand the user.
      attempt_count = attempt_count + CASE WHEN p_status = ANY (v_lifecycle) THEN 0 ELSE 1 END,
      updated_at    = now()
  WHERE veriff_session_id = p_session_id;

  -- is_verified / verification_level / trust_score are all derived here.
  RETURN recalculate_trust_score(v_profile_id);
END;
$$;

REVOKE ALL ON FUNCTION public.update_veriff_session(text, text, numeric, text, integer, jsonb, jsonb, text)
  FROM anon, authenticated, public;

-- A submitted session is spent: its URL cannot be reopened, so handing it back
-- would strand the user on an erroring SDK. 'started' stays reusable inside the
-- short window -- the user opened the camera and backed out without uploading.
CREATE OR REPLACE FUNCTION public.get_active_veriff_session(p_auth_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile_id uuid;
  v_result json;
BEGIN
  SELECT id INTO v_profile_id
  FROM public.profiles
  WHERE user_id = p_auth_id OR id = p_auth_id;

  SELECT json_build_object('url', session_url, 'id', veriff_session_id)
  INTO v_result
  FROM public.veriff_verifications
  WHERE profile_id = v_profile_id
    AND attempt_count < 10
    AND (
      -- Resubmission runs on the original session. Veriff keeps it alive for
      -- 7 days; past that it is dead and a new one is cheaper than a stuck user.
      (status = 'resubmission_requested' AND created_at > now() - interval '6 days')
      -- ponytail: 30 min is the "app crashed / user backed out before the
      -- camera" window. Long enough to avoid minting a session per tap, short
      -- enough that a submitted-but-undecided session is never re-handed out.
      -- Widen it only if Veriff session cost shows up on the bill.
      OR (status IN ('created', 'started') AND created_at > now() - interval '30 minutes')
    )
  ORDER BY created_at DESC
  LIMIT 1;

  RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.get_active_veriff_session(uuid)
  FROM anon, authenticated, public;
