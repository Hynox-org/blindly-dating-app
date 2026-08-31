-- ============================================================================
-- match_blocks holds profile ids, not auth user ids.
--
-- Everything that reads the table already assumes profiles:
--   * unmatch_users copies matches.user_a_id / user_b_id straight in, and both
--     of those are profile ids;
--   * get_discovery_prospects and get_discovery_categories both compare
--     match_blocks.user_a_id against the caller's profile id.
--
-- Only the foreign keys disagreed, and they pointed at auth.users. Two
-- consequences, both live today:
--   1. unmatch_users raises 23503 for any real pair, so blocking on unmatch
--      has never actually persisted — which is why the table is empty;
--   2. had a row ever landed, the deck's "blocked either direction" check
--      would have compared a profile id against a user id and matched nobody.
--
-- The second one is what makes this urgent now: Spotlight lets someone pay to
-- jump to the front of a deck, and "the person who blocked me must never see
-- me" is exactly the rule that must not be decorative.
--
-- The table is empty, so this is a straight repoint. The guard below refuses
-- to run rather than silently dropping rows if that ever stops being true.
-- ============================================================================

DO $$
DECLARE stray INT;
BEGIN
  SELECT count(*) INTO stray
    FROM public.match_blocks b
   WHERE b.user_a_id NOT IN (SELECT id FROM public.profiles)
      OR b.user_b_id NOT IN (SELECT id FROM public.profiles);

  IF stray > 0 THEN
    RAISE EXCEPTION
      'match_blocks holds % row(s) that are not profile ids; migrate them before repointing the FK', stray;
  END IF;
END $$;

ALTER TABLE public.match_blocks
  DROP CONSTRAINT IF EXISTS match_blocks_user_a_id_fkey,
  DROP CONSTRAINT IF EXISTS match_blocks_user_b_id_fkey;

ALTER TABLE public.match_blocks
  ADD CONSTRAINT match_blocks_user_a_id_fkey
    FOREIGN KEY (user_a_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
  ADD CONSTRAINT match_blocks_user_b_id_fkey
    FOREIGN KEY (user_b_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- The deck asks "is this pair blocked, either direction" on every fetch.
CREATE INDEX IF NOT EXISTS idx_match_blocks_pair_a ON public.match_blocks (user_a_id, user_b_id);
CREATE INDEX IF NOT EXISTS idx_match_blocks_pair_b ON public.match_blocks (user_b_id, user_a_id);
