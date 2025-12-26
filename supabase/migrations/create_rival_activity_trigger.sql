-- Migration: Create trigger for Rival Activity notifications
-- This trigger detects when a user's points change and checks if they overtook someone on the leaderboard

-- Function to check for rival activity and send notifications
CREATE OR REPLACE FUNCTION check_rival_overtake()
RETURNS TRIGGER AS $$
DECLARE
  previous_rank INT;
  new_rank INT;
  overtaken_users RECORD;
  current_user_name TEXT;
BEGIN
  -- Get the user's name for the notification
  SELECT COALESCE(username, full_name, 'Unknown') INTO current_user_name
  FROM users
  WHERE id = NEW.user_id;

  -- Calculate previous rank (based on old points)
  WITH ranked_users AS (
    SELECT
      user_id,
      RANK() OVER (ORDER BY total_points DESC) as rank
    FROM users
  )
  SELECT rank INTO previous_rank
  FROM ranked_users
  WHERE user_id = NEW.user_id;

  -- Calculate new rank (based on new points)
  -- We need to simulate the new points first
  WITH ranked_users AS (
    SELECT
      user_id,
      RANK() OVER (ORDER BY total_points DESC) as rank
    FROM users
  )
  SELECT rank INTO new_rank
  FROM ranked_users
  WHERE user_id = NEW.user_id;

  -- If user improved their rank (lower number = better rank)
  IF new_rank < previous_rank THEN
    -- Find all users who were overtaken (users now ranked between new_rank and previous_rank)
    FOR overtaken_users IN
      WITH ranked_users AS (
        SELECT
          u.id,
          u.username,
          u.full_name,
          RANK() OVER (ORDER BY u.total_points DESC) as rank
        FROM users u
      )
      SELECT id, COALESCE(username, full_name, 'Unknown') as name
      FROM ranked_users
      WHERE rank >= new_rank
        AND rank < previous_rank
        AND id != NEW.user_id
    LOOP
      -- Check if we already sent this notification recently (within last 24 hours)
      IF NOT EXISTS (
        SELECT 1
        FROM notifications
        WHERE user_id = overtaken_users.id
          AND type = 'rivalActivity'
          AND rival_username = current_user_name
          AND created_at > NOW() - INTERVAL '24 hours'
      ) THEN
        -- Send rival activity notification to the overtaken user
        INSERT INTO notifications (
          user_id,
          title,
          message,
          type,
          rival_username,
          is_read
        ) VALUES (
          overtaken_users.id,
          '👥 RIVAL ALERT',
          '@' || current_user_name || ' just overtook you on the Leaderboard! Don''t get left behind.',
          'rivalActivity',
          current_user_name,
          false
        );

        RAISE NOTICE 'Sent rival activity notification to % about %', overtaken_users.name, current_user_name;
      END IF;
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on users table when total_points is updated
DROP TRIGGER IF EXISTS trigger_rival_activity ON users;

CREATE TRIGGER trigger_rival_activity
  AFTER UPDATE OF total_points ON users
  FOR EACH ROW
  WHEN (NEW.total_points > OLD.total_points)
  EXECUTE FUNCTION check_rival_overtake();

-- Note: This trigger fires when a user's total_points increases
-- Make sure total_points is updated whenever achievements are unlocked or runs are completed
