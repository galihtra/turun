-- ==================================================
-- TURUN APP - RUN SESSIONS TABLE ONLY
-- Quick setup for run tracking feature
-- ==================================================

-- Create run_sessions table
CREATE TABLE IF NOT EXISTS public.run_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    territory_id INTEGER NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    distance_meters DOUBLE PRECISION NOT NULL DEFAULT 0,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    average_pace_min_per_km DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_speed DOUBLE PRECISION NOT NULL DEFAULT 0,
    calories_burned INTEGER NOT NULL DEFAULT 0,
    route_points JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
    territory_conquered BOOLEAN NOT NULL DEFAULT FALSE,
    previous_owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_run_sessions_user_id ON public.run_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_run_sessions_territory_id ON public.run_sessions(territory_id);
CREATE INDEX IF NOT EXISTS idx_run_sessions_status ON public.run_sessions(status);
CREATE INDEX IF NOT EXISTS idx_run_sessions_pace ON public.run_sessions(average_pace_min_per_km) WHERE status = 'completed';
CREATE INDEX IF NOT EXISTS idx_run_sessions_start_time ON public.run_sessions(start_time DESC);

-- Enable Row Level Security
ALTER TABLE public.run_sessions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can view completed run sessions" ON public.run_sessions;
DROP POLICY IF EXISTS "Users can view own run sessions" ON public.run_sessions;
DROP POLICY IF EXISTS "Users can insert own run sessions" ON public.run_sessions;
DROP POLICY IF EXISTS "Users can update own run sessions" ON public.run_sessions;
DROP POLICY IF EXISTS "Users can delete own run sessions" ON public.run_sessions;

-- RLS Policies for run_sessions
-- Users can view all completed run sessions (for leaderboards)
CREATE POLICY "Anyone can view completed run sessions"
    ON public.run_sessions
    FOR SELECT
    USING (status = 'completed');

-- Users can view their own run sessions (any status)
CREATE POLICY "Users can view own run sessions"
    ON public.run_sessions
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own run sessions
CREATE POLICY "Users can insert own run sessions"
    ON public.run_sessions
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own run sessions
CREATE POLICY "Users can update own run sessions"
    ON public.run_sessions
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own run sessions
CREATE POLICY "Users can delete own run sessions"
    ON public.run_sessions
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create or replace function for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS update_run_sessions_updated_at ON public.run_sessions;
CREATE TRIGGER update_run_sessions_updated_at
    BEFORE UPDATE ON public.run_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==================================================
-- HELPER FUNCTIONS
-- ==================================================

-- Function to get current territory owner's best time
CREATE OR REPLACE FUNCTION get_territory_best_pace(territory_id_param INTEGER)
RETURNS TABLE (
    user_id UUID,
    best_pace DOUBLE PRECISION,
    run_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rs.user_id,
        rs.average_pace_min_per_km,
        rs.id
    FROM run_sessions rs
    WHERE rs.territory_id = territory_id_param
      AND rs.status = 'completed'
    ORDER BY rs.average_pace_min_per_km ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can conquer territory
CREATE OR REPLACE FUNCTION can_conquer_territory(
    territory_id_param INTEGER,
    user_pace DOUBLE PRECISION
)
RETURNS BOOLEAN AS $$
DECLARE
    current_best_pace DOUBLE PRECISION;
BEGIN
    SELECT average_pace_min_per_km INTO current_best_pace
    FROM run_sessions
    WHERE territory_id = territory_id_param
      AND status = 'completed'
    ORDER BY average_pace_min_per_km ASC
    LIMIT 1;

    -- If no existing record, user can conquer
    IF current_best_pace IS NULL THEN
        RETURN TRUE;
    END IF;

    -- User must have better (lower) pace to conquer
    RETURN user_pace < current_best_pace;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==================================================
-- VERIFICATION QUERIES
-- ==================================================

-- Verify table was created
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' AND table_name = 'run_sessions';

-- Verify indexes
-- SELECT indexname FROM pg_indexes
-- WHERE tablename = 'run_sessions';

-- Verify RLS is enabled
-- SELECT tablename, rowsecurity FROM pg_tables
-- WHERE schemaname = 'public' AND tablename = 'run_sessions';

-- Verify policies
-- SELECT policyname FROM pg_policies
-- WHERE tablename = 'run_sessions';

-- ==================================================
-- DONE!
-- ==================================================
-- Your run_sessions table is ready to use!
-- Now you can run the Flutter app and start tracking runs.
