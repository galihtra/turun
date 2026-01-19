-- =====================================================
-- AI Nutrition Feature - Supabase Tables
-- Run this SQL in your Supabase SQL Editor
-- =====================================================

-- 1. User Nutrition Goals Table
CREATE TABLE IF NOT EXISTS user_nutrition_goals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  goal_type TEXT NOT NULL CHECK (goal_type IN ('weight_loss', 'bulking', 'maintain')),
  target_weight DECIMAL(5,2),
  daily_calories DECIMAL(8,2) NOT NULL,
  bmr DECIMAL(8,2) NOT NULL,
  tdee DECIMAL(8,2) NOT NULL,
  streak INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for faster user lookups
CREATE INDEX IF NOT EXISTS idx_nutrition_goals_user_id ON user_nutrition_goals(user_id);

-- Enable RLS
ALTER TABLE user_nutrition_goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own nutrition goals"
  ON user_nutrition_goals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own nutrition goals"
  ON user_nutrition_goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own nutrition goals"
  ON user_nutrition_goals FOR UPDATE
  USING (auth.uid() = user_id);

-- 2. Meal Logs Table
CREATE TABLE IF NOT EXISTS meal_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner')),
  food_name TEXT NOT NULL,
  calories INTEGER NOT NULL,
  target_calories INTEGER NOT NULL,
  image_url TEXT,
  ai_analysis TEXT,
  status TEXT NOT NULL CHECK (status IN ('empty', 'pass', 'over', 'under')),
  logged_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for faster lookups by user and date
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_id ON meal_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_meal_logs_logged_at ON meal_logs(logged_at);

-- Enable RLS
ALTER TABLE meal_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own meal logs"
  ON meal_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meal logs"
  ON meal_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal logs"
  ON meal_logs FOR UPDATE
  USING (auth.uid() = user_id);
