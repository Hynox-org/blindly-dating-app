-- get_active_veriff_session() handed back any session sitting in
-- 'created'/'started' with no age limit. Nothing ever writes 'started' (the
-- webhook drops event payloads), so a user who opened the SDK and abandoned --
-- or submitted while the callback URL was misconfigured -- left the row on
-- 'created' forever. Every later "Start verification" returned that same URL.
--
-- A Veriff session URL dies after 7 days and a submitted session cannot be
-- reopened, so the SDK errored on every retry with no way out: permanently
-- stuck, and attempt_count never grew to trip the < 10 escape hatch.
--
-- Reuse is now only for the two cases where it is actually correct:
--   * resubmission_requested -- Veriff REQUIRES the same session to resubmit.
--   * a brand new session the user has only just been handed.
-- Anything else mints a fresh session, which self-heals the stuck state.

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

-- Supabase re-grants EXECUTE to app roles on every CREATE FUNCTION.
REVOKE ALL ON FUNCTION public.get_active_veriff_session(uuid)
  FROM anon, authenticated, public;
