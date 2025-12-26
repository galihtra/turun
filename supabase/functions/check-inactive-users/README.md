# Check Inactive Users - Edge Function

This Supabase Edge Function checks for inactive users (users who haven't run in 3+ days) and sends them reminder notifications.

## Deployment

1. **Deploy the function:**
   ```bash
   supabase functions deploy check-inactive-users
   ```

2. **Set up cron job to run daily at 8 AM UTC:**

   Using Supabase Dashboard:
   - Go to Database → Extensions
   - Enable `pg_cron` extension if not already enabled
   - Go to Database → Database
   - Run this SQL:

   ```sql
   -- Enable pg_cron extension
   CREATE EXTENSION IF NOT EXISTS pg_cron;

   -- Schedule the function to run daily at 8 AM UTC
   SELECT cron.schedule(
     'check-inactive-users-daily',
     '0 8 * * *', -- Run at 8:00 AM UTC every day
     $$
     SELECT
       net.http_post(
         url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/check-inactive-users',
         headers := jsonb_build_object(
           'Content-Type', 'application/json',
           'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
         ),
         body := '{}'::jsonb
       );
     $$
   );
   ```

   Replace:
   - `YOUR_PROJECT_REF` with your Supabase project reference
   - `YOUR_SERVICE_ROLE_KEY` with your service role key from Project Settings → API

3. **View scheduled jobs:**
   ```sql
   SELECT * FROM cron.job;
   ```

4. **Delete/unschedule job if needed:**
   ```sql
   SELECT cron.unschedule('check-inactive-users-daily');
   ```

## Manual Testing

You can test the function manually using curl:

```bash
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/check-inactive-users' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json'
```

## How It Works

1. Fetches all users from the database
2. For each user, checks their most recent completed run
3. Calculates days since last run
4. If user has been inactive for 3+ days:
   - Checks if we already sent a reminder in the last 7 days (to avoid spam)
   - If not, sends an "Inactive Reminder" notification
5. Returns summary of how many users checked and notifications sent

## Configuration

- **Inactive threshold**: 3 days (configurable in code)
- **Reminder cooldown**: 7 days (won't send another reminder within 7 days)
- **Schedule**: Daily at 8 AM UTC (configurable in cron)

## Notification Details

- **Title**: "💤 WAKE UP, SOLDIER"
- **Message**: "Your legs are getting rusty. Run for 15 mins today to stay combat-ready!"
- **Type**: `inactiveReminder`
