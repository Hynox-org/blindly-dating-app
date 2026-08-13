-- session_replication_role = 'replica' disables FK triggers, which includes
-- ON DELETE CASCADE. The old wipe held it for the whole function, so deleting
-- profiles left every child row behind: profile_modes, profile_mode_media,
-- _interestchips, _lifestylechips, _prompts, profile_languages,
-- compatibility_reports, daily_discovery_matches. A "clean" project came back
-- up full of orphans pointing at users that no longer existed.
--
-- Only storage.objects needs the bypass (protect_objects_delete guards it), so
-- replica mode is now scoped to that one statement and cascades do the rest.
-- Also wipes every bucket, not just user_photos, and pins search_path.
CREATE OR REPLACE FUNCTION public.wipe_all_user_data()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    deleted_users_count int;
    deleted_profiles_count int;
BEGIN
    DELETE FROM public.messages;
    DELETE FROM public.swipes;
    DELETE FROM public.matches;
    DELETE FROM public.veriff_verifications;

    -- Cascades to profile_modes -> media/chips/prompts, profile_languages, etc.
    DELETE FROM public.profiles;
    GET DIAGNOSTICS deleted_profiles_count = ROW_COUNT;

    -- Not reachable by cascade from profiles.
    DELETE FROM public.notifications;
    DELETE FROM public.notification_audit_logs;
    DELETE FROM public.calls;
    DELETE FROM public.user_push_tokens;
    DELETE FROM public.otp_logs;
    DELETE FROM public.compatibility_reports;
    DELETE FROM public.daily_discovery_matches;

    -- Every bucket, not just user_photos. protect_objects_delete blocks this,
    -- so this one statement runs with triggers off.
    SET LOCAL session_replication_role = 'replica';
    DELETE FROM storage.objects;
    SET LOCAL session_replication_role = 'origin';

    DELETE FROM auth.refresh_tokens;
    DELETE FROM auth.mfa_amr_claims;
    DELETE FROM auth.mfa_challenges;
    DELETE FROM auth.mfa_factors;
    DELETE FROM auth.sessions;
    DELETE FROM auth.identities;

    DELETE FROM auth.users;
    GET DIAGNOSTICS deleted_users_count = ROW_COUNT;

    RETURN json_build_object(
        'status', 'success',
        'deleted_users', deleted_users_count,
        'deleted_profiles', deleted_profiles_count
    );
EXCEPTION WHEN OTHERS THEN
    SET LOCAL session_replication_role = 'origin';
    RAISE;
END;
$$;

REVOKE ALL ON FUNCTION public.wipe_all_user_data() FROM PUBLIC, anon, authenticated;
