-- ============================================================================
-- record_swipe now tells the caller whether that swipe produced a match.
--
-- handle_mutual_like creates the match, but the RPC returned only
-- {success, action} — so the app could never celebrate an instant match. You
-- swiped right on someone who had already liked you and nothing happened;
-- you found out from the matches list later.
--
-- `matched` is true only when THIS call inserted the swipe (not a replay
-- absorbed by ON CONFLICT) and a match exists for the pair afterwards.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.record_swipe(p_target_profile_id uuid, p_action_type text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_actor_profile_id uuid;
  v_action_enum public.swipe_action_enum;
  v_inserted int;
  v_matched boolean := false;
BEGIN
  SELECT id
  INTO v_actor_profile_id
  FROM public.profiles
  WHERE user_id = auth.uid()
    AND is_active = true
    AND is_deleted = false;

  IF v_actor_profile_id IS NULL THEN
    RETURN json_build_object('success', false, 'code', 'PROFILE_NOT_FOUND');
  END IF;

  IF p_target_profile_id IS NULL OR p_target_profile_id = v_actor_profile_id THEN
    RETURN json_build_object('success', false, 'code', 'INVALID_TARGET');
  END IF;

  BEGIN
    v_action_enum := p_action_type::public.swipe_action_enum;
  EXCEPTION
    WHEN others THEN
      RETURN json_build_object('success', false, 'code', 'INVALID_ACTION_TYPE');
  END;

  INSERT INTO public.swipes (actor_id, target_id, action_type)
  VALUES (v_actor_profile_id, p_target_profile_id, v_action_enum)
  ON CONFLICT (actor_id, target_id) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;

  -- A replayed swipe must not re-celebrate a match the user already saw.
  IF v_inserted > 0 AND v_action_enum IN ('like', 'super_like') THEN
    SELECT EXISTS (
      SELECT 1 FROM public.matches m
       WHERE m.user_a_id = LEAST(v_actor_profile_id, p_target_profile_id)
         AND m.user_b_id = GREATEST(v_actor_profile_id, p_target_profile_id)
    ) INTO v_matched;
  END IF;

  RETURN json_build_object(
    'success', true,
    'action',  v_action_enum,
    'matched', v_matched
  );
END;
$function$;
