-- Core Notifications Table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Flexible typing allowing easy introduction of new notification types 
  -- ('system', 'match_update', 'promo', 'message', 'greeting', 'alert', 'reminder')
  type TEXT NOT NULL,
  
  -- Display content
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  
  -- Flexible payload for Flutter deep-linking (e.g., { "route": "/chat/123" })
  data JSONB DEFAULT '{}'::jsonb,  
  
  -- State tracking
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  
  -- Optional: Grouping identifier to collapse similar notifications natively
  group_id TEXT 
);

-- Index for fetching a user's unread notifications quickly (used by the in-app bell icon)
CREATE INDEX idx_user_notifications ON notifications(user_id, is_read, created_at DESC);

-- Index on type for quick filtering of notification preferences
CREATE INDEX idx_notification_type ON notifications(type);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own notifications
CREATE POLICY "Users can view their own notifications" 
ON notifications FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

-- Allow users to update their own notifications (e.g., read_at, is_read)
CREATE POLICY "Users can update their own notifications" 
ON notifications FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Device Tokens Table (for sending Push Notifications)
CREATE TABLE user_push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,  -- FCM token
  platform TEXT CHECK (platform IN ('ios', 'android', 'web')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_push_tokens ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own tokens
CREATE POLICY "Users can view their own tokens" 
ON user_push_tokens FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

-- Allow users to insert their own tokens
CREATE POLICY "Users can insert their own tokens" 
ON user_push_tokens FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own tokens
CREATE POLICY "Users can update their own tokens" 
ON user_push_tokens FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own tokens
CREATE POLICY "Users can delete their own tokens" 
ON user_push_tokens FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- Trigger function to update last_used_at timestamp on token usage/update
CREATE OR REPLACE FUNCTION update_last_used_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_used_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_push_tokens_last_used_at
BEFORE UPDATE ON user_push_tokens
FOR EACH ROW
EXECUTE FUNCTION update_last_used_at();

-- Enable pg_net for HTTP requests from the database
CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

-- Webhook function to call the deliver-push-notification Edge Function
CREATE OR REPLACE FUNCTION public.webhook_deliver_push()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- We use net.http_post to make an asynchronous HTTP request
  -- The Edge Function URL in production will be specific to your project.
  -- You must set app.settings.edge_function_url in your Supabase configuration or replace this heavily parameterized URL.
  PERFORM net.http_post(
    url := COALESCE(current_setting('app.settings.edge_function_url', true), 'http://host.docker.internal:54321') || '/functions/v1/deliver-push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || COALESCE(current_setting('app.settings.service_role_key', true), 'anon-key')
    ),
    body := jsonb_build_object(
      'type', TG_OP,
      'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA,
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$;

-- Trigger to execute the webhook on new notifications
CREATE TRIGGER "send_push_notification"
AFTER INSERT ON "public"."notifications"
FOR EACH ROW
EXECUTE FUNCTION "public"."webhook_deliver_push"();
