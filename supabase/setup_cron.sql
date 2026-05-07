-- ==============================================================================
-- ⏰ DISCOVERY CRON SETUP
-- Run this in the Supabase SQL Editor.
-- Note: Replace <PROJECT_REF> and <SERVICE_ROLE_KEY> with your actual values.
-- ==============================================================================

-- 1. Enable pg_cron and pg_net if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 2. Schedule the Discovery Batch Refresh (Every day at 00:00 IST / 18:30 UTC)
SELECT cron.schedule(
  'daily-discovery-refresh',
  '30 18 * * *',
  $$
  SELECT net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/process-discovery-batch',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer <SERVICE_ROLE_KEY>"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
