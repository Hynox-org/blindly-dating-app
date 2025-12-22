-- Add columns to profiles
ALTER TABLE "public"."profiles" 
DROP COLUMN IF EXISTS "onboarding_step",
DROP COLUMN IF EXISTS "skipped_steps",
ADD COLUMN IF NOT EXISTS "onboarding_status" text DEFAULT 'in_progress', -- 'in_progress', 'complete', 'blocked'
ADD COLUMN IF NOT EXISTS "steps_progress" jsonb DEFAULT '{}'::jsonb, -- Map of step_key -> status ('completed', 'skipped')
ADD COLUMN IF NOT EXISTS "profile_completeness" int DEFAULT 0;

-- Create onboarding_steps table
CREATE TABLE IF NOT EXISTS "public"."onboarding_steps" (
    "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    "step_key" text NOT NULL UNIQUE,
    "step_name" text NOT NULL,
    "step_position" int NOT NULL,
    "is_mandatory" boolean DEFAULT false,
    "step_type" text NOT NULL, -- 'auth', 'basic_profile', 'photos', 'verification', 'enrichment'
    "estimated_time_seconds" int DEFAULT 30,
    "max_skips_allowed" int DEFAULT 0,
    "is_parallel" boolean DEFAULT false,
    "created_at" timestamptz DEFAULT now(),
    "updated_at" timestamptz DEFAULT now()
);

-- RLS for onboarding_steps
ALTER TABLE "public"."onboarding_steps" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to onboarding_steps"
ON "public"."onboarding_steps"
FOR SELECT USING (true);


-- Create profile completeness trigger
CREATE OR REPLACE FUNCTION calculate_profile_completeness()
RETURNS TRIGGER AS $$
DECLARE
  completeness int := 0;
BEGIN
  -- Mandatory: 70 points
  IF NEW.display_name IS NOT NULL THEN completeness := completeness + 10; END IF;
  IF NEW.birth_date IS NOT NULL THEN completeness := completeness + 10; END IF;
  IF NEW.gender IS NOT NULL THEN completeness := completeness + 10; END IF;
  
  -- Optional: 30 points
  IF NEW.bio IS NOT NULL AND length(trim(NEW.bio)) > 50 THEN completeness := completeness + 10; END IF;

  NEW.profile_completeness := least(completeness, 100);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS profiles_completeness_trigger ON profiles;

CREATE TRIGGER profiles_completeness_trigger
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION calculate_profile_completeness();

-- RLS Policy for discovery
CREATE POLICY "Block incomplete profiles from discovery"
ON profiles FOR SELECT USING (
  (auth.uid() = id) OR -- User can see themselves
  (onboarding_status = 'complete' AND profile_completeness >= 60)
);

-- Insert Default Steps
-- NOTE: Removed 'selfie_processing' as it is a transient UI state, not a persisted step.
INSERT INTO "public"."onboarding_steps" ("step_key", "step_name", "step_position", "is_mandatory", "step_type", "estimated_time_seconds", "max_skips_allowed") 
VALUES 
('terms_accept', 'Accept Terms', 1, true, 'auth', 15, 0),
('permissions', 'App Permissions', 2, true, 'auth', 20, 0),
('language_select', 'Choose Language', 3, true, 'auth', 15, 0),
('name_entry', 'Enter Display Name', 4, true, 'basic_profile', 20, 0),
('birth_date', 'Enter Birth Date', 5, true, 'basic_profile', 25, 0),
('gender_select', 'Select Gender', 6, true, 'basic_profile', 15, 0),
('location_set', 'Set Location', 7, true, 'basic_profile', 30, 0),
('photo_upload', 'Upload Photos', 8, true, 'photos', 90, 0),
('photo_reorder', 'Reorder Photos', 9, false, 'photos', 30, 1),
('selfie_instructions', 'Selfie Verification', 10, false, 'verification', 45, 2),
('selfie_capture', 'Capture Selfie', 11, false, 'verification', 60, 2),
('gov_id_optional', 'Government ID (Optional)', 12, false, 'verification', 120, 1),
('bio_entry', 'Write Bio', 13, false, 'enrichment', 60, 3),
('interests_select', 'Choose Interests', 14, false, 'enrichment', 45, 2),
('lifestyle_prefs', 'Lifestyle Preferences', 15, false, 'enrichment', 40, 2),
('voice_intro', 'Record Voice Intro', 16, false, 'enrichment', 75, 1),
('profile_prompts', 'Add Profile Prompts', 17, false, 'enrichment', 75, 1)
ON CONFLICT (step_key) DO UPDATE SET 
step_position = EXCLUDED.step_position,
step_name = EXCLUDED.step_name;
