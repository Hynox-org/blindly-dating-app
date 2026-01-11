-- Migration: Location Tracking & Discovery
-- Description: Secures location updates and adds discovery query.

BEGIN;

-- 1. Secure location_geom: Revoke direct update access from authenticated users
-- This forces the client to use the Edge Function (which uses service_role or admin privileges)
-- to update their location, ensuring our server-side validation and anti-spoofing logic runs.
REVOKE UPDATE (location_geom) ON TABLE public.profiles FROM authenticated;
REVOKE UPDATE (location_geom) ON TABLE public.profiles FROM anon;

-- Note: We assume standard RLS "Users can update their own profile" exists for other columns.
-- If not, ensure you have basic RLS:
-- CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);

-- 2. Create Safety Flags table if it doesn't exist (referenced in requirements)
CREATE TABLE IF NOT EXISTS public.safety_flags (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    flag_type text NOT NULL, -- e.g., 'locationspoofing'
    confidence_score float DEFAULT 0.0,
    details jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_safety_flags_user ON public.safety_flags(user_id);

-- 3. Discovery Feed Function
-- Returns profiles within radius_km, ordered by distance.
-- Excludes: Self, Deleted, Inactive.
CREATE OR REPLACE FUNCTION public.get_discovery_feed(
    p_radius_km float DEFAULT 50.0,
    p_limit int DEFAULT 20,
    p_offset int DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    user_id uuid,
    display_name varchar,
    bio text,
    age int, -- Calculated from birth_date
    gender text, -- Cast to text for simplicity in Dart
    city varchar,
    distance_km float,
    match_percentage int -- Placeholder for future matching logic
)
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with privileges of creator (admin), bypasses RLS to read others' locations
SET search_path = public, extensions
AS $$
DECLARE
    v_my_location geography(Point, 4326);
    v_my_id uuid;
BEGIN
    v_my_id := auth.uid();
    
    -- Get current user's location
    SELECT location_geom INTO v_my_location
    FROM public.profiles
    WHERE public.profiles.user_id = v_my_id;

    -- If no location set, return empty or global feed (returning empty for now)
    IF v_my_location IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT 
        p.id,
        p.user_id,
        p.display_name,
        p.bio,
        EXTRACT(YEAR FROM age(CURRENT_DATE, p.birth_date))::int as age,
        p.gender::text,
        p.city,
        (ST_Distance(p.location_geom, v_my_location) / 1000.0) as distance_km,
        80 as match_percentage -- placeholder
    FROM public.profiles p
    WHERE 
        p.user_id != v_my_id
        AND p.is_active = true
        AND p.is_deleted = false
        -- Optimize with ST_DWithin (uses index)
        AND ST_DWithin(p.location_geom, v_my_location, p_radius_km * 1000)
    ORDER BY 
        p.location_geom <-> v_my_location
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

COMMIT;
