


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions";






CREATE SCHEMA IF NOT EXISTS "topology";
CREATE EXTENSION IF NOT EXISTS "postgis_topology" WITH SCHEMA "topology";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."admin_role" AS ENUM (
    'moderator',
    'senior_mod',
    'admin',
    'super_admin'
);


ALTER TYPE "public"."admin_role" OWNER TO "postgres";


CREATE TYPE "public"."attribute_category_enum" AS ENUM (
    'diet',
    'religion',
    'education',
    'smoking',
    'drinking',
    'language',
    'height',
    'occupation',
    'income',
    'relationship_status',
    'children'
);


ALTER TYPE "public"."attribute_category_enum" OWNER TO "postgres";


CREATE TYPE "public"."attribute_importance" AS ENUM (
    'low',
    'medium',
    'high',
    'dealbreaker'
);


ALTER TYPE "public"."attribute_importance" OWNER TO "postgres";


CREATE TYPE "public"."billing_cycle_type" AS ENUM (
    '1_month',
    '3_month',
    '6_month',
    '12_month'
);


ALTER TYPE "public"."billing_cycle_type" OWNER TO "postgres";


CREATE TYPE "public"."block_reason_enum" AS ENUM (
    'harassment',
    'spam',
    'catfish',
    'offensive_behavior',
    'other'
);


ALTER TYPE "public"."block_reason_enum" OWNER TO "postgres";


CREATE TYPE "public"."challenge_status" AS ENUM (
    'active',
    'completed',
    'claimed',
    'expired'
);


ALTER TYPE "public"."challenge_status" OWNER TO "postgres";


CREATE TYPE "public"."challenge_type" AS ENUM (
    'daily',
    'weekly',
    'monthly'
);


ALTER TYPE "public"."challenge_type" OWNER TO "postgres";


CREATE TYPE "public"."content_type" AS ENUM (
    'profile',
    'photo',
    'message',
    'event'
);


ALTER TYPE "public"."content_type" OWNER TO "postgres";


CREATE TYPE "public"."conversation_type" AS ENUM (
    'direct',
    'event_group'
);


ALTER TYPE "public"."conversation_type" OWNER TO "postgres";


CREATE TYPE "public"."event_category" AS ENUM (
    'foodie',
    'tech',
    'outdoor',
    'adventure',
    'volunteer',
    'cultural',
    'sports',
    'nightlife'
);


ALTER TYPE "public"."event_category" OWNER TO "postgres";


CREATE TYPE "public"."event_rsvp_status" AS ENUM (
    'going',
    'maybe',
    'waitlist',
    'checked_in',
    'cancelled'
);


ALTER TYPE "public"."event_rsvp_status" OWNER TO "postgres";


CREATE TYPE "public"."export_format_type" AS ENUM (
    'json',
    'csv'
);


ALTER TYPE "public"."export_format_type" OWNER TO "postgres";


CREATE TYPE "public"."export_status" AS ENUM (
    'requested',
    'processing',
    'ready',
    'downloaded',
    'expired'
);


ALTER TYPE "public"."export_status" OWNER TO "postgres";


CREATE TYPE "public"."gender_enum" AS ENUM (
    'M',
    'F',
    'NB',
    'Prefer Not'
);


ALTER TYPE "public"."gender_enum" OWNER TO "postgres";


CREATE TYPE "public"."icebreaker_category" AS ENUM (
    'funny',
    'deep',
    'foodie',
    'travel',
    'interests'
);


ALTER TYPE "public"."icebreaker_category" OWNER TO "postgres";


CREATE TYPE "public"."importance_level" AS ENUM (
    'low',
    'medium',
    'high',
    'dealbreaker'
);


ALTER TYPE "public"."importance_level" OWNER TO "postgres";


CREATE TYPE "public"."match_status" AS ENUM (
    'active',
    'expired',
    'unmatched',
    'blocked'
);


ALTER TYPE "public"."match_status" OWNER TO "postgres";


CREATE TYPE "public"."match_status_enum" AS ENUM (
    'active',
    'expired',
    'unmatched'
);


ALTER TYPE "public"."match_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."message_type" AS ENUM (
    'text',
    'image',
    'voice_note',
    'call_log',
    'emoji_only'
);


ALTER TYPE "public"."message_type" OWNER TO "postgres";


CREATE TYPE "public"."metric_type" AS ENUM (
    'coins_earned',
    'matches_made',
    'events_attended',
    'messages_sent'
);


ALTER TYPE "public"."metric_type" OWNER TO "postgres";


CREATE TYPE "public"."moderation_action" AS ENUM (
    'warned',
    'suspended',
    'banned',
    'false_report'
);


ALTER TYPE "public"."moderation_action" OWNER TO "postgres";


CREATE TYPE "public"."moderation_queue_status" AS ENUM (
    'pending',
    'assigned',
    'completed',
    'appealed'
);


ALTER TYPE "public"."moderation_queue_status" OWNER TO "postgres";


CREATE TYPE "public"."moderation_reason_enum" AS ENUM (
    'nudity_detected',
    'low_quality',
    'face_not_visible',
    'group_photo',
    'logo_detected',
    'watermark',
    'repeated_edit',
    'other'
);


ALTER TYPE "public"."moderation_reason_enum" OWNER TO "postgres";


CREATE TYPE "public"."moderation_status" AS ENUM (
    'pending',
    'approved',
    'rejected',
    'appeal'
);


ALTER TYPE "public"."moderation_status" OWNER TO "postgres";


CREATE TYPE "public"."payment_status" AS ENUM (
    'pending',
    'completed',
    'failed',
    'refunded'
);


ALTER TYPE "public"."payment_status" OWNER TO "postgres";


CREATE TYPE "public"."period_type" AS ENUM (
    'daily',
    'weekly',
    'monthly'
);


ALTER TYPE "public"."period_type" OWNER TO "postgres";


CREATE TYPE "public"."priority_level" AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE "public"."priority_level" OWNER TO "postgres";


CREATE TYPE "public"."razorpay_payment_status" AS ENUM (
    'created',
    'authorized',
    'captured',
    'refunded',
    'failed'
);


ALTER TYPE "public"."razorpay_payment_status" OWNER TO "postgres";


CREATE TYPE "public"."report_category" AS ENUM (
    'fake_profile',
    'underage',
    'harassment',
    'spam',
    'offensive_photo',
    'scam',
    'inappropriate_message',
    'bot_behavior'
);


ALTER TYPE "public"."report_category" OWNER TO "postgres";


