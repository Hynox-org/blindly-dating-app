-- migration_smart_discovery.sql

-- This function generates the JSON payload to send to AWS for ml categorization.
-- It returns the current user profile context and a pool of candidates matching basic preferences.
-- It limits the search radius to 200km to avoid massive payload transfers, and limits to 1000 candidates max.
-- It correctly fetches interests and lifestyles linked to that exact profile mode!

CREATE OR REPLACE FUNCTION get_discovery_ml_payload(
  search_mode text,
  user_auth_id uuid DEFAULT auth.uid()
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  my_profile_id uuid;
  my_mode_id uuid;
  my_geom geometry;
  my_gender public.gender_enum;
  my_birth_date date;
  my_seen_profiles uuid[];
  target_genders public.gender_enum[];
  result json;
  current_user_json json;
  candidates_json json;
BEGIN
  -- 1. Get current user's profile and geom
  SELECT 
    id, 
    gender, 
    birth_date,
    COALESCE(passport_location_geom, location_geom) 
  INTO 
    my_profile_id, 
    my_gender, 
    my_birth_date,
    my_geom
  FROM public.profiles 
  WHERE user_id = user_auth_id;

  -- 2. Get current user's mode ID and seen profiles
  SELECT 
    id,
    COALESCE(discovery_seen_profiles, ARRAY[]::uuid[]) 
  INTO 
    my_mode_id,
    my_seen_profiles
  FROM public.profile_modes 
  WHERE profile_id = my_profile_id AND mode = search_mode::public.profile_mode_enum AND is_active = true;

  -- Ensure we got everything
  IF my_profile_id IS NULL OR my_mode_id IS NULL THEN
    RETURN json_build_object('error', 'Profile or mode not found');
  END IF;

  -- Safety Check for Geom
  IF my_geom IS NULL THEN
    RETURN json_build_object('error', 'Location geometry is null');
  END IF;

  -- 3. Auto-calculate gender preference
  IF my_gender IN ('NB', 'Prefer Not') THEN
      target_genders := ARRAY['M', 'F', 'NB', 'Prefer Not']::public.gender_enum[];
  ELSIF search_mode = 'date' THEN
      IF my_gender = 'M' THEN target_genders := ARRAY['F']::public.gender_enum[]; END IF;
      IF my_gender = 'F' THEN target_genders := ARRAY['M']::public.gender_enum[]; END IF;
  ELSIF search_mode = 'bff' THEN
      IF my_gender = 'M' THEN target_genders := ARRAY['M']::public.gender_enum[]; END IF;
      IF my_gender = 'F' THEN target_genders := ARRAY['F']::public.gender_enum[]; END IF;
  END IF;

  -- 4. Build current user JSON
  SELECT json_build_object(
      'profile_id', my_profile_id,
      'location_geom', ST_AsText(my_geom),
      'interests', COALESCE((
          SELECT json_agg(chip_id) 
          FROM public.profile_mode_interestchips 
          WHERE profile_mode_id = my_mode_id
      ), '[]'::json),
      'lifestyle', COALESCE((
          SELECT json_agg(chip_id) 
          FROM public.profile_mode_lifestylechips 
          WHERE profile_mode_id = my_mode_id
      ), '[]'::json)
  ) INTO current_user_json;

  -- 5. Build candidate pool JSON array
  -- USING a subquery to safely fetch limited records with arrays
  SELECT COALESCE(json_agg(
      json_build_object(
          'profile_id', sub.id,
          'location_geom', ST_AsText(sub.geom),
          'created_at', sub.created_at,
          'last_active_at', sub.last_active,
          'interests', sub.interests,
          'lifestyle', sub.lifestyle
      )
  ), '[]'::json)
  INTO candidates_json
  FROM (
      SELECT 
          p.id,
          COALESCE(p.passport_location_geom, p.location_geom) as geom,
          p.created_at,
          p.last_active,
          COALESCE((
              SELECT json_agg(ic.chip_id) 
              FROM public.profile_mode_interestchips ic 
              WHERE ic.profile_mode_id = pm.id
          ), '[]'::json) as interests,
          COALESCE((
              SELECT json_agg(lc.chip_id) 
              FROM public.profile_mode_lifestylechips lc 
              WHERE lc.profile_mode_id = pm.id
          ), '[]'::json) as lifestyle
      FROM public.profiles p
      INNER JOIN public.profile_modes pm ON p.id = pm.profile_id
      WHERE 
        p.is_active = true
        AND p.id != my_profile_id
        AND p.gender = ANY(target_genders)
        AND ST_DWithin(COALESCE(p.passport_location_geom, p.location_geom), my_geom, 200 * 1000)
        AND pm.mode = search_mode::public.profile_mode_enum
        AND pm.is_active = true
        -- EXCLUDE USERS ALREADY SHOWN IN PREVIOUS BATCHES
        AND p.id != ALL(my_seen_profiles)
        -- Exclude users already swiped today
        AND NOT EXISTS (
            SELECT 1 FROM public.swipes s
            WHERE 
                (s.actor_id = my_profile_id AND s.target_id = p.id)
                OR 
                (s.actor_id = p.id AND s.target_id = my_profile_id AND s.action_type = 'like'::public.swipe_action_enum)
        )
      ORDER BY p.last_active DESC NULLS LAST
      LIMIT 1000
  ) sub;

  -- 6. Combine everything
  result := json_build_object(
      'current_user', current_user_json,
      'candidate_pool', candidates_json,
      'requirements', json_build_object('max_per_category', 5)
  );

  RETURN result;
END;
$$;
