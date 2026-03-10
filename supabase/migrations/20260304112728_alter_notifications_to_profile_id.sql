-- Alter notifications table to use profile_id instead of user_id
ALTER TABLE notifications DROP COLUMN IF EXISTS user_id CASCADE;
ALTER TABLE notifications ADD COLUMN profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE;

-- Alter user_push_tokens table to use profile_id instead of user_id
ALTER TABLE user_push_tokens DROP COLUMN IF EXISTS user_id CASCADE;
ALTER TABLE user_push_tokens ADD COLUMN profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE;

-- Recreate index for quick lookups using profile_id
CREATE INDEX idx_user_notifications ON notifications(profile_id, is_read, created_at DESC);

-- Update RLS policies for notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can insert their own notifications" ON notifications;

CREATE POLICY "Users can view their own notifications" 
ON notifications FOR SELECT 
TO authenticated 
USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can update their own notifications" 
ON notifications FOR UPDATE 
TO authenticated 
USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()))
WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert their own notifications" 
ON notifications FOR INSERT 
TO authenticated 
WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

-- Update RLS policies for user_push_tokens
DROP POLICY IF EXISTS "Users can view their own tokens" ON user_push_tokens;
DROP POLICY IF EXISTS "Users can insert their own tokens" ON user_push_tokens;
DROP POLICY IF EXISTS "Users can update their own tokens" ON user_push_tokens;
DROP POLICY IF EXISTS "Users can delete their own tokens" ON user_push_tokens;

CREATE POLICY "Users can view their own tokens" 
ON user_push_tokens FOR SELECT 
TO authenticated 
USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert their own tokens" 
ON user_push_tokens FOR INSERT 
TO authenticated 
WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can update their own tokens" 
ON user_push_tokens FOR UPDATE 
TO authenticated 
USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()))
WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));

CREATE POLICY "Users can delete their own tokens" 
ON user_push_tokens FOR DELETE 
TO authenticated 
USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));