CREATE TYPE "public"."report_status" AS ENUM (
    'open',
    'investigating',
    'resolved',
    'dismissed',
    'appealed'
);


ALTER TYPE "public"."report_status" OWNER TO "postgres";


CREATE TYPE "public"."review_status" AS ENUM (
    'unreviewed',
    'confirmed',
    'false_positive'
);


ALTER TYPE "public"."review_status" OWNER TO "postgres";


CREATE TYPE "public"."safety_flag_type" AS ENUM (
    'bot_behavior',
    'fake_profile',
    'payment_fraud',
    'aggressive_messaging',
    'photo_manipulation',
    'location_spoofing'
);


ALTER TYPE "public"."safety_flag_type" OWNER TO "postgres";


CREATE TYPE "public"."swipe_action" AS ENUM (
    'like',
    'pass',
    'super_like',
    'rewind'
);


ALTER TYPE "public"."swipe_action" OWNER TO "postgres";


CREATE TYPE "public"."swipe_action_enum" AS ENUM (
    'like',
    'pass',
    'super_like',
    'rewind'
);


ALTER TYPE "public"."swipe_action_enum" OWNER TO "postgres";


CREATE TYPE "public"."verification_level" AS ENUM (
    'unverified',
    'liveness_only',
    'full_verified'
);


ALTER TYPE "public"."verification_level" OWNER TO "postgres";


CREATE TYPE "public"."verification_status" AS ENUM (
    'pending',
    'processing',
    'verified',
    'failed',
    'manual_review'
);


ALTER TYPE "public"."verification_status" OWNER TO "postgres";


CREATE TYPE "public"."verification_type" AS ENUM (
    'liveness',
    'gov_id'
);


ALTER TYPE "public"."verification_type" OWNER TO "postgres";


CREATE TYPE "public"."visibility_enum" AS ENUM (
    'everyone',
    'verified_only',
    'matches_only',
    'hidden'
);


ALTER TYPE "public"."visibility_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_profile_completeness"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  completeness int := 0;
BEGIN
  -- Mandatory: 70 points
  IF NEW.display_name IS NOT NULL THEN completeness := completeness + 10; END IF;
  IF NEW.birth_date IS NOT NULL THEN completeness := completeness + 10; END IF;
  IF NEW.gender IS NOT NULL THEN completeness := completeness + 10; END IF;
  
  -- Optional: 30 points
  IF NEW.bio IS NOT NULL AND length(trim(NEW.bio)) > 50 THEN completeness := completeness + 10; END IF;

  NEW.profile_completeness := least(completeness, 100);
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."calculate_profile_completeness"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_trust_score"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_profile_id UUID;
    liveness_passed BOOLEAN;
    id_passed BOOLEAN;
    new_score INTEGER := 0;
    new_level verification_level_enum := 'unverified';
BEGIN
    -- Determine which profile we are working on
    IF TG_TABLE_NAME = 'verifications' THEN
        target_profile_id := NEW.profile_id;
    ELSE
        target_profile_id := NEW.id;
    END IF;

    -- A. Check Liveness Status
    SELECT EXISTS (
        SELECT 1 FROM public.verifications 
        WHERE profile_id = target_profile_id 
        AND verification_type = 'liveness' 
        AND status = 'verified'
    ) INTO liveness_passed;

    -- B. Check Government ID Status
    SELECT EXISTS (
        SELECT 1 FROM public.verifications 
        WHERE profile_id = target_profile_id 
        AND verification_type = 'gov_id' 
        AND status = 'verified'
    ) INTO id_passed;

    -- C. Calculate Score Logic
    -- Base Score: 10 (Just for existing)
    new_score := 10;

    -- Logic: Liveness is good (+40), ID is best (+50)
    IF liveness_passed THEN
        new_score := new_score + 40; -- Total 50
        new_level := 'liveness_only';
    END IF;

    IF id_passed THEN
        new_score := new_score + 50; -- Total 60 (or 100 if both)
        new_level := 'full_verified';
    END IF;

    -- Cap at 100
    IF new_score > 100 THEN new_score := 100; END IF;

    -- D. Update the Profile automatically
    UPDATE public.profiles
    SET 
        trust_score = new_score,
        verification_level = new_level,
        is_verified = (new_score >= 50), -- Verified if at least liveness passed
        updated_at = CURRENT_TIMESTAMP
    WHERE id = target_profile_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."calculate_trust_score"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_user_account"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;


ALTER FUNCTION "public"."delete_user_account"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."expire_matches"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE matches
  SET status = 'expired'
  WHERE status = 'active'
    AND expires_at <= now();
END;
$$;


