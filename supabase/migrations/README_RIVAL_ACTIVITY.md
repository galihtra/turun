# Rival Activity Notification - Database Trigger

This migration creates a PostgreSQL trigger that automatically sends "Rival Activity" notifications when a user overtakes another user on the leaderboard.

## How It Works

1. **Trigger Event**: Fires when a user's `total_points` in the `users` table increases
2. **Detection Logic**:
   - Calculates the user's previous rank (before points update)
   - Calculates the user's new rank (after points update)
   - If the user improved their rank (moved up on the leaderboard)
   - Identifies all users who were overtaken (users between the old and new rank)
3. **Notification**:
   - Sends a "Rival Activity" notification to each overtaken user
   - Includes the overtaking user's username in the message
   - Has a 24-hour cooldown to prevent spam

## Installation

Run the migration:

```bash
# Using Supabase CLI
supabase db push

# Or apply manually via Supabase Dashboard SQL Editor
# Copy and paste the contents of create_rival_activity_trigger.sql
```

## Database Objects Created

### Function: `check_rival_overtake()`
- Triggered function that detects rank changes
- Calculates rankings using PostgreSQL's `RANK()` window function
- Sends notifications to overtaken users
- Prevents duplicate notifications within 24 hours

### Trigger: `trigger_rival_activity`
- Attached to the `users` table
- Fires `AFTER UPDATE OF total_points`
- Only executes when `total_points` increases
- Calls `check_rival_overtake()` function

## Important Notes

### User Points Must Be Updated

The trigger **only fires** when `total_points` in the `users` table is updated. Make sure to update this field whenever:

- User completes an achievement → Already handled in `AchievementProvider.loadUserAchievements()`
- User earns points from runs
- User completes missions

The Flutter code already updates `total_points` via:
```dart
// In AchievementProvider
await _updateUserTotalPoints(userId);
```

This update triggers the database function which sends rival notifications.

### Notification Details

- **Title**: "👥 RIVAL ALERT"
- **Message**: "@{username} just overtook you on the Leaderboard! Don't get left behind."
- **Type**: `rivalActivity`
- **Cooldown**: 24 hours (won't send duplicate notification from same rival within 24h)

## Testing

1. **Create test users with different points:**
   ```sql
   -- User A has 100 points
   UPDATE users SET total_points = 100 WHERE id = 'user-a-id';

   -- User B has 90 points
   UPDATE users SET total_points = 90 WHERE id = 'user-b-id';
   ```

2. **Make User B overtake User A:**
   ```sql
   -- User B gains points and overtakes User A
   UPDATE users SET total_points = 110 WHERE id = 'user-b-id';
   ```

3. **Check notifications:**
   ```sql
   SELECT * FROM notifications
   WHERE type = 'rivalActivity'
   AND user_id = 'user-a-id';
   ```

   User A should receive a notification that User B overtook them.

## Monitoring

Check trigger execution logs:
```sql
-- View recent rival activity notifications
SELECT
  n.created_at,
  u1.username as notified_user,
  n.rival_username as rival
FROM notifications n
JOIN users u1 ON u1.id = n.user_id
WHERE n.type = 'rivalActivity'
ORDER BY n.created_at DESC
LIMIT 20;
```

## Troubleshooting

### Notifications not being sent?

1. Check if trigger exists:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'trigger_rival_activity';
   ```

2. Check if function exists:
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'check_rival_overtake';
   ```

3. Verify `total_points` is actually being updated:
   ```sql
   SELECT id, username, total_points, updated_at
   FROM users
   ORDER BY updated_at DESC
   LIMIT 10;
   ```

### Too many notifications being sent?

The trigger has a 24-hour cooldown. If you're still getting too many notifications:

1. Increase the cooldown period in the trigger function:
   ```sql
   -- Change '24 hours' to '48 hours' or longer
   AND created_at > NOW() - INTERVAL '48 hours'
   ```

2. Or modify the rank change threshold (currently triggers on any rank improvement)

## Uninstall

To remove the trigger and function:

```sql
-- Drop trigger
DROP TRIGGER IF EXISTS trigger_rival_activity ON users;

-- Drop function
DROP FUNCTION IF EXISTS check_rival_overtake();
```
