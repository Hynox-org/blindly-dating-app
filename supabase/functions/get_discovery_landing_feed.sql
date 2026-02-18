-- ==============================================================================
-- 🔎 DISCOVERY LANDING FEED (CATEGORIZED USERS)
-- Description: Fetches users for 'Discovery Page' categories (Nearby, New, Active)
-- Optimized for:
--  1. Mode Handling (Date vs BFF)
--  2. Profile Image Selection (Context-aware)
--  3. Exclusion Logic (Swiped users + Users who liked me)
--  4. Randomization
-- ==============================================================================

CREATE OR REPLACE FUNCTION get_discovery_landing_feed(
  current_lat float8,
  current_long float8,
  radius_km int DEFAULT 100,
  limit_per_category int DEFAULT 10,
  p_mode_override text DEFAULT NULL -- New parameter for override
)
RETURNS JSON AS $$
DECLARE
  nearby_users JSON;
  new_faces_users JSON;
  active_users JSON;
  wanderlust_users JSON;
  
  my_profile_id uuid;
  my_user_id uuid;
  current_point geography;
  my_gender_text text;
  my_gender_enum public.gender_enum;
  my_mode_text text;
  my_mode_enum public.profile_mode_enum;
  target_genders public.gender_enum[];
  
  -- We'll use arrays to track IDs to avoid duplicates across categories
  excluded_ids uuid[];
