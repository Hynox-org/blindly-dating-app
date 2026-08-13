-- Two rows for two attempts is correct: a Veriff session is single-use, so a
-- retry after a decline is necessarily a new session. The audit trail is the
-- point -- the declined row carries the fraud signal (code 9102, risk labels)
-- that a dating app needs to keep.
--
-- What was wrong is how the winner is chosen. recalculate_trust_score() picked
-- the latest conclusive decision by updated_at, which is a WRITE timestamp, not
-- an attempt order. Veriff retries webhooks for hours, so replaying the old
-- decline after a later approval bumped that row's updated_at above the
-- approved one and silently revoked a badge the user had legitimately earned.
-- Reproduced against live data: is_verified true -> false, trust 58 -> 18, with
-- no decision having been reversed.
--
-- created_at is the session's own creation time, so it orders attempts the way
-- the user made them and no webhook timing can reorder it.

CREATE OR REPLACE FUNCTION public.recalculate_trust_score(p_profile_id uuid DEFAULT NULL)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_id       uuid;
  v_caller        uuid := auth.uid();

  v_verified      boolean;
  v_level         verification_level;

  score_verify    int := 0;
  score_media     int := 0;
  score_substance int := 0;
  penalty         int := 0;
  total           int := 0;

  v_photos        int;
  v_has_voice     boolean;
  v_flags         int;
BEGIN
  -- Resolve target. SECURITY DEFINER bypasses RLS, so a caller may only
  -- recalculate their own profile. service_role (auth.uid() IS NULL) may
  -- target any profile -- this is how the Veriff webhook calls in.
  target_id := COALESCE(p_profile_id, (SELECT id FROM profiles WHERE user_id = v_caller));

  IF target_id IS NULL THEN
    RETURN json_build_object('error', 'Profile not found');
  END IF;

  IF v_caller IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = target_id AND user_id = v_caller) THEN
    RAISE EXCEPTION 'Not authorized to recalculate trust score for profile %', target_id
      USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = target_id) THEN
    RETURN json_build_object('error', 'Profile not found');
  END IF;

  -- Verification (40). One Veriff decision covers document + face match +
  -- liveness, so it is one all-or-nothing check, not two 20-point tiers.
  -- Only conclusive statuses count, and only the most recent ATTEMPT: a later
  -- decline must override an earlier approval, while a pending
  -- resubmission/review must not strip a badge already earned.
  --
  -- Ordered by created_at (when the session was minted, i.e. attempt order),
  -- NOT updated_at (when a webhook happened to land). A retried webhook for an
  -- older attempt must never outrank a newer decision.
  SELECT status = 'approved' INTO v_verified
  FROM veriff_verifications
  WHERE profile_id = target_id
    AND status IN ('approved', 'declined', 'expired', 'abandoned')
  ORDER BY created_at DESC, updated_at DESC
  LIMIT 1;

  v_verified := COALESCE(v_verified, false);

  IF v_verified THEN score_verify := 40; END IF;

  v_level := CASE WHEN v_verified THEN 'full_verified'::verification_level
                  ELSE 'unverified'::verification_level END;

  -- Media evidence (25), counted across all active modes.
  -- ponytail: counts photos that are merely un-rejected, because nothing
  -- approves media today. Tighten to moderation_status = 'approved' as soon as
  -- a moderation step exists.
  SELECT count(*) FILTER (WHERE m.media_type = 'photo'),
         count(*) FILTER (WHERE m.media_type = 'voice_intro') > 0
    INTO v_photos, v_has_voice
  FROM profile_mode_media m
  JOIN profile_modes pm ON pm.id = m.profile_mode_id
  WHERE pm.profile_id = target_id
    AND pm.is_active
    AND m.is_deleted = false
    AND m.moderation_status <> 'rejected';

  IF v_photos >= 1 THEN score_media := score_media + 10; END IF;
  IF v_photos >= 3 THEN score_media := score_media + 8;  END IF;
  IF v_has_voice  THEN score_media := score_media + 7;   END IF;

  -- Profile substance (25). Best single mode, not the sum of both, so a user
  -- is not rewarded twice for the same effort.
  SELECT COALESCE(MAX(
           CASE WHEN length(trim(COALESCE(pm.bio, ''))) >= 30 THEN 5 ELSE 0 END
         + CASE WHEN (SELECT count(*) FROM profile_mode_prompts pr
                       WHERE pr.profile_mode_id = pm.id) >= 2 THEN 5 ELSE 0 END
         + CASE WHEN (SELECT count(*) FROM profile_mode_interestchips ic
                       WHERE ic.profile_mode_id = pm.id) >= 3 THEN 4 ELSE 0 END
         + CASE WHEN (SELECT count(*) FROM profile_mode_lifestylechips lc
                       WHERE lc.profile_mode_id = pm.id) >= 3 THEN 3 ELSE 0 END
         + CASE WHEN COALESCE(array_length(pm.looking_for, 1), 0) > 0 THEN 3 ELSE 0 END
         ), 0)
    INTO score_substance
  FROM profile_modes pm
  WHERE pm.profile_id = target_id AND pm.is_active;

  -- Identity basics (5), mode-independent.
  SELECT score_substance + CASE
           WHEN NULLIF(trim(p.display_name), '') IS NOT NULL
            AND p.birth_date IS NOT NULL
            AND p.gender IS NOT NULL
            AND NULLIF(trim(p.city), '') IS NOT NULL
            AND NULLIF(trim(p.state), '') IS NOT NULL
           THEN 5 ELSE 0 END
    INTO score_substance
  FROM profiles p WHERE p.id = target_id;

  -- Safety penalty (up to -20). No writer for safety_flags yet; reads 0.
  SELECT count(*) INTO v_flags
  FROM safety_flags sf
  JOIN profiles p ON p.user_id = sf.user_id
  WHERE p.id = target_id AND sf.created_at >= now() - interval '30 days';

  penalty := CASE WHEN v_flags = 0 THEN 0
                  WHEN v_flags = 1 THEN 5
                  WHEN v_flags = 2 THEN 10
                  ELSE 20 END;

  total := GREATEST(0, LEAST(100,
             score_verify + score_media + score_substance - penalty));

  UPDATE profiles
  SET trust_score        = total,
      verification_level = v_level,
      is_verified        = v_verified,
      updated_at         = now()
  WHERE id = target_id;

  RETURN json_build_object(
    'profile_id',  target_id,
    'trust_score', total,
    'is_verified', v_verified,
    'verification_level', v_level,
    'breakdown', json_build_object(
      'verification',   score_verify,
      'media',          score_media,
      'substance',      score_substance,
      'safety_penalty', penalty
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.recalculate_trust_score(uuid) FROM public;
GRANT EXECUTE ON FUNCTION public.recalculate_trust_score(uuid) TO authenticated;

-- The index backing the lookup should match how it is now ordered.
CREATE INDEX IF NOT EXISTS veriff_verifications_profile_created_idx
  ON public.veriff_verifications (profile_id, created_at DESC);
