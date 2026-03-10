-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "extensions";

-- Create the cleanup function
CREATE OR REPLACE FUNCTION delete_old_notifications()
RETURNS void AS $$
BEGIN
  -- 1. Delete read notifications older than 2 days
  -- We use read_at if available, otherwise fallback to created_at
  DELETE FROM public.notifications
  WHERE is_read = TRUE
  AND (
    (read_at IS NOT NULL AND read_at < NOW() - INTERVAL '2 days')
    OR
    (read_at IS NULL AND created_at < NOW() - INTERVAL '2 days')
  );

  -- 2. Delete unread notifications older than 7 days
  DELETE FROM public.notifications
  WHERE is_read = FALSE
  AND created_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule the cleanup task to run every day at 00:00 (midnight)
-- Note: '0 0 * * *' corresponds to midnight daily
-- We use a safe unschedule by name if it already exists
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'notification-cleanup';
SELECT cron.schedule(
  'notification-cleanup',
  '0 0 * * *',
  'SELECT delete_old_notifications()'
);
