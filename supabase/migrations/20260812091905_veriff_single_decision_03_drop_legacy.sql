-- Part 3/3: retire the legacy two-tier pipeline, then backfill.
--
-- Veriff is a single-decision provider: one session covers document + face
-- match + liveness and returns one verdict. The `verifications` table modelled
-- two independent tiers (liveness / gov_id) and was written only by the ML-Kit
-- pose selfie screen, with provider='aws_rekognition' -- a provider that was
-- never integrated, so no row ever reached status='verified'. 0 rows at drop.

-- The wipe helper referenced the dropped table and missed Veriff rows entirely.
CREATE OR REPLACE FUNCTION public.wipe_all_user_data()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    deleted_users_count int;
    deleted_profiles_count int;
BEGIN
    SET LOCAL session_replication_role = 'replica';

    DELETE FROM public.messages;
    DELETE FROM public.swipes;
    DELETE FROM public.matches;

    DELETE FROM public.veriff_verifications;

    DELETE FROM public.profiles;
    GET DIAGNOSTICS deleted_profiles_count = ROW_COUNT;

    DELETE FROM public.notifications;
    DELETE FROM public.calls;
    DELETE FROM public.user_push_tokens;
    DELETE FROM public.otp_logs;

    DELETE FROM storage.objects WHERE bucket_id = 'user_photos';

    DELETE FROM auth.refresh_tokens;
    DELETE FROM auth.mfa_amr_claims;
    DELETE FROM auth.mfa_challenges;
    DELETE FROM auth.mfa_factors;
    DELETE FROM auth.sessions;
    DELETE FROM auth.identities;

    DELETE FROM auth.users;
    GET DIAGNOSTICS deleted_users_count = ROW_COUNT;

    SET LOCAL session_replication_role = 'origin';

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

DROP TABLE IF EXISTS public.verifications;
DROP TYPE IF EXISTS public.verification_type;

-- Backfill: every profile with an existing Veriff decision, which the old
-- circular logic had left un-verified.
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT DISTINCT profile_id FROM veriff_verifications LOOP
    PERFORM public.recalculate_trust_score(r.profile_id);
  END LOOP;
END $$;
