-- migration_daily_discovery_matches.sql

-- 1. Create table to store the 24-hour cache of AWS ML matches for each user
CREATE TABLE IF NOT EXISTS public.daily_discovery_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_mode_id UUID NOT NULL REFERENCES public.profile_modes(id) ON DELETE CASCADE,
    feed_data JSONB NOT NULL, -- Stores the categorized UUIDs returned from AWS
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure we only have one cached feed per profile mode to prevent duplicates
    UNIQUE(profile_mode_id)
);

-- Enable RLS (Row Level Security)
ALTER TABLE public.daily_discovery_matches ENABLE ROW LEVEL SECURITY;

-- Allow users to read and update their own cache based on the profile_modes relation
CREATE POLICY "Users can manage their own discovery cache"
    ON public.daily_discovery_matches
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profile_modes pm
            JOIN public.profiles p ON p.id = pm.profile_id
            WHERE pm.id = daily_discovery_matches.profile_mode_id
            AND p.user_id = auth.uid()
        )
    );

-- Allow Edge Functions (Service Role) full access
CREATE POLICY "Service Role has full access to daily_discovery_matches"
    ON public.daily_discovery_matches
    FOR ALL
    USING (true);
