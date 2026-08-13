-- Found by supabase/tests/test_veriff_verification.sql.
--
-- Supabase's default privileges grant EXECUTE on new public functions to
-- anon/authenticated, which quietly re-granted these on every CREATE. All four
-- are SECURITY DEFINER and none of them authorises the caller:
--
--   update_veriff_session()     -- a user could approve their own session
--   create_veriff_session()     -- takes an auth id, so a user could act as
--   get_active_veriff_session() -- someone else
--   wipe_all_user_data()        -- deletes every user in the project
--
-- They are reachable only from Edge Functions holding the service_role key,
-- which bypasses grants entirely.
REVOKE ALL ON FUNCTION public.update_veriff_session(text, text, numeric, text, integer, jsonb, jsonb, text)
  FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.create_veriff_session(uuid, text, text)
  FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.get_active_veriff_session(uuid)
  FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.wipe_all_user_data()
  FROM PUBLIC, anon, authenticated;
