-- Part 2/3: the single writer.
--
-- recalculate_trust_score() is now the ONLY function that writes is_verified /
-- verification_level / trust_score. update_veriff_session() records the Veriff
-- decision and delegates every profile-level consequence to it.
--
-- Previously both wrote, and disagreed: update_veriff_session() set
-- is_verified = true, then called recalculate_trust_score(), which re-derived
-- is_verified from the empty `verifications` table and set it straight back to
-- false. Every approval un-verified the user in the same transaction.

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
  -- Only conclusive statuses count, and only the most recent one: a later
  -- decline must override an earlier approval, while a pending
  -- resubmission/review must not strip a badge already earned.
  SELECT status = 'approved' INTO v_verified
  FROM veriff_verifications
  WHERE profile_id = target_id
    AND status IN ('approved', 'declined', 'expired', 'abandoned')
  ORDER BY updated_at DESC
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

-- Webhook sink. Records the decision, then delegates. Events
-- (started/submitted) never reach here, so attempt_count now counts attempts
-- rather than webhooks.
DROP FUNCTION IF EXISTS public.update_veriff_session(text, text, numeric, text, integer, jsonb, jsonb, text, text, text);

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
  v_profile_id uuid;
BEGIN
  IF p_status NOT IN ('approved', 'declined', 'resubmission_requested',
                      'review', 'expired', 'abandoned') THEN
    RAISE EXCEPTION 'Unknown Veriff decision status: %', p_status
      USING ERRCODE = '22023';
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
  WHERE veriff_session_id = p_session_id
  RETURNING profile_id INTO v_profile_id;

  IF v_profile_id IS NULL THEN
    -- Unknown session: a forged or replayed webhook. Nothing to update.
    RETURN json_build_object('error', 'Unknown session', 'session_id', p_session_id);
  END IF;

  -- is_verified / verification_level / trust_score are all derived here.
  RETURN recalculate_trust_score(v_profile_id);
END;
$$;

REVOKE ALL ON FUNCTION public.update_veriff_session(text, text, numeric, text, integer, jsonb, jsonb, text) FROM public;
