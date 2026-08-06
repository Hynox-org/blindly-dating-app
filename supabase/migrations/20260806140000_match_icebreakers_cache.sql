-- Cache for the ai-icebreakers edge function.
--
-- Keyed by the requesting profile id, because the generated copy is written in
-- the sender's voice: {"<sender_profile_id>": {both_profiles: {...}, recipient_only: {...}}}
-- Written only by the edge function (service role), so no policy is added --
-- the column rides along with whatever SELECT policy matches already has.
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS icebreakers jsonb;
