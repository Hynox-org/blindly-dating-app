CREATE OR REPLACE FUNCTION get_discovery_feed_v3(
  p_mode text,
  p_radius_meters int,
  p_limit int,
  p_offset int,
  p_looking_for text[]
)
RETURNS TABLE (
  profile_id uuid,
  display_name text,
  age int,
  bio text,
  gender text,
  city text,
  distance_meters float,
  match_score int,
  interest_match_count int,
  lifestyle_match_count int,
  media_url text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_current_auth_id uuid;
  v_current_profile_id uuid;
  v_my_lat float;
  v_my_long float;
  v_my_loc geometry;
BEGIN
  -- 1. Resolve Current User Data
  v_current_auth_id := auth.uid();
  
  SELECT 
    id,
    COALESCE(location_geom, passport_location_geom)
  INTO 
    v_current_profile_id,
    v_my_loc
  FROM profiles
  WHERE user_id = v_current_auth_id;

  -- 2. Return Query
  RETURN QUERY
  SELECT
    p.id as profile_id,
    p.display_name::text,
    EXTRACT(YEAR FROM age(p.birth_date))::int as age,
    pm.bio::text,
    p.gender::text,
    p.city::text,
    
    -- Distance
    CASE 
      WHEN v_my_loc IS NOT NULL AND p.location_geom IS NOT NULL 
      THEN ST_Distance(p.location_geom, v_my_loc) 
      ELSE 0 
    END as distance_meters,

    -- Match Score (Placeholders for now as columns don't exist in profiles)
    0 as match_score,
    0 as interest_match_count,
    0 as lifestyle_match_count,

    -- Safe Image Selection (Moderated)
    (
      SELECT um.media_url::text
      FROM user_media um 
      WHERE um.profile_id = p.id 
        AND um.is_primary = true 
        AND um.moderation_status = 'approved'
        AND um.nsfw_detected = false
      LIMIT 1
    ) as media_url

  FROM profiles p
  JOIN profile_modes pm ON pm.profile_id = p.id
  WHERE
    -- Not Me
    p.user_id != v_current_auth_id
    
    -- Mode Filter
    AND pm.mode = p_mode::profile_mode_enum
    AND pm.is_active = true

    -- Dynamic Gender Filter
    AND p.gender::text = ANY(p_looking_for)
    
    -- Exclude Swiped
    AND NOT EXISTS (
      SELECT 1 FROM swipes s
      WHERE s.actor_id = v_current_profile_id
      AND s.target_id = p.id
    )

    -- Exclude Matched
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

    -- Distance Filter
    AND (
      v_my_loc IS NULL 
      OR p.location_geom IS NULL 
      OR ST_DWithin(p.location_geom, v_my_loc, p_radius_meters)
    )

  ORDER BY 
    distance_meters ASC
  LIMIT p_limit OFFSET p_offset;
END;
$$;
