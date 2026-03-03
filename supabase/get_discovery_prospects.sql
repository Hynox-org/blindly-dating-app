CREATE OR REPLACE FUNCTION get_discovery_prospects(
  search_mode text,
  radius_km int,
  limit_count int,
  offset_count int
)
RETURNS TABLE (
  profile_id uuid,
  display_name text,
  age int,
  distance_km float,
  bio text,
  mode_id uuid,
  image_urls text[],
  gender text,
  work_title text,
  hometown_city text,
  prompts json,
  looking_for text[],
  is_verified boolean,
  verification_level text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  my_geom geometry;
  my_birth_date date;
  my_gender public.gender_enum;
  my_profile_id uuid;
  target_genders public.gender_enum[];
BEGIN
  -- ============================================================
  -- STEP 1: GET MY CONTEXT
  -- ============================================================
  SELECT 
    me.id, 
    me.birth_date, 
    me.gender, 
    COALESCE(me.passport_location_geom, me.location_geom) 
  INTO 
    my_profile_id, 
    my_birth_date, 
    my_gender, 
    my_geom
  FROM public.profiles AS me 
  WHERE me.user_id = auth.uid();

  -- Safety Check
  IF my_geom IS NULL THEN
    RETURN;
  END IF;

  -- ============================================================
  -- STEP 2: AUTO-CALCULATE GENDER PREFERENCE
  -- ============================================================
  IF my_gender IN ('NB', 'Prefer Not') THEN
      target_genders := ARRAY['M', 'F', 'NB', 'Prefer Not']::public.gender_enum[];
  ELSIF search_mode = 'date' THEN
      IF my_gender = 'M' THEN target_genders := ARRAY['F']::public.gender_enum[]; END IF;
      IF my_gender = 'F' THEN target_genders := ARRAY['M']::public.gender_enum[]; END IF;
  ELSIF search_mode = 'bff' THEN
      IF my_gender = 'M' THEN target_genders := ARRAY['M']::public.gender_enum[]; END IF;
      IF my_gender = 'F' THEN target_genders := ARRAY['F']::public.gender_enum[]; END IF;
  END IF;

  RETURN QUERY
  SELECT 
    p.id as profile_id,
    p.display_name::text,
    EXTRACT(YEAR FROM AGE(current_date, p.birth_date))::int as age,
    (ST_Distance(p.location_geom, my_geom)::float / 1000) as distance_km,
    pm.bio,
    pm.id as mode_id,
    
    -- ✅ UPDATED SUBQUERY: Fetches Array of up to 3 images
    ARRAY(
      SELECT media_url 
      FROM public.profile_mode_media pmm
      WHERE pmm.profile_mode_id = pm.id 
      AND pmm.is_deleted = false
      -- Put Primary First (TRUE sorts before FALSE in DESC), then newest
      ORDER BY pmm.is_primary DESC, pmm.created_at DESC 
      LIMIT 3
    ) as image_urls,

    p.gender::text,
    p.work_title::text,
    p.hometown_city::text,
    
    -- Fetch Prompts JSON
    COALESCE(
      (
        SELECT json_agg(
            json_build_object(
                'id', pmp.id,
                'prompt_template_id', pmp.prompt_template_id,
                'prompt_text', pt.prompt_text,
                'user_response', pmp.user_response,
                'prompt_display_order', pmp.display_order
            ) ORDER BY pmp.display_order ASC
        )
        FROM public.profile_mode_prompts pmp
        JOIN public.prompt_templates pt ON pt.id = pmp.prompt_template_id
        WHERE pmp.profile_mode_id = pm.id
      ), 
      '[]'::json
    ) as prompts,
    
    COALESCE(pm.looking_for, '{}'::text[]) as looking_for,
    p.is_verified,
    p.verification_level::text
    
  FROM public.profiles p
  INNER JOIN public.profile_modes pm ON p.id = pm.profile_id
  
  WHERE 
    p.is_active = true
    AND p.user_id != auth.uid()
    
    AND p.gender = ANY(target_genders)
    
    AND (
        my_birth_date IS NULL 
        OR p.birth_date BETWEEN (my_birth_date - interval '5 years') AND (my_birth_date + interval '5 years')
    )

    AND ST_DWithin(p.location_geom, my_geom, radius_km * 1000)
    
    AND pm.mode = search_mode::public.profile_mode_enum
    AND pm.is_active = true

    AND NOT EXISTS (
        SELECT 1 FROM public.swipes s
        WHERE 
            (s.actor_id = my_profile_id AND s.target_id = p.id)
            OR 
            (s.actor_id = p.id AND s.target_id = my_profile_id AND s.action_type = 'like'::public.swipe_action_enum)
    )

  ORDER BY p.location_geom <-> my_geom
  LIMIT limit_count
  OFFSET offset_count;
END;
$$;
