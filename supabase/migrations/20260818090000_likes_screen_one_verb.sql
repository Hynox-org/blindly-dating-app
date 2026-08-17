-- ============================================================================
-- Likes screen: one verb.
--
-- The likes screen had its own private pair of actions (create_match /
-- ignore_like) next to the deck's record_swipe, and the two halves did not
-- cooperate:
--
--   * both RPCs filtered action_type = 'like', so Match and Pass silently
--     did nothing for super likes — the reported bug;
--   * a mutual like in the deck created the match but left the other side's
--     like 'pending', so people you had already matched with kept showing in
--     Likes;
--   * a likes-screen match fired the matches notification trigger AND two
--     client-side notification inserts — "It's a Match!" arrived twice.
--
-- Now the likes screen calls record_swipe like everyone else, and the swipe
-- trigger keeps `resolution` consistent for every path:
--
--   my like  + their pending like  → match + both rows 'matched'
--   my pass  + their pending like  → their row 'rejected'
--   my undo                        → their row back to 'pending'
--
-- create_match and ignore_like are dropped; no caller remains.
-- ============================================================================

DROP FUNCTION IF EXISTS public.create_match(uuid);
DROP FUNCTION IF EXISTS public.ignore_like(uuid);

-- ------------------------------------------------------------------ trigger
CREATE OR REPLACE FUNCTION public.handle_mutual_like()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_other_like_exists boolean;
BEGIN
  -- A pass answers any like the other person had pending on me.
  IF NEW.action_type = 'pass' THEN
    UPDATE public.swipes
       SET resolution = 'rejected'
     WHERE actor_id = NEW.target_id
       AND target_id = NEW.actor_id
       AND action_type IN ('like', 'super_like')
       AND resolution = 'pending';
    RETURN NEW;
  END IF;

  IF NEW.action_type NOT IN ('like', 'super_like') THEN
    RETURN NEW;
  END IF;

  -- No rematch for pairs that unmatched before.
  IF EXISTS (
    SELECT 1
    FROM public.match_blocks
    WHERE user_a_id = LEAST(NEW.actor_id, NEW.target_id)
      AND user_b_id = GREATEST(NEW.actor_id, NEW.target_id)
  ) THEN
    RETURN NEW;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.swipes s
    WHERE s.actor_id = NEW.target_id
      AND s.target_id = NEW.actor_id
      AND s.action_type IN ('like', 'super_like')
  )
  INTO v_other_like_exists;

  IF v_other_like_exists THEN
    INSERT INTO public.matches (
      user_a_id, user_b_id, status, created_at, expires_at
    )
    VALUES (
      LEAST(NEW.actor_id, NEW.target_id),
      GREATEST(NEW.actor_id, NEW.target_id),
      'active',
      now(),
      now() + interval '24 hours'
    )
    ON CONFLICT DO NOTHING;

    -- Both likes are answered now; 'pending' is what the likes screen shows.
    UPDATE public.swipes
       SET resolution = 'matched'
     WHERE ((actor_id = NEW.actor_id  AND target_id = NEW.target_id)
         OR (actor_id = NEW.target_id AND target_id = NEW.actor_id))
       AND action_type IN ('like', 'super_like')
       AND resolution = 'pending';
  END IF;

  RETURN NEW;
END;
$$;

-- --------------------------------------------------------------- notify
-- An instant match used to send "you've got a new admirer" AND "It's a
-- Match!" in the same second. The match trigger already tells both sides.
CREATE OR REPLACE FUNCTION public.notify_on_like()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NEW.action_type NOT IN ('like', 'super_like') THEN
    RETURN NEW;
  END IF;

  -- Mutual: the matches trigger notifies both sides, this would be noise.
  IF EXISTS (
    SELECT 1 FROM public.swipes s
    WHERE s.actor_id = NEW.target_id
      AND s.target_id = NEW.actor_id
      AND s.action_type IN ('like', 'super_like')
  ) THEN
    RETURN NEW;
  END IF;

  IF NEW.target_id IS NOT NULL THEN
    INSERT INTO public.notifications (profile_id, type, title, body, data)
    VALUES (
      NEW.target_id,
      'alert',
      'Psst... you’ve got a new admirer! ✨',
      'Someone just liked your profile. Want to see if the feeling is mutual?',
      jsonb_build_object('route', '/likes')
    );
  END IF;

  RETURN NEW;
