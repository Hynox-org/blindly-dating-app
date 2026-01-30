-- Remove the 'looking_for' column as requested.
-- Logic is now handled dynamically via 'get_discovery_feed_v3'.

ALTER TABLE profiles
DROP COLUMN IF EXISTS looking_for;