BEGIN

  -- 1. Get My Context (Profile ID, Location, Gender, Current Mode)
  my_user_id := auth.uid();

  SELECT 
    p.id,
    p.gender::text, 
    p.current_mode,
    ST_SetSRID(ST_MakePoint(current_long, current_lat), 4326)::geography
  INTO 
    my_profile_id,
    my_gender_text,
    my_mode_text,
    current_point
  FROM public.profiles p
  WHERE p.user_id = my_user_id;

  -- Prioritize Override
  IF p_mode_override IS NOT NULL THEN
    my_mode_text := LOWER(p_mode_override);
  END IF;

  -- Normalize mode
  BEGIN
    my_mode_enum := my_mode_text::public.profile_mode_enum;
  EXCEPTION WHEN OTHERS THEN
    my_mode_enum := 'date'::public.profile_mode_enum;
  END;
  
  -- Normalize gender
  BEGIN
    my_gender_enum := my_gender_text::public.gender_enum;
  EXCEPTION WHEN OTHERS THEN
    my_gender_enum := 'M'::public.gender_enum; 
  END;

  -- 2. Determine Target Genders
  IF my_mode_enum = 'date'::public.profile_mode_enum THEN
      IF my_gender_enum = 'M'::public.gender_enum THEN 
          target_genders := ARRAY['F']::public.gender_enum[]; 
      ELSIF my_gender_enum = 'F'::public.gender_enum THEN 
          target_genders := ARRAY['M']::public.gender_enum[];
      ELSE 
          target_genders := ARRAY['M', 'F', 'NB', 'Prefer Not']::public.gender_enum[]; 
      END IF;
      
  ELSIF my_mode_enum = 'bff'::public.profile_mode_enum THEN
      -- BFF: Same gender
      target_genders := ARRAY[my_gender_enum]::public.gender_enum[];
      
  ELSE
      -- Biz or other: Open to all
      target_genders := ARRAY['M', 'F', 'NB', 'Prefer Not']::public.gender_enum[];
  END IF;


  -- 3. BUILD EXCLUSION LIST
  -- Exclude:
  --  a) Me (always)
  --  b) Users I have swiped on (pass OR like)
  --  c) Users who have LIKED me (as per requirement: "ignore the profiles that they liked me")
  --     (Note: If they passed me, I can still see them to potentially like them)
  
  SELECT ARRAY_AGG(DISTINCT target_uuid)
  INTO excluded_ids
  FROM (
      -- Me
      SELECT my_user_id AS target_uuid
      
      UNION ALL
      
      -- Users I swiped on (I am actor)
      SELECT p.user_id 
      FROM swipes s
      JOIN profiles p ON s.target_id = p.id
      WHERE s.actor_id = my_profile_id
      
      UNION ALL
      
      -- Users who LIKED me (I am target, Action is LIKE)
      SELECT p.user_id
      FROM swipes s
      JOIN profiles p ON s.actor_id = p.id
      WHERE s.target_id = my_profile_id AND s.action_type = 'like'
  ) all_exclusions;
  
  -- Ensure not null for array operations
  IF excluded_ids IS NULL THEN
      excluded_ids := ARRAY[my_user_id];
  END IF;


  -- 4. NEARBY (Priority 1)
  -- Logic: Within Radius -> Random Order
  WITH nearby_cte AS (
    SELECT
      p.id as profile_id,
      p.user_id,
      p.display_name,
      EXTRACT(YEAR FROM AGE(p.birth_date))::int as age,
      (ST_Distance(p.passport_location_geom, current_point) / 1000) as distance_km,
      pm.bio,
      
      -- Image Fetching: From profile_mode_media linked to the selected pm
      COALESCE(
        (
          SELECT json_agg(pmm.media_url ORDER BY pmm.is_primary DESC, pmm.display_order ASC)
          FROM profile_mode_media pmm
          WHERE pmm.profile_mode_id = pm.id
            AND pmm.media_type = 'photo'
            AND pmm.is_deleted = false
        ),
        '[]'::json
      ) as image_urls,
      
      p.gender,
      p.work_title,
      p.hometown_city as hometown,
      p.height_cm as height
    FROM profiles p
    -- Fetch the BEST active profile mode for display
    -- Priority: 1. Matching Mode (e.g. they align with my Date/BFF intent), 2. Default Date, 3. Any
    LEFT JOIN LATERAL (
      SELECT id, bio, mode
      FROM profile_modes m
      WHERE m.profile_id = p.id AND m.is_active = true
      ORDER BY 
        (CASE WHEN m.mode = my_mode_enum THEN 1 WHEN m.mode = 'date'::public.profile_mode_enum THEN 2 ELSE 3 END) ASC
      LIMIT 1
    ) pm ON true
    WHERE
      (ST_Distance(p.passport_location_geom, current_point) / 1000) <= radius_km
      AND p.user_id != ALL(excluded_ids)
      AND p.is_active = true
      AND p.is_deleted = false
      AND pm.id IS NOT NULL 
      AND p.gender = ANY(target_genders)
    ORDER BY RANDOM() -- Randomize results
    LIMIT limit_per_category
  )
  SELECT 
    json_agg(t), 
    array_agg(t.user_id) 
  INTO nearby_users, excluded_ids
  FROM nearby_cte t;
  
  -- Update excluded IDs manually since SELECT INTO replaced it
  IF excluded_ids IS NULL THEN
     -- Recover base context if no nearby users found
      SELECT ARRAY_AGG(DISTINCT target_uuid)
      INTO excluded_ids
      FROM (
          SELECT my_user_id AS target_uuid
          UNION ALL
          SELECT p.user_id FROM swipes s JOIN profiles p ON s.target_id = p.id WHERE s.actor_id = my_profile_id
          UNION ALL
          SELECT p.user_id FROM swipes s JOIN profiles p ON s.actor_id = p.id WHERE s.target_id = my_profile_id AND s.action_type = 'like'
      ) all_exclusions;
  ELSE
      -- Append base context back to the nearby results
      SELECT ARRAY_AGG(DISTINCT id) INTO excluded_ids FROM (
          SELECT unnest(excluded_ids) as id
          UNION ALL
          SELECT my_user_id
          UNION ALL
          SELECT p.user_id FROM swipes s JOIN profiles p ON s.target_id = p.id WHERE s.actor_id = my_profile_id
          UNION ALL
          SELECT p.user_id FROM swipes s JOIN profiles p ON s.actor_id = p.id WHERE s.target_id = my_profile_id AND s.action_type = 'like'
      ) sub;
  END IF;


  -- 5. NEW FACES (Priority 2)
  -- Logic: Created recently -> then Random among those
  WITH new_faces_cte AS (
    SELECT
      p.id as profile_id,
      p.user_id,
      p.display_name,
      EXTRACT(YEAR FROM AGE(p.birth_date))::int as age,
      (ST_Distance(p.passport_location_geom, current_point) / 1000) as distance_km,
      pm.bio,
       COALESCE(
        (
          SELECT json_agg(pmm.media_url ORDER BY pmm.is_primary DESC, pmm.display_order ASC)
          FROM profile_mode_media pmm
          WHERE pmm.profile_mode_id = pm.id
            AND pmm.media_type = 'photo'
            AND pmm.is_deleted = false
        ),
        '[]'::json
      ) as image_urls,
      p.gender,
      p.work_title
    FROM profiles p
    LEFT JOIN LATERAL (
      SELECT id, bio, mode
      FROM profile_modes m
      WHERE m.profile_id = p.id AND m.is_active = true
      ORDER BY 
        (CASE WHEN m.mode = my_mode_enum THEN 1 WHEN m.mode = 'date'::public.profile_mode_enum THEN 2 ELSE 3 END) ASC
      LIMIT 1
    ) pm ON true
    WHERE
      p.created_at > (NOW() - INTERVAL '30 days')
      AND (ST_Distance(p.passport_location_geom, current_point) / 1000) <= (radius_km * 2)
      AND p.user_id != ALL(excluded_ids)
      AND p.is_active = true
      AND p.is_deleted = false
      AND pm.id IS NOT NULL
      AND p.gender = ANY(target_genders)
    ORDER BY p.created_at DESC, RANDOM() -- Newest first, but randomize ties/close calls
    LIMIT limit_per_category
  )
  SELECT 
    json_agg(t),
    (SELECT array_agg(id) FROM (SELECT unnest(excluded_ids) as id UNION ALL SELECT user_id FROM new_faces_cte) as sub)
  INTO new_faces_users, excluded_ids
  FROM new_faces_cte t;

  -- 6. RECENTLY ACTIVE (Priority 3)
  -- Logic: Actually active -> Random
  WITH active_cte AS (
    SELECT
      p.id as profile_id,
      p.display_name,
      EXTRACT(YEAR FROM AGE(p.birth_date))::int as age,
      (ST_Distance(p.passport_location_geom, current_point) / 1000) as distance_km,
      pm.bio,
       COALESCE(
        (
          SELECT json_agg(pmm.media_url ORDER BY pmm.is_primary DESC, pmm.display_order ASC)
          FROM profile_mode_media pmm
          WHERE pmm.profile_mode_id = pm.id
             AND pmm.media_type = 'photo'
             AND pmm.is_deleted = false
        ),
        '[]'::json
      ) as image_urls
    FROM profiles p
    LEFT JOIN LATERAL (
      SELECT id, bio, mode
      FROM profile_modes m
      WHERE m.profile_id = p.id AND m.is_active = true
      ORDER BY 
        (CASE WHEN m.mode = my_mode_enum THEN 1 WHEN m.mode = 'date'::public.profile_mode_enum THEN 2 ELSE 3 END) ASC
      LIMIT 1
    ) pm ON true
    WHERE
      p.user_id != ALL(excluded_ids)
      AND p.is_active = true
      AND p.is_deleted = false
      AND pm.id IS NOT NULL
      AND p.gender = ANY(target_genders) -- GENDER FILTER ONLY
      AND (ST_Distance(p.passport_location_geom, current_point) / 1000) <= radius_km
    ORDER BY p.last_active DESC, RANDOM()
    LIMIT limit_per_category
  )
  SELECT json_agg(t) INTO active_users FROM active_cte t;

  -- 7. WANDERLUST (Placeholder)
  wanderlust_users := '[]'::json;

  RETURN json_build_object(
    'nearby', COALESCE(nearby_users, '[]'::json),
    'new_faces', COALESCE(new_faces_users, '[]'::json),
    'recently_active', COALESCE(active_users, '[]'::json),
    'wanderlust', wanderlust_users
  );

END;
$$ LANGUAGE plpgsql;