END;
$$;

-- ------------------------------------------------------------------ undo
-- Undoing a swipe hands back whatever it answered: a like the pair matched
-- on, or a like my pass rejected, returns to 'pending' so that person
-- reappears in my likes screen.
CREATE OR REPLACE FUNCTION public.undo_last_swipe(p_target_profile_id UUID DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me       UUID;
  v_swipe_id BIGINT;
  v_target   UUID;
BEGIN
  SELECT id INTO v_me
    FROM profiles
   WHERE user_id = auth.uid()
     AND is_deleted = FALSE;

  IF v_me IS NULL THEN
    RETURN FALSE;
  END IF;

  SELECT s.id, s.target_id
    INTO v_swipe_id, v_target
    FROM swipes s
   WHERE s.actor_id = v_me
     AND (p_target_profile_id IS NULL OR s.target_id = p_target_profile_id)
   ORDER BY s.created_at DESC, s.id DESC
   LIMIT 1;

  IF v_swipe_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Once a chat exists the match is no longer take-backable.
  IF EXISTS (
    SELECT 1 FROM matches m
     WHERE m.user_a_id = LEAST(v_me, v_target)
       AND m.user_b_id = GREATEST(v_me, v_target)
       AND m.chat_started = TRUE
  ) THEN
    RETURN FALSE;
  END IF;

  DELETE FROM matches
   WHERE user_a_id = LEAST(v_me, v_target)
     AND user_b_id = GREATEST(v_me, v_target);

  DELETE FROM swipes WHERE id = v_swipe_id;

  UPDATE swipes
     SET resolution = 'pending'
   WHERE actor_id = v_target
     AND target_id = v_me
     AND action_type IN ('like', 'super_like')
     AND resolution IN ('matched', 'rejected');

  RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.undo_last_swipe(UUID) TO authenticated;

-- ---------------------------------------------------------------- likes feed
-- Same shape as before minus total_likes (the client counts its own list),
-- plus the moderation rule every other surface already applies.
-- Return type changes, so DROP first.
DROP FUNCTION IF EXISTS public.get_likes_received();

CREATE FUNCTION public.get_likes_received()
RETURNS TABLE(
  profile_id  uuid,
  display_name text,
  age         integer,
  image_path  text,
  liked_at    timestamptz,
  action_type text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  my_profile_id uuid;
BEGIN
  SELECT id
  INTO my_profile_id
  FROM public.profiles
  WHERE user_id = auth.uid()
    AND is_deleted = false
  LIMIT 1;

  IF my_profile_id IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    p.id::uuid,
    p.display_name::text,
    DATE_PART('year', AGE(p.birth_date))::int,
    COALESCE(pmm.media_url, '')::text,
    s.created_at::timestamptz,
    s.action_type::text
  FROM public.swipes s
  JOIN public.profiles p
    ON p.id = s.actor_id
  LEFT JOIN public.profile_modes pm
    ON pm.profile_id = p.id
   AND pm.is_active = true
   AND pm.mode = LOWER(p.current_mode)
  LEFT JOIN LATERAL (
    SELECT media_url
    FROM public.profile_mode_media
    WHERE profile_mode_id = pm.id
      AND media_type = 'photo'
      AND is_deleted = false
      AND moderation_status <> 'rejected'
    ORDER BY is_primary DESC, display_order ASC
    LIMIT 1
  ) pmm ON true
  WHERE s.target_id = my_profile_id
    AND s.action_type IN ('like', 'super_like')
    AND s.resolution = 'pending'
    AND p.is_deleted = false
  ORDER BY
    CASE WHEN s.action_type = 'super_like' THEN 1 ELSE 2 END ASC,
    s.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_likes_received() TO authenticated;
