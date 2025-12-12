# 🚀 Quick Setup Guide - Run Tracking Feature

## Step 1: Database Setup (5 minutes)

### Option A: Run Sessions Only (Recommended if territories table exists)
```sql
-- Go to Supabase Dashboard → SQL Editor
-- Copy and paste the entire content of:
SUPABASE_RUN_SESSIONS_ONLY.sql
-- Click "Run" or press Ctrl+Enter
```

### Option B: Full Schema (If starting fresh)
```sql
-- Go to Supabase Dashboard → SQL Editor
-- Copy and paste the entire content of:
SUPABASE_SCHEMA.sql
-- Click "Run" or press Ctrl+Enter
```

**Expected Result:**
- ✅ Table `run_sessions` created
- ✅ 5 indexes created
- ✅ RLS enabled with 5 policies
- ✅ 2 helper functions created

## Step 2: Verify Database Setup

Run this query in Supabase SQL Editor:
```sql
-- Check if table exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'run_sessions'
ORDER BY ordinal_position;
```

You should see 15 columns including:
- id (uuid)
- user_id (uuid)
- territory_id (integer)
- distance_meters (double precision)
- average_pace_min_per_km (double precision)
- route_points (jsonb)
- status (text)
- etc.

## Step 3: Test the App

### 3.1 Launch App
```bash
flutter run
```

### 3.2 Navigate to Territory
1. Open app → Go to Running/Map page
2. Select any territory on the map
3. Tap "Go to Location"
4. Follow the blue route line

### 3.3 Start Run
1. When you arrive at territory → "You've arrived!" notification appears
2. Tap "Start Run" button
3. You'll be taken to Run Tracking Screen

### 3.4 During Run
- Watch live metrics update:
  - ⏱️ Duration (updates every second)
  - 📏 Distance (updates every ~5 meters)
  - ⚡ Pace (in min/km)
  - 🏃 Speed (in km/h)
- Green polyline shows your route
- Use buttons: Pause, Resume, Cancel

### 3.5 Finish Run
1. Tap "Finish" button
2. Confirm in dialog
3. View completion screen with:
   - All run statistics
   - Territory conquest status
   - Celebration if you conquered!

## Step 4: Test Territory Conquest

### Scenario 1: First Runner (Territory Unclaimed)
```
1. Select unclaimed territory (no owner)
2. Complete run with any pace
Result: ✅ Territory conquered! (You're the first owner)
```

### Scenario 2: Beat Current Record
```
1. Select territory owned by someone else
2. Complete run with FASTER pace than current owner
Result: ✅ Territory conquered! (You took over)
```

### Scenario 3: Slower Than Record
```
1. Select territory with owner
2. Complete run with SLOWER pace
Result: ❌ Keep improving! (No conquest, but run recorded)
```

## Step 5: Check Database

After completing a run, verify in Supabase:

```sql
-- View your runs
SELECT
    id,
    distance_meters,
    duration_seconds,
    average_pace_min_per_km,
    status,
    territory_conquered,
    created_at
FROM run_sessions
ORDER BY created_at DESC
LIMIT 5;
```

```sql
-- View territory ownership changes
SELECT
    t.id,
    t.name,
    t.owner_id,
    rs.average_pace_min_per_km as best_pace
FROM territories t
LEFT JOIN run_sessions rs ON rs.territory_id = t.id AND rs.user_id = t.owner_id
WHERE t.owner_id IS NOT NULL
ORDER BY t.id;
```

## Common Issues & Solutions

### Issue 1: GPS Not Working
**Symptoms:** "Using default location" warning
**Solution:**
1. Check app has location permissions
2. Enable GPS on device
3. Go outside or near window for better signal

### Issue 2: Can't Start Run
**Symptoms:** "Start Run" button doesn't appear
**Solution:**
1. Make sure you're inside the territory polygon
2. Check GPS accuracy (may take few seconds to get accurate position)
3. Try moving around a bit within territory

### Issue 3: Route Not Showing
**Symptoms:** No green line during run
**Solution:**
1. Check internet connection (needs Google Directions API)
2. Move at least 5 meters (distance filter)
3. Wait few seconds for GPS to stabilize

### Issue 4: Database Error
**Symptoms:** "Failed to save run session"
**Solution:**
1. Check Supabase connection in `.env`
2. Verify RLS policies are created
3. Check user is authenticated
4. View Supabase logs for details

### Issue 5: Pace Calculation Seems Wrong
**Note:** Pace is calculated as `duration_minutes / distance_km`
- Lower number = Faster pace
- Example: 5'30" per km is faster than 6'00" per km
- Make sure you moved enough distance (minimum ~100m recommended)

## Performance Tips

### For Best GPS Accuracy:
1. ✅ Use outdoors with clear sky view
2. ✅ Wait 10-20 seconds before starting run
3. ✅ Keep phone in pocket or armband (not in bag)
4. ❌ Avoid starting run indoors
5. ❌ Don't use in areas with tall buildings (GPS bounce)

### For Smooth Experience:
1. ✅ Have stable internet connection
2. ✅ Close other GPS apps
3. ✅ Enable high accuracy mode in phone settings
4. ✅ Disable battery saver during runs
5. ✅ Keep app in foreground

## Testing Checklist

- [ ] Database setup successful
- [ ] App launches without errors
- [ ] Can see territories on map
- [ ] Can navigate to territory
- [ ] "Start Run" button appears at territory
- [ ] Run tracking screen shows
- [ ] Metrics update in real-time
- [ ] Can pause/resume run
- [ ] Can finish run successfully
- [ ] Completion screen shows correct stats
- [ ] Territory conquest logic works
- [ ] Data saved to Supabase

## Next Steps

### For Development:
1. **Add Leaderboard UI**: Show top 10 runners per territory
2. **User Profile**: Show territories owned and stats
3. **Run History**: List all past runs with details
4. **Achievements**: Badges for milestones
5. **Social Features**: Share runs, challenge friends

### For Production:
1. **Error Monitoring**: Setup Sentry or similar
2. **Analytics**: Track user behavior
3. **Performance**: Optimize GPS battery usage
4. **Testing**: Unit tests for pace calculations
5. **Documentation**: User guide in app

## Support

If you encounter issues:

1. **Check Logs:**
   ```dart
   // Look for AppLogger output in console
   AppLogger.error(LogLabel.general, 'Error message', error);
   ```

2. **Supabase Dashboard:**
   - View logs in Logs section
   - Check API usage
   - Verify data in Table Editor

3. **Debug Mode:**
   ```bash
   flutter run --verbose
   ```

## Success Indicators

Your setup is successful when:

✅ You can complete a full run cycle
✅ Data appears in Supabase run_sessions table
✅ Territory ownership updates correctly
✅ Metrics are calculated accurately
✅ UI is smooth and responsive
✅ GPS tracking is accurate
✅ No crashes or errors

## Congratulations! 🎉

Your run tracking system is now live! Users can:
- Track their runs with GPS
- Compete for territory ownership
- View detailed run statistics
- Celebrate conquests

**Happy Running!** 🏃‍♂️💨
