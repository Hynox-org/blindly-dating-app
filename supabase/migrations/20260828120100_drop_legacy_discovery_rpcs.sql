-- ============================================================================
-- Drop the discovery RPCs nothing calls any more.
--
-- get_discovery_landing_feed  — replaced by get_discovery_categories +
--                               hydrate_discovery_profiles.
-- get_discovery_candidates    — only caller was the discovery-trigger Lambda,
--                               now in supabase/functions/_archive/, whose own
--                               header records that it never worked.
-- get_discovery_ml_payload    — no caller in the app or in any edge function.
-- record_swipe_action         — superseded by record_swipe, which also reports
--                               whether the swipe produced a match.
--
-- Verified before dropping: no reference in lib/, no reference in any live
-- supabase/functions/ directory (only _archive/discovery-trigger.ts).
-- ============================================================================

DROP FUNCTION IF EXISTS public.get_discovery_landing_feed(
  double precision, double precision, integer, integer, text, boolean);
DROP FUNCTION IF EXISTS public.get_discovery_candidates(uuid, text);
DROP FUNCTION IF EXISTS public.get_discovery_ml_payload(text, uuid);
DROP FUNCTION IF EXISTS public.record_swipe_action(uuid, public.swipe_action_enum);
