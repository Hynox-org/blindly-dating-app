-- ==============================================================================
-- 🚀 DISCOVERY PIPELINE RPC: get_discovery_candidates (Official Version)
-- Source: Discovery Implementation Guide
-- Description: Fetches target context and 100 candidate IDs for Lambda.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.get_discovery_candidates(
  target_profile_id uuid,
  target_mode_input text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_filters jsonb;
  seen_profiles uuid[];
  target_mode_id uuid;
  target_birth date;
  target_location geometry;
  t_interest_chips text[];
  t_lifestyle_chips text[];
  result jsonb;
BEGIN
  -- 1. Fetch target profile mode details
  SELECT pm.id, coalesce(pm.filters,'{}'),
  coalesce(pm.discovery_seen_profiles,'{}')
    INTO target_mode_id, target_filters, seen_profiles
    FROM public.profile_modes pm
    WHERE pm.profile_id = target_profile_id
    AND pm.mode = target_mode_input::public.profile_mode_enum AND pm.is_active = true LIMIT 1;

  IF target_mode_id IS NULL THEN RETURN NULL; END IF;

  -- 2. Fetch target profile details
  SELECT p.birth_date, p.location_geom INTO target_birth, target_location
    FROM public.profiles p WHERE p.id = target_profile_id
    AND p.is_active = true AND p.is_deleted = false;

  IF target_birth IS NULL THEN RETURN NULL; END IF;

  -- 3. Fetch target's interests and lifestyle chips
  SELECT array_agg(ic.label) INTO t_interest_chips
    FROM public.profile_mode_interestchips pmic
    JOIN public.interest_chips ic ON ic.id = pmic.chip_id
    WHERE pmic.profile_mode_id = target_mode_id;

  SELECT array_agg(lc.label) INTO t_lifestyle_chips
    FROM public.profile_mode_lifestylechips pmlc
    JOIN public.lifestyle_chips lc ON lc.id = pmlc.chip_id
    WHERE pmlc.profile_mode_id = target_mode_id;

  -- 4. Build the response object with target context and candidate pool
  SELECT jsonb_build_object(
    'mode', target_mode_input,
    'target', jsonb_build_object(
      'profile_id', target_profile_id,
      'profile_mode_id', target_mode_id,
      'mode', target_mode_input,
      'birth_date', target_birth,
      'location', jsonb_build_object(
        'lat', ST_Y(target_location::geometry),
        'lng', ST_X(target_location::geometry)),
      'interest_chips', coalesce(to_jsonb(t_interest_chips),'[]'),
      'lifestyle_chips', coalesce(to_jsonb(t_lifestyle_chips),'[]'),
      'mode_filters', jsonb_build_object(
        'minAge', coalesce((target_filters->>'minAge')::int, 18),
        'maxAge', coalesce((target_filters->>'maxAge')::int, 99),
        'distanceLimit', coalesce((target_filters->>'distanceLimit')::float, 100),
        'genderPreference', coalesce(target_filters->>'genderPreference', 'Everyone')
      )
    ),
    'candidate_ids', (
      SELECT jsonb_agg(p.id) FROM (
        SELECT p.id FROM public.profiles p
        JOIN public.profile_modes pm ON pm.profile_id = p.id
        WHERE p.id != target_profile_id
        AND pm.mode = target_mode_input::public.profile_mode_enum
        AND pm.is_active = true
        AND p.is_active = true
        AND p.is_deleted = false
        AND p.id != ALL(seen_profiles)
        -- Age filter
        AND p.birth_date <= CURRENT_DATE - (coalesce((target_filters->>'minAge')::int, 18) || ' years')::interval
        AND p.birth_date >= CURRENT_DATE - (coalesce((target_filters->>'maxAge')::int, 99) || ' years')::interval
        -- Distance filter
        AND ST_DWithin(p.location_geom, target_location, coalesce((target_filters->>'distanceLimit')::float, 100) * 1609.34)
        -- Gender filter
        AND (
          coalesce(target_filters->>'genderPreference', 'Everyone') = 'Everyone'
          OR (target_filters->>'genderPreference' = 'Women' AND lower(p.gender::text) = 'female')
          OR (target_filters->>'genderPreference' = 'Men' AND lower(p.gender::text) = 'male')
        )
        ORDER BY random() LIMIT 100
      ) p
    )
  ) INTO result;
  RETURN result;
END;
$$;

-- Utility: append_seen_profiles
CREATE OR REPLACE FUNCTION public.append_seen_profiles(
  p_profile_mode_id uuid,
  p_new_seen      uuid[]
)
RETURNS void 
SECURITY DEFINER
LANGUAGE sql AS $$
  UPDATE public.profile_modes
  SET discovery_seen_profiles = ARRAY(
    SELECT DISTINCT unnest(
      array_cat(coalesce(discovery_seen_profiles,'{}'), p_new_seen)
    )
  )
  WHERE id = p_profile_mode_id;
$$;
