-- ============================================================================
-- The swipes table was world-readable.
--
-- "Allow realtime select swipes" was USING (true) for role public, and since
-- policies are OR'd it made the sensible "Users view own swipes" policy next
-- to it meaningless: any logged-in user could read every swipe in the app —
-- who liked them before matching (defeating the Liked You gate), and who
-- passed on them.
--
-- It existed because Liked You subscribes to realtime INSERTs on swipes where
-- target_id is the caller, and realtime honours RLS — so the incoming half is
-- a real requirement, not something to drop. Scope it instead:
--
--   * swipes I made          → mine to see
--   * likes aimed at me      → mine to see (this is the Liked You feed)
--   * passes aimed at me     → nobody's business
--
-- Every RPC that touches swipes (record_swipe, undo_last_swipe,
-- get_discovery_prospects, get_likes_received) is SECURITY DEFINER and so is
-- unaffected. The two direct table reads in the app — the relationship lookup
-- in DiscoveryRepository and the Liked You realtime channel — are both covered
-- by the policies below.
-- ============================================================================

DROP POLICY IF EXISTS "Allow realtime select swipes" ON public.swipes;

CREATE POLICY "Users view likes aimed at them"
  ON public.swipes
  FOR SELECT
  USING (
    action_type IN ('like', 'super_like')
    AND target_id IN (
      SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
  );
