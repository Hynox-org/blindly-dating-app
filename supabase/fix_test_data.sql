-- Fix Priya's Data (User ID: 14d03c3f-d49b-40dd-803d-169d49295051)

-- 1. Ensure 'date' mode exists and is active
INSERT INTO profile_modes (profile_id, mode, is_active, bio)
SELECT id, 'date', true, 'I am Priya, generated for testing.'
FROM profiles
WHERE display_name = 'Priya'
ON CONFLICT (profile_id, mode) DO UPDATE
SET is_active = true;

-- 2. Fix Location (Copy from passport if main location is null)
UPDATE profiles
SET location_geom = passport_location_geom
WHERE display_name = 'Priya' AND location_geom IS NULL;

-- 3. Ensure 'date' mode exists for Paramesh too (just in case)
INSERT INTO profile_modes (profile_id, mode, is_active, bio)
SELECT id, 'date', true, 'I am Paramesh.'
FROM profiles
WHERE display_name = 'Paramesh'
ON CONFLICT (profile_id, mode) DO UPDATE
SET is_active = true;
