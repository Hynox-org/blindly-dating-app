-- Debug script to inspect swipes
SELECT * FROM swipes ORDER BY created_at DESC LIMIT 5;

-- Also show current user IDs for comparison
SELECT auth.uid() as auth_id, id as profile_id FROM profiles WHERE user_id = auth.uid();