ALTER FUNCTION "public"."expire_matches"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."extend_match_expiry"("p_match_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_match RECORD;
BEGIN
  -- Fetch match
  SELECT *
  INTO v_match
  FROM matches
  WHERE id = p_match_id;

  -- Validation
  IF NOT FOUND THEN
    RAISE EXCEPTION 'MATCH_NOT_FOUND';
  END IF;

  IF v_match.status != 'active' THEN
    RAISE EXCEPTION 'MATCH_NOT_ACTIVE';
  END IF;

  IF v_match.expires_at < NOW() THEN
    RAISE EXCEPTION 'MATCH_ALREADY_EXPIRED';
  END IF;

  IF v_match.extension_count >= 3 THEN
    RAISE EXCEPTION 'EXTENSION_LIMIT_REACHED';
  END IF;

  -- Extend match
  UPDATE matches
  SET
    expires_at = expires_at + INTERVAL '24 hours',
    extension_count = extension_count + 1
  WHERE id = p_match_id;

END;
$$;


ALTER FUNCTION "public"."extend_match_expiry"("p_match_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_daily_expiry_rate"("p_date" "date") RETURNS json
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_total_matches int;
  v_expired_matches int;
BEGIN
  SELECT COUNT(*)
  INTO v_total_matches
  FROM matches
  WHERE created_at::date = p_date;

  SELECT COUNT(*)
  INTO v_expired_matches
  FROM matches
  WHERE status = 'expired'
    AND created_at::date = p_date;

  RETURN json_build_object(
    'date', p_date,
    'total_matches', v_total_matches,
    'expired_matches', v_expired_matches,
    'expiry_rate_percentage',
    CASE
      WHEN v_total_matches = 0 THEN 0
      ELSE ROUND((v_expired_matches::numeric / v_total_matches) * 100, 2)
    END
  );
END;
$$;


ALTER FUNCTION "public"."get_daily_expiry_rate"("p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_daily_match_analytics"("p_date" "date") RETURNS json
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN json_build_object(
    'match_rate', public.get_daily_match_rate(p_date),
    'expiry_rate', public.get_daily_expiry_rate(p_date),
    'unmatch_rate', public.get_daily_unmatch_rate(p_date)
  );
END;
$$;


ALTER FUNCTION "public"."get_daily_match_analytics"("p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_daily_match_rate"("p_date" "date") RETURNS json
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_likes_count int;
  v_matches_count int;
BEGIN
  -- Total likes on that day
  SELECT COUNT(*)
  INTO v_likes_count
  FROM swipes
  WHERE action_type = 'like'
    AND created_at::date = p_date;

  -- Matches created on that day
  SELECT COUNT(*)
  INTO v_matches_count
  FROM matches
  WHERE created_at::date = p_date;

  RETURN json_build_object(
    'date', p_date,
    'likes', v_likes_count,
    'matches', v_matches_count,
    'match_rate_percentage',
    CASE
      WHEN v_likes_count = 0 THEN 0
      ELSE ROUND((v_matches_count::numeric / v_likes_count) * 100, 2)
    END
  );
END;
$$;


ALTER FUNCTION "public"."get_daily_match_rate"("p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_daily_unmatch_rate"("p_date" "date") RETURNS json
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_total_matches int;
  v_unmatched int;
BEGIN
  SELECT COUNT(*)
  INTO v_total_matches
  FROM matches
  WHERE created_at::date = p_date;

  SELECT COUNT(*)
  INTO v_unmatched
  FROM matches
  WHERE status = 'unmatched'
    AND created_at::date = p_date;

  RETURN json_build_object(
    'date', p_date,
    'total_matches', v_total_matches,
    'unmatched', v_unmatched,
    'unmatch_rate_percentage',
    CASE
      WHEN v_total_matches = 0 THEN 0
      ELSE ROUND((v_unmatched::numeric / v_total_matches) * 100, 2)
    END
  );
END;
$$;


ALTER FUNCTION "public"."get_daily_unmatch_rate"("p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_discovery_feed_final"("p_radius_meters" double precision, "p_limit" integer, "p_offset" integer) RETURNS TABLE("profile_id" "uuid", "display_name" "text", "age" integer, "bio" "text", "city" "text", "distance_meters" double precision, "interest_match_count" integer, "lifestyle_match_count" integer, "match_score" integer, "image_url" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
DECLARE
  v_current_auth_id uuid;
  v_current_profile_id uuid;
  v_user_gender public.gender_enum;
  v_user_location geography(Point, 4326);
  v_user_interests uuid[] := '{}';
  v_user_lifestyles uuid[] := '{}';
BEGIN
  -- 1️⃣ Resolve auth user
  v_current_auth_id := auth.uid();

  -- 2️⃣ Resolve profile + preferences
  SELECT
    id,
    gender,
    passport_location_geom,
    COALESCE(selected_interest_ids, '{}'),
    COALESCE(selected_lifestyle_ids, '{}')
  INTO
    v_current_profile_id,
    v_user_gender,
    v_user_location,
    v_user_interests,
    v_user_lifestyles
  FROM public.profiles
  WHERE user_id = v_current_auth_id
    AND is_active = true
    AND is_deleted = false;

  -- Safety check
  IF v_current_profile_id IS NULL OR v_user_location IS NULL THEN
    RETURN;
  END IF;

  -- 3️⃣ Discovery feed
  RETURN QUERY
  SELECT
    p.id AS profile_id,
    p.display_name::text,
    EXTRACT(YEAR FROM AGE(p.birth_date))::int AS age,
    p.bio::text,
    p.city::text,

    ST_Distance(p.passport_location_geom, v_user_location) AS distance_meters,

    -- Interest matches
    cardinality(ARRAY(
      SELECT unnest(COALESCE(p.selected_interest_ids, '{}'))
      INTERSECT
      SELECT unnest(v_user_interests)
    )) AS interest_match_count,

    -- Lifestyle matches
    cardinality(ARRAY(
      SELECT unnest(COALESCE(p.selected_lifestyle_ids, '{}'))
      INTERSECT
      SELECT unnest(v_user_lifestyles)
    )) AS lifestyle_match_count,

    -- Match score
    (
      cardinality(ARRAY(
        SELECT unnest(COALESCE(p.selected_interest_ids, '{}'))
        INTERSECT
        SELECT unnest(v_user_interests)
      )) * 2
      +
      cardinality(ARRAY(
        SELECT unnest(COALESCE(p.selected_lifestyle_ids, '{}'))
        INTERSECT
        SELECT unnest(v_user_lifestyles)
      ))
    ) AS match_score,

    -- Primary profile image
    (
      SELECT um.media_url::text
      FROM public.user_media um
      WHERE um.profile_id = p.id
        AND um.media_type = 'photo'
        AND um.is_deleted = false
        AND um.moderation_status = 'approved'
        AND um.nsfw_detected = false
      ORDER BY um.is_primary DESC, um.display_order ASC
      LIMIT 1
    ) AS image_url

  FROM public.profiles p
  WHERE
    -- Basic validity
    p.id <> v_current_profile_id
    AND p.is_active = true
    AND p.is_deleted = false
    AND p.passport_location_geom IS NOT NULL

    -- 🚫 Exclude ONLY profiles I have already swiped
    AND p.id NOT IN (
      SELECT s.target_id
      FROM public.swipes s
      WHERE s.actor_id = v_current_profile_id
    )

    -- 🚫 Exclude matched / expired / unmatched users
    AND p.id NOT IN (
      SELECT
        CASE
          WHEN m.user_a_id = v_current_profile_id THEN m.user_b_id
          ELSE m.user_a_id
        END
      FROM public.matches m
      WHERE
        m.user_a_id = v_current_profile_id
        OR m.user_b_id = v_current_profile_id
    )

    -- Gender & distance rules
    AND v_user_gender IS NOT NULL
    AND p.gender IS NOT NULL
    AND p.gender <> v_user_gender
    AND ST_DWithin(
      p.passport_location_geom,
      v_user_location,
      p_radius_meters
    )

  ORDER BY
    match_score DESC,
    p.passport_location_geom <-> v_user_location,
    p.last_active DESC

  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_discovery_feed_final"("p_radius_meters" double precision, "p_limit" integer, "p_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_matches"() RETURNS TABLE("match_id" "uuid", "user_a_id" "uuid", "user_b_id" "uuid", "expires_at" timestamp with time zone, "status" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_profile_id uuid;
BEGIN
  SELECT id
  INTO v_profile_id
  FROM profiles
  WHERE user_id = auth.uid()
    AND is_active = true
    AND is_deleted = false
  LIMIT 1;

  IF v_profile_id IS NULL THEN
    RAISE EXCEPTION 'PROFILE_NOT_FOUND';
  END IF;

  RETURN QUERY
  SELECT
    m.id,
    m.user_a_id,
    m.user_b_id,
    m.expires_at,
    m.status::text,
    m.created_at
  FROM matches m
  WHERE
    (m.user_a_id = v_profile_id OR m.user_b_id = v_profile_id)
    AND m.status = 'active'
  ORDER BY m.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_my_matches"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_mutual_like"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_other_like_exists boolean;
BEGIN
  -- 1️⃣ Only care about likes & super likes
  IF NEW.action_type NOT IN ('like', 'super_like') THEN
    RETURN NEW;
  END IF;

  -- 2️⃣ 🚫 BLOCK REMATCH IF USERS UNMATCHED BEFORE
  IF EXISTS (
    SELECT 1
    FROM public.match_blocks
    WHERE user_a_id = LEAST(NEW.actor_id, NEW.target_id)
      AND user_b_id = GREATEST(NEW.actor_id, NEW.target_id)
  ) THEN
    -- 🚫 Do nothing, exit trigger
    RETURN NEW;
  END IF;

  -- 3️⃣ Check if the other user already liked this user
  SELECT EXISTS (
    SELECT 1
    FROM public.swipes s
    WHERE s.actor_id = NEW.target_id
      AND s.target_id = NEW.actor_id
      AND s.action_type IN ('like', 'super_like')
  )
  INTO v_other_like_exists;

  -- 4️⃣ If mutual like → create match
  IF v_other_like_exists THEN
    INSERT INTO public.matches (
      user_a_id,
      user_b_id,
      status,
      created_at,
      expires_at
    )
    VALUES (
      LEAST(NEW.actor_id, NEW.target_id),
      GREATEST(NEW.actor_id, NEW.target_id),
      'active',
      now(),
      now() + interval '24 hours'
    )
    ON CONFLICT DO NOTHING; -- 🔒 prevents duplicate matches
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_mutual_like"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."record_swipe"("p_target_profile_id" "uuid", "p_action_type" "text") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_actor_profile_id uuid;
  v_action_enum public.swipe_action_enum;
  v_today_like_count int := 0;
BEGIN
  -- Resolve actor profile
  SELECT id
  INTO v_actor_profile_id
  FROM public.profiles
  WHERE user_id = auth.uid()
    AND is_active = true
    AND is_deleted = false;

  IF v_actor_profile_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'code', 'PROFILE_NOT_FOUND'
    );
  END IF;

  -- Convert text → enum
  BEGIN
    v_action_enum := p_action_type::public.swipe_action_enum;
  EXCEPTION
    WHEN others THEN
      RETURN json_build_object(
        'success', false,
        'code', 'INVALID_ACTION_TYPE'
      );
  END;

  -- Daily like limit (10)
  IF v_action_enum = 'like' THEN
    SELECT COUNT(*)
    INTO v_today_like_count
    FROM public.swipes
    WHERE actor_id = v_actor_profile_id
      AND action_type = 'like'
      AND created_at >= date_trunc('day', now());

    IF v_today_like_count >= 10 THEN
      RETURN json_build_object(
        'success', false,
        'code', 'LIKE_LIMIT_REACHED'
      );
    END IF;
  END IF;

  -- Insert swipe
  INSERT INTO public.swipes (actor_id, target_id, action_type)
  VALUES (v_actor_profile_id, p_target_profile_id, v_action_enum)
  ON CONFLICT (actor_id, target_id) DO NOTHING;

  RETURN json_build_object(
    'success', true,
    'action', v_action_enum
  );
END;
$$;


ALTER FUNCTION "public"."record_swipe"("p_target_profile_id" "uuid", "p_action_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."undo_last_swipe"() RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_actor_profile_id uuid;
  v_is_premium boolean := false;
  v_last_swipe_id bigint;
BEGIN
  /* 1️⃣ Resolve actor profile + premium status */
  SELECT id, COALESCE(is_premium, false)
  INTO v_actor_profile_id, v_is_premium
  FROM public.profiles
  WHERE user_id = auth.uid()
    AND is_active = true
    AND is_deleted = false;

  IF v_actor_profile_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'code', 'PROFILE_NOT_FOUND'
    );
  END IF;

  /* 2️⃣ Premium check */
  IF v_is_premium = false THEN
    RETURN json_build_object(
      'success', false,
      'code', 'PREMIUM_REQUIRED'
    );
  END IF;

  /* 3️⃣ Find last swipe */
  SELECT id
  INTO v_last_swipe_id
  FROM public.swipes
  WHERE actor_id = v_actor_profile_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_last_swipe_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'code', 'NO_SWIPE_TO_UNDO'
    );
  END IF;

  /* 4️⃣ Delete last swipe */
  DELETE FROM public.swipes
  WHERE id = v_last_swipe_id;

  /* 5️⃣ Success */
  RETURN json_build_object(
    'success', true
  );
END;
$$;


ALTER FUNCTION "public"."undo_last_swipe"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."unmatch_users"("p_match_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  a uuid;
  b uuid;
begin
  -- 1. Get users from match
  select user_a_id, user_b_id
  into a, b
  from matches
  where id = p_match_id;

  -- 2. Mark match as unmatched
  update matches
  set status = 'unmatched'
  where id = p_match_id;

  -- 3. Permanently block future matches
  insert into match_blocks (user_a_id, user_b_id)
  values (least(a,b), greatest(a,b))
  on conflict do nothing;
end;
$$;


ALTER FUNCTION "public"."unmatch_users"("p_match_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_passport_location"("p_lat" double precision, "p_long" double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.profiles
  SET 
    -- Convert raw Lat/Long into a PostGIS Geography Point (SRID 4326 is the standard for GPS)
    passport_location_geom = ST_SetSRID(ST_MakePoint(p_long, p_lat), 4326),
    
    -- Also update 'last_active' so we know they are online
    last_active = CURRENT_TIMESTAMP
  WHERE 
    user_id = auth.uid(); -- Only updates the logged-in user
END;
$$;


ALTER FUNCTION "public"."update_passport_location"("p_lat" double precision, "p_long" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."daily_stats" (
    "id" bigint NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "swipe_count" integer DEFAULT 0,
    "super_like_count" integer DEFAULT 0,
    "rewind_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."daily_stats" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."daily_stats_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."daily_stats_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."daily_stats_id_seq" OWNED BY "public"."daily_stats"."id";



CREATE TABLE IF NOT EXISTS "public"."interest_chips" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "section" "text" NOT NULL,
    "label" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."interest_chips" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lifestyle_categories" (
    "id" smallint NOT NULL,
    "key" "text" NOT NULL,
    "is_multiselect" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."lifestyle_categories" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."lifestyle_categories_id_seq"
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."lifestyle_categories_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."lifestyle_categories_id_seq" OWNED BY "public"."lifestyle_categories"."id";



CREATE TABLE IF NOT EXISTS "public"."lifestyle_chips" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" smallint NOT NULL,
    "label" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."lifestyle_chips" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."match_blocks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_a_id" "uuid" NOT NULL,
    "user_b_id" "uuid" NOT NULL,
    "reason" "text" DEFAULT 'unmatched'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."match_blocks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."matches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_a_id" "uuid" NOT NULL,
    "user_b_id" "uuid" NOT NULL,
    "status" "public"."match_status_enum" DEFAULT 'active'::"public"."match_status_enum" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "extended_count" integer DEFAULT 0 NOT NULL,
    "extended_until" timestamp with time zone,
    "unmatched_by_user_id" "uuid",
    "unmatched_at" timestamp with time zone,
    "extension_count" integer DEFAULT 0,
    CONSTRAINT "different_users" CHECK (("user_a_id" <> "user_b_id"))
);


ALTER TABLE "public"."matches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."onboarding_steps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "step_key" "text" NOT NULL,
    "step_name" "text" NOT NULL,
    "step_position" integer NOT NULL,
    "is_mandatory" boolean DEFAULT false,
    "step_type" "text" NOT NULL,
    "estimated_time_seconds" integer DEFAULT 30,
    "max_skips_allowed" integer DEFAULT 0,
    "is_parallel" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."onboarding_steps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."otp_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "phone" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."otp_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_interest_chips" (
    "profile_id" "uuid" NOT NULL,
    "chip_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profile_interest_chips" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_lifestyle_chips" (
    "profile_id" "uuid" NOT NULL,
    "chip_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profile_lifestyle_chips" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_prompts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "prompt_template_id" "uuid" NOT NULL,
    "user_response" "text" NOT NULL,
    "prompt_display_order" integer DEFAULT 1,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "profile_prompts_display_order_chk" CHECK ((("prompt_display_order" >= 1) AND ("prompt_display_order" <= 3)))
);


ALTER TABLE "public"."profile_prompts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profile_views" (
    "id" bigint NOT NULL,
    "viewer_profile_id" "uuid" NOT NULL,
    "viewed_profile_id" "uuid" NOT NULL,
    "view_duration_seconds" integer,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."profile_views" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."profile_views_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."profile_views_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."profile_views_id_seq" OWNED BY "public"."profile_views"."id";



CREATE TABLE IF NOT EXISTS "public"."profile_visibility" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "visibility_setting" "public"."visibility_enum" DEFAULT 'everyone'::"public"."visibility_enum",
    "show_exact_distance" boolean DEFAULT false,
    "show_last_active" boolean DEFAULT false,
    "incognito_mode" boolean DEFAULT false,
    "incognito_hidden_user_ids" "uuid"[] DEFAULT '{}'::"uuid"[],
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."profile_visibility" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "display_name" character varying(100),
    "bio" "text",
    "birth_date" "date",
    "gender" "public"."gender_enum",
    "location_geom" "extensions"."geography"(Point,4326),
    "city" character varying(100),
    "state" character varying(100),
    "country" character varying(50) DEFAULT 'IN'::character varying,
    "trust_score" integer DEFAULT 0,
    "is_verified" boolean DEFAULT false,
    "verification_level" "public"."verification_level" DEFAULT 'unverified'::"public"."verification_level",
    "profile_completeness" integer DEFAULT 0,
    "last_active" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "is_active" boolean DEFAULT true,
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "onboarding_status" character varying(20) DEFAULT 'in_progress'::character varying,
    "steps_progress" "jsonb" DEFAULT '{}'::"jsonb",
    "languages_known" "text"[] DEFAULT ARRAY['en'::"text"],
    "passport_location_geom" "extensions"."geography"(Point,4326),
    "selected_lifestyle_ids" "uuid"[] DEFAULT '{}'::"uuid"[],
    "selected_interest_ids" "uuid"[] DEFAULT '{}'::"uuid"[],
    CONSTRAINT "profiles_trust_score_check" CHECK ((("trust_score" >= 0) AND ("trust_score" <= 100)))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."profiles"."languages_known" IS 'List of languages known by the user (e.g. {en, hi})';



CREATE TABLE IF NOT EXISTS "public"."prompt_categories" (
    "id" smallint NOT NULL,
    "key" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."prompt_categories" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."prompt_categories_id_seq"
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."prompt_categories_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."prompt_categories_id_seq" OWNED BY "public"."prompt_categories"."id";



CREATE TABLE IF NOT EXISTS "public"."prompt_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "prompt_text" "text" NOT NULL,
    "language" character varying(10) NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "category_id" smallint NOT NULL
);


ALTER TABLE "public"."prompt_templates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."safety_flags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "flag_type" "text" NOT NULL,
    "confidence_score" double precision DEFAULT 0.0,
    "details" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."safety_flags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."swipes" (
    "id" bigint NOT NULL,
    "actor_id" "uuid" NOT NULL,
    "target_id" "uuid" NOT NULL,
    "action_type" "public"."swipe_action_enum" NOT NULL,
    "device_fingerprint" character varying(255) DEFAULT NULL::character varying,
    "ip_address_hash" character varying(255) DEFAULT NULL::character varying,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."swipes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."swipes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."swipes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."swipes_id_seq" OWNED BY "public"."swipes"."id";



CREATE TABLE IF NOT EXISTS "public"."user_media" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "media_url" "text" NOT NULL,
    "media_type" character varying(20) NOT NULL,
    "display_order" integer NOT NULL,
    "is_primary" boolean DEFAULT false,
    "is_deleted" boolean DEFAULT false,
    "file_size_bytes" integer NOT NULL,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "moderation_status" "public"."moderation_status" DEFAULT 'pending'::"public"."moderation_status",
    "moderation_reason" "public"."moderation_reason_enum",
    "ai_labels" "jsonb" DEFAULT '{}'::"jsonb",
    "ai_confidence_score" numeric(3,2),
    "nsfw_detected" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "approved_at" timestamp with time zone,
    "duration_seconds" integer,
    "mime_type" "text",
    CONSTRAINT "user_media_media_type_check" CHECK ((("media_type")::"text" = ANY (ARRAY['photo'::"text", 'video_intro'::"text", 'voice_intro'::"text"]))),
    CONSTRAINT "user_media_voice_intro_duration_check" CHECK (((("media_type")::"text" <> 'voice_intro'::"text") OR (("duration_seconds" IS NOT NULL) AND (("duration_seconds" >= 1) AND ("duration_seconds" <= 60)))))
);


ALTER TABLE "public"."user_media" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."verifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "verification_type" "public"."verification_type" NOT NULL,
    "provider" character varying(50) DEFAULT 'aws_rekognition'::character varying,
    "attempt_number" integer NOT NULL,
    "status" "public"."verification_status" NOT NULL,
    "failure_reason" "text",
    "provider_request_id" character varying(255),
    "provider_response" "jsonb",
    "confidence_score" numeric(3,2),
    "selfie_video_url" "text",
    "id_document_url" "text",
    "review_notes" "text",
    "reviewed_by_admin_id" "uuid",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "verified_at" timestamp with time zone
);


ALTER TABLE "public"."verifications" OWNER TO "postgres";


ALTER TABLE ONLY "public"."daily_stats" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."daily_stats_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."lifestyle_categories" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."lifestyle_categories_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."profile_views" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."profile_views_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."prompt_categories" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."prompt_categories_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."swipes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."swipes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."daily_stats"
    ADD CONSTRAINT "daily_stats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interest_chips"
    ADD CONSTRAINT "interest_chips_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lifestyle_categories"
    ADD CONSTRAINT "lifestyle_categories_key_key" UNIQUE ("key");



ALTER TABLE ONLY "public"."lifestyle_categories"
    ADD CONSTRAINT "lifestyle_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lifestyle_chips"
    ADD CONSTRAINT "lifestyle_chips_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."match_blocks"
    ADD CONSTRAINT "match_blocks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."match_blocks"
    ADD CONSTRAINT "match_blocks_user_a_id_user_b_id_key" UNIQUE ("user_a_id", "user_b_id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."onboarding_steps"
    ADD CONSTRAINT "onboarding_steps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."onboarding_steps"
    ADD CONSTRAINT "onboarding_steps_step_key_key" UNIQUE ("step_key");



ALTER TABLE ONLY "public"."otp_logs"
    ADD CONSTRAINT "otp_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_interest_chips"
    ADD CONSTRAINT "profile_interest_chips_pkey" PRIMARY KEY ("profile_id", "chip_id");



ALTER TABLE ONLY "public"."profile_lifestyle_chips"
    ADD CONSTRAINT "profile_lifestyle_chips_pkey" PRIMARY KEY ("profile_id", "chip_id");



ALTER TABLE ONLY "public"."profile_prompts"
    ADD CONSTRAINT "profile_prompts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_visibility"
    ADD CONSTRAINT "profile_visibility_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_visibility"
    ADD CONSTRAINT "profile_visibility_profile_id_key" UNIQUE ("profile_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."prompt_categories"
    ADD CONSTRAINT "prompt_categories_key_key" UNIQUE ("key");



ALTER TABLE ONLY "public"."prompt_categories"
    ADD CONSTRAINT "prompt_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."prompt_templates"
    ADD CONSTRAINT "prompt_templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."safety_flags"
    ADD CONSTRAINT "safety_flags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."swipes"
    ADD CONSTRAINT "swipes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."swipes"
    ADD CONSTRAINT "unique_swipe_per_actor_target" UNIQUE ("actor_id", "target_id");



ALTER TABLE ONLY "public"."interest_chips"
    ADD CONSTRAINT "uq_interest" UNIQUE ("section", "label");



ALTER TABLE ONLY "public"."lifestyle_chips"
    ADD CONSTRAINT "uq_lifestyle" UNIQUE ("category_id", "label");



ALTER TABLE ONLY "public"."user_media"
    ADD CONSTRAINT "user_media_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."verifications"
    ADD CONSTRAINT "verifications_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_daily_stats_date" ON "public"."daily_stats" USING "btree" ("date");



CREATE UNIQUE INDEX "idx_daily_stats_profile_date" ON "public"."daily_stats" USING "btree" ("profile_id", "date");



CREATE INDEX "idx_profile_interest_chip" ON "public"."profile_interest_chips" USING "btree" ("chip_id");



CREATE INDEX "idx_profile_interest_profile" ON "public"."profile_interest_chips" USING "btree" ("profile_id");



CREATE INDEX "idx_profile_lifestyle_chip" ON "public"."profile_lifestyle_chips" USING "btree" ("chip_id");



CREATE INDEX "idx_profile_lifestyle_profile" ON "public"."profile_lifestyle_chips" USING "btree" ("profile_id");



CREATE INDEX "idx_profile_prompts_profile_id" ON "public"."profile_prompts" USING "btree" ("profile_id");



CREATE INDEX "idx_profile_views_created_at" ON "public"."profile_views" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_profile_views_viewed_profile" ON "public"."profile_views" USING "btree" ("viewed_profile_id", "created_at" DESC);



CREATE INDEX "idx_profiles_city_state" ON "public"."profiles" USING "btree" ("city", "state");



CREATE INDEX "idx_profiles_created_at" ON "public"."profiles" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_profiles_interest_ids" ON "public"."profiles" USING "gin" ("selected_interest_ids");



CREATE INDEX "idx_profiles_is_verified" ON "public"."profiles" USING "btree" ("is_verified") WHERE ("is_active" = true);



CREATE INDEX "idx_profiles_last_active" ON "public"."profiles" USING "btree" ("last_active" DESC);



CREATE INDEX "idx_profiles_lifestyle_ids" ON "public"."profiles" USING "gin" ("selected_lifestyle_ids");



CREATE INDEX "idx_profiles_location" ON "public"."profiles" USING "gist" ("location_geom");



CREATE INDEX "idx_profiles_passport_location" ON "public"."profiles" USING "gist" ("passport_location_geom");



CREATE INDEX "idx_profiles_trust_score" ON "public"."profiles" USING "btree" ("trust_score" DESC) WHERE ("is_active" = true);



CREATE INDEX "idx_profiles_user_id" ON "public"."profiles" USING "btree" ("user_id");



CREATE INDEX "idx_prompt_templates_category_id" ON "public"."prompt_templates" USING "btree" ("category_id");



CREATE INDEX "idx_prompt_templates_language" ON "public"."prompt_templates" USING "btree" ("language");



CREATE INDEX "idx_safety_flags_user" ON "public"."safety_flags" USING "btree" ("user_id");



CREATE INDEX "idx_swipes_action_type" ON "public"."swipes" USING "btree" ("action_type");



CREATE INDEX "idx_swipes_actor_created_at" ON "public"."swipes" USING "btree" ("actor_id", "created_at" DESC);



CREATE INDEX "idx_swipes_actor_target" ON "public"."swipes" USING "btree" ("actor_id", "target_id");



CREATE INDEX "idx_swipes_target_created_at" ON "public"."swipes" USING "btree" ("target_id", "created_at" DESC);



CREATE INDEX "idx_user_media_display_order" ON "public"."user_media" USING "btree" ("profile_id", "display_order");



CREATE INDEX "idx_user_media_nsfw" ON "public"."user_media" USING "btree" ("nsfw_detected") WHERE ("nsfw_detected" = true);



CREATE INDEX "idx_user_media_profile_id" ON "public"."user_media" USING "btree" ("profile_id");



CREATE INDEX "idx_user_media_status" ON "public"."user_media" USING "btree" ("moderation_status") WHERE ("moderation_status" = ANY (ARRAY['pending'::"public"."moderation_status", 'appeal'::"public"."moderation_status"]));



CREATE INDEX "idx_verifications_created_at" ON "public"."verifications" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_verifications_profile_id" ON "public"."verifications" USING "btree" ("profile_id");



CREATE INDEX "idx_verifications_status" ON "public"."verifications" USING "btree" ("status");



CREATE INDEX "idx_verifications_type_status" ON "public"."verifications" USING "btree" ("verification_type", "status");



CREATE INDEX "matches_expires_at_idx" ON "public"."matches" USING "btree" ("expires_at");



CREATE INDEX "matches_status_idx" ON "public"."matches" USING "btree" ("status");



CREATE INDEX "matches_user_a_idx" ON "public"."matches" USING "btree" ("user_a_id");



CREATE INDEX "matches_user_b_idx" ON "public"."matches" USING "btree" ("user_b_id");



CREATE UNIQUE INDEX "unique_match_pair" ON "public"."matches" USING "btree" (LEAST("user_a_id", "user_b_id"), GREATEST("user_a_id", "user_b_id"));



CREATE UNIQUE INDEX "uq_profile_prompt_order" ON "public"."profile_prompts" USING "btree" ("profile_id", "prompt_display_order");



CREATE UNIQUE INDEX "uq_profile_prompt_template" ON "public"."profile_prompts" USING "btree" ("profile_id", "prompt_template_id");



CREATE UNIQUE INDEX "uq_prompt_templates_lang_text" ON "public"."prompt_templates" USING "btree" ("language", "prompt_text");



CREATE OR REPLACE TRIGGER "profiles_completeness_trigger" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."calculate_profile_completeness"();



CREATE OR REPLACE TRIGGER "trigger_handle_mutual_like" AFTER INSERT ON "public"."swipes" FOR EACH ROW EXECUTE FUNCTION "public"."handle_mutual_like"();



ALTER TABLE ONLY "public"."daily_stats"
    ADD CONSTRAINT "daily_stats_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lifestyle_chips"
    ADD CONSTRAINT "lifestyle_chips_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."lifestyle_categories"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."match_blocks"
    ADD CONSTRAINT "match_blocks_user_a_id_fkey" FOREIGN KEY ("user_a_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."match_blocks"
    ADD CONSTRAINT "match_blocks_user_b_id_fkey" FOREIGN KEY ("user_b_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_unmatched_by_user_id_fkey" FOREIGN KEY ("unmatched_by_user_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_user_a_id_fkey" FOREIGN KEY ("user_a_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_user_b_id_fkey" FOREIGN KEY ("user_b_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_interest_chips"
    ADD CONSTRAINT "profile_interest_chips_chip_id_fkey" FOREIGN KEY ("chip_id") REFERENCES "public"."interest_chips"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."profile_interest_chips"
    ADD CONSTRAINT "profile_interest_chips_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_lifestyle_chips"
    ADD CONSTRAINT "profile_lifestyle_chips_chip_id_fkey" FOREIGN KEY ("chip_id") REFERENCES "public"."lifestyle_chips"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."profile_lifestyle_chips"
    ADD CONSTRAINT "profile_lifestyle_chips_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_prompts"
    ADD CONSTRAINT "profile_prompts_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_prompts"
    ADD CONSTRAINT "profile_prompts_prompt_template_id_fkey" FOREIGN KEY ("prompt_template_id") REFERENCES "public"."prompt_templates"("id");



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_viewed_profile_id_fkey" FOREIGN KEY ("viewed_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_views"
    ADD CONSTRAINT "profile_views_viewer_profile_id_fkey" FOREIGN KEY ("viewer_profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile_visibility"
    ADD CONSTRAINT "profile_visibility_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."prompt_templates"
    ADD CONSTRAINT "prompt_templates_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."prompt_categories"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."safety_flags"
    ADD CONSTRAINT "safety_flags_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."swipes"
    ADD CONSTRAINT "swipes_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."swipes"
    ADD CONSTRAINT "swipes_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_media"
    ADD CONSTRAINT "user_media_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."verifications"
    ADD CONSTRAINT "verifications_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Allow public read access to onboarding_steps" ON "public"."onboarding_steps" FOR SELECT USING (true);



CREATE POLICY "Block incomplete profiles from discovery" ON "public"."profiles" FOR SELECT USING ((("auth"."uid"() = "id") OR ((("onboarding_status")::"text" = 'complete'::"text") AND ("profile_completeness" >= 60))));



CREATE POLICY "Enable read access for everyone" ON "public"."otp_logs" FOR SELECT USING (true);



CREATE POLICY "Public read access" ON "public"."prompt_categories" FOR SELECT USING (true);



CREATE POLICY "Public read access" ON "public"."prompt_templates" FOR SELECT USING (true);



CREATE POLICY "Service Role Full Access" ON "public"."otp_logs" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Users can delete their own media" ON "public"."user_media" FOR DELETE USING (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can insert their own media" ON "public"."user_media" FOR INSERT WITH CHECK (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own verifications" ON "public"."verifications" FOR INSERT TO "authenticated" WITH CHECK (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can read their own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can select their own media" ON "public"."user_media" FOR SELECT USING (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can update their own media" ON "public"."user_media" FOR UPDATE USING (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users manage own prompts" ON "public"."profile_prompts" USING (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users view own stats" ON "public"."daily_stats" FOR SELECT USING (("profile_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users view own swipes" ON "public"."swipes" FOR SELECT USING (("actor_id" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."user_id" = "auth"."uid"()))));



ALTER TABLE "public"."daily_stats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."matches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."onboarding_steps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."otp_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_prompts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_views" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_visibility" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."prompt_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."prompt_templates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."safety_flags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."swipes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."verifications" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";









GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";







































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































GRANT ALL ON FUNCTION "public"."calculate_profile_completeness"() TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_profile_completeness"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_profile_completeness"() TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_trust_score"() TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_trust_score"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_trust_score"() TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_matches"() TO "anon";
GRANT ALL ON FUNCTION "public"."expire_matches"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."expire_matches"() TO "service_role";



GRANT ALL ON FUNCTION "public"."extend_match_expiry"("p_match_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."extend_match_expiry"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."extend_match_expiry"("p_match_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_daily_expiry_rate"("p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_expiry_rate"("p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_expiry_rate"("p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_daily_match_analytics"("p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_match_analytics"("p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_match_analytics"("p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_daily_match_rate"("p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_match_rate"("p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_match_rate"("p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_daily_unmatch_rate"("p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_unmatch_rate"("p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_unmatch_rate"("p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_discovery_feed_final"("p_radius_meters" double precision, "p_limit" integer, "p_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_discovery_feed_final"("p_radius_meters" double precision, "p_limit" integer, "p_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_discovery_feed_final"("p_radius_meters" double precision, "p_limit" integer, "p_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_matches"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_matches"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_matches"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_mutual_like"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_mutual_like"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_mutual_like"() TO "service_role";



GRANT ALL ON FUNCTION "public"."record_swipe"("p_target_profile_id" "uuid", "p_action_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."record_swipe"("p_target_profile_id" "uuid", "p_action_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."record_swipe"("p_target_profile_id" "uuid", "p_action_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."undo_last_swipe"() TO "anon";
GRANT ALL ON FUNCTION "public"."undo_last_swipe"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."undo_last_swipe"() TO "service_role";



GRANT ALL ON FUNCTION "public"."unmatch_users"("p_match_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."unmatch_users"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unmatch_users"("p_match_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_passport_location"("p_lat" double precision, "p_long" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."update_passport_location"("p_lat" double precision, "p_long" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_passport_location"("p_lat" double precision, "p_long" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";























































































GRANT ALL ON TABLE "public"."daily_stats" TO "anon";
GRANT ALL ON TABLE "public"."daily_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."daily_stats" TO "service_role";



GRANT ALL ON SEQUENCE "public"."daily_stats_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."daily_stats_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."daily_stats_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."interest_chips" TO "anon";
GRANT ALL ON TABLE "public"."interest_chips" TO "authenticated";
GRANT ALL ON TABLE "public"."interest_chips" TO "service_role";



GRANT ALL ON TABLE "public"."lifestyle_categories" TO "anon";
GRANT ALL ON TABLE "public"."lifestyle_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."lifestyle_categories" TO "service_role";



GRANT ALL ON SEQUENCE "public"."lifestyle_categories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."lifestyle_categories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."lifestyle_categories_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."lifestyle_chips" TO "anon";
GRANT ALL ON TABLE "public"."lifestyle_chips" TO "authenticated";
GRANT ALL ON TABLE "public"."lifestyle_chips" TO "service_role";



GRANT ALL ON TABLE "public"."match_blocks" TO "anon";
GRANT ALL ON TABLE "public"."match_blocks" TO "authenticated";
GRANT ALL ON TABLE "public"."match_blocks" TO "service_role";



GRANT ALL ON TABLE "public"."matches" TO "anon";
GRANT ALL ON TABLE "public"."matches" TO "authenticated";
GRANT ALL ON TABLE "public"."matches" TO "service_role";



GRANT ALL ON TABLE "public"."onboarding_steps" TO "anon";
GRANT ALL ON TABLE "public"."onboarding_steps" TO "authenticated";
GRANT ALL ON TABLE "public"."onboarding_steps" TO "service_role";



GRANT ALL ON TABLE "public"."otp_logs" TO "anon";
GRANT ALL ON TABLE "public"."otp_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."otp_logs" TO "service_role";



GRANT ALL ON TABLE "public"."profile_interest_chips" TO "anon";
GRANT ALL ON TABLE "public"."profile_interest_chips" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_interest_chips" TO "service_role";



GRANT ALL ON TABLE "public"."profile_lifestyle_chips" TO "anon";
GRANT ALL ON TABLE "public"."profile_lifestyle_chips" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_lifestyle_chips" TO "service_role";



GRANT ALL ON TABLE "public"."profile_prompts" TO "anon";
GRANT ALL ON TABLE "public"."profile_prompts" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_prompts" TO "service_role";



GRANT ALL ON TABLE "public"."profile_views" TO "anon";
GRANT ALL ON TABLE "public"."profile_views" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_views" TO "service_role";



GRANT ALL ON SEQUENCE "public"."profile_views_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."profile_views_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."profile_views_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."profile_visibility" TO "anon";
GRANT ALL ON TABLE "public"."profile_visibility" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_visibility" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."prompt_categories" TO "anon";
GRANT ALL ON TABLE "public"."prompt_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."prompt_categories" TO "service_role";



GRANT ALL ON SEQUENCE "public"."prompt_categories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."prompt_categories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."prompt_categories_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."prompt_templates" TO "anon";
GRANT ALL ON TABLE "public"."prompt_templates" TO "authenticated";
GRANT ALL ON TABLE "public"."prompt_templates" TO "service_role";



GRANT ALL ON TABLE "public"."safety_flags" TO "anon";
GRANT ALL ON TABLE "public"."safety_flags" TO "authenticated";
GRANT ALL ON TABLE "public"."safety_flags" TO "service_role";



GRANT ALL ON TABLE "public"."swipes" TO "anon";
GRANT ALL ON TABLE "public"."swipes" TO "authenticated";
GRANT ALL ON TABLE "public"."swipes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."swipes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."swipes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."swipes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_media" TO "anon";
GRANT ALL ON TABLE "public"."user_media" TO "authenticated";
GRANT ALL ON TABLE "public"."user_media" TO "service_role";



GRANT ALL ON TABLE "public"."verifications" TO "anon";
GRANT ALL ON TABLE "public"."verifications" TO "authenticated";
GRANT ALL ON TABLE "public"."verifications" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































