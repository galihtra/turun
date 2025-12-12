-- ==================================================
-- TURUN APP - SUPABASE DATABASE SCHEMA
-- Run Tracking & Territory System
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

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_run_sessions_updated_at
    BEFORE UPDATE ON public.run_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==================================================
-- TERRITORIES TABLE (if not exists)
-- ==================================================
CREATE TABLE IF NOT EXISTS public.territories (
    id SERIAL PRIMARY KEY,
    name TEXT,
    region TEXT,
    points JSONB NOT NULL DEFAULT '[]'::jsonb,
    owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    owner_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    image_url TEXT,
    difficulty TEXT,
    reward_points INTEGER,
    area_size_km DOUBLE PRECISION,
    description TEXT
);

-- Create indexes for territories
CREATE INDEX IF NOT EXISTS idx_territories_owner_id ON public.territories(owner_id);

-- Enable Row Level Security for territories
ALTER TABLE public.territories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for territories
CREATE POLICY "Anyone can view territories"
    ON public.territories
    FOR SELECT
    USING (true);

-- Only authenticated users can update territories (for claiming)
CREATE POLICY "Authenticated users can update territories"
    ON public.territories
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Create trigger for territories updated_at (only if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_territories_updated_at'
    ) THEN
        CREATE TRIGGER update_territories_updated_at
            BEFORE UPDATE ON public.territories
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END
$$;

-- ==================================================
-- USEFUL QUERIES FOR LEADERBOARDS
-- ==================================================

-- Get top 10 fastest runners for a specific territory
-- SELECT
--     rs.id,
--     rs.user_id,
--     u.email as user_email,
--     rs.average_pace_min_per_km,
--     rs.distance_meters,
--     rs.duration_seconds,
--     rs.start_time
-- FROM run_sessions rs
-- LEFT JOIN auth.users u ON rs.user_id = u.id
-- WHERE rs.territory_id = <TERRITORY_ID>
--   AND rs.status = 'completed'
-- ORDER BY rs.average_pace_min_per_km ASC
-- LIMIT 10;

-- Get user's best run for a territory
-- SELECT *
-- FROM run_sessions
-- WHERE user_id = <USER_ID>
--   AND territory_id = <TERRITORY_ID>
--   AND status = 'completed'
-- ORDER BY average_pace_min_per_km ASC
-- LIMIT 1;

-- Get all territories owned by a user
-- SELECT t.*, COUNT(rs.id) as total_runs
-- FROM territories t
-- LEFT JOIN run_sessions rs ON rs.territory_id = t.id AND rs.user_id = t.owner_id
-- WHERE t.owner_id = <USER_ID>
-- GROUP BY t.id;

-- ==================================================
-- SAMPLE DATA (Optional - for testing)
-- ==================================================

-- Insert sample territory (Batam Center example)
-- INSERT INTO territories (name, region, points, difficulty, reward_points, area_size_km, description)
-- VALUES (
--     'Batam Center Park',
--     'Batam City',
--     '[
--         {"lat": 1.13000, "lng": 104.05000},
--         {"lat": 1.13000, "lng": 104.05500},
--         {"lat": 1.12500, "lng": 104.05500},
--         {"lat": 1.12500, "lng": 104.05000}
--     ]'::jsonb,
--     'Easy',
--     100,
--     0.5,
--     'A beautiful park in the heart of Batam Center'
-- );

-- ==================================================
-- FUNCTIONS (Optional - Helper functions)
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
-- NOTES
-- ==================================================
-- 1. Make sure to run this SQL in your Supabase SQL Editor
-- 2. Adjust the sample data according to your actual territories
-- 3. The route_points JSONB field stores GPS coordinates as an array of objects with 'lat' and 'lng' keys
-- 4. RLS policies ensure users can only modify their own data
-- 5. The pace-based leaderboard system automatically determines territory ownership
