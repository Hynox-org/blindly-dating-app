-- Veriff is a single-decision provider: one session produces one verdict that
-- already covers document + face match + liveness. The schema modelled two
-- independent tiers (liveness_only / full_verified) fed by two tables, and the
-- two writers fought:
--
--   update_veriff_session() set is_verified = true, then called
--   recalculate_trust_score(), which re-derived is_verified from the empty
--   `verifications` table and set it straight back to false. Every approval
--   un-verified the user in the same transaction.
--
-- After this migration veriff_verifications is the only source of truth and
-- recalculate_trust_score() is the only writer of is_verified/verification_level.

-- Part 1/3: schema. Drops the second writer of profile verification state and
-- adds the decision detail the webhook was throwing away.
DROP TRIGGER IF EXISTS on_veriff_status_update ON public.veriff_verifications;
DROP FUNCTION IF EXISTS public.sync_veriff_to_profile();

ALTER TABLE public.veriff_verifications
  ADD COLUMN IF NOT EXISTS decision_code integer,
  ADD COLUMN IF NOT EXISTS attempt_id text,
  ADD COLUMN IF NOT EXISTS risk_labels jsonb DEFAULT '[]'::jsonb;

CREATE INDEX IF NOT EXISTS veriff_verifications_profile_updated_idx
  ON public.veriff_verifications (profile_id, updated_at DESC);
