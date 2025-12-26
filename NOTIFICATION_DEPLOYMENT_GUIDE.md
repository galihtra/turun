# 🔔 Notification System - Deployment Guide

Panduan lengkap untuk deploy semua 7 kategori notifikasi di aplikasi TuRun.

## 📋 Overview

Sistem notifikasi TuRun memiliki 7 kategori dengan 3 mekanisme berbeda:

| Kategori | Trigger Mechanism | Status |
|----------|------------------|---------|
| 🛡️ **Opportunity** | Auto-generate via Flutter | ✅ Ready |
| ⚠️ **Under Attack** | Event-based via Flutter | ✅ Ready |
| ❌ **Territory Lost** | Event-based via Flutter | ✅ Ready |
| 🏅 **Mission Complete** | Achievement unlock via Flutter | ✅ Ready |
| 🆙 **Level Up** | Points threshold via Flutter | ✅ Ready |
| 👥 **Rival Activity** | Database Trigger (PostgreSQL) | ⚙️ Needs Deploy |
| 💤 **Inactive Reminder** | Edge Function + Cron | ⚙️ Needs Deploy |

---

## 🚀 Quick Start (Flutter App)

### 1. Database Migration

Jalankan migration untuk membuat table `notifications`:

```bash
cd supabase
supabase db push
```

Atau via Supabase Dashboard → SQL Editor:
```sql
-- Copy paste isi file: supabase/migrations/create_notifications_table.sql
```

### 2. Test Notifikasi yang Sudah Berfungsi

Setelah app running, notifikasi ini akan otomatis bekerja:

- ✅ **Opportunity**: Cek halaman notifikasi, harusnya ada notif untuk territory kosong
- ✅ **Under Attack**: Run di territory milik user lain
- ✅ **Territory Lost**: Ambil territory milik user lain dengan pace lebih cepat
- ✅ **Mission Complete**: Unlock achievement (misal: complete first run)
- ✅ **Level Up**: Kumpulkan 100 points dari achievements

---

## 🎯 Deploy Rival Activity (Database Trigger)

### Prerequisites
- Supabase project sudah setup
- Database migrations sudah di-apply

### Step 1: Apply Database Trigger

Via Supabase Dashboard → SQL Editor:

```bash
# Copy paste isi file: supabase/migrations/create_rival_activity_trigger.sql
```

Atau via CLI:
```bash
supabase db push
```

### Step 2: Verify Trigger

Cek apakah trigger sudah ter-install:

```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_rival_activity';
```

Should return 1 row.

### Step 3: Test Rival Activity

1. Buat 2 user dengan points berbeda:
   ```sql
   UPDATE users SET total_points = 100 WHERE username = 'user1';
   UPDATE users SET total_points = 90 WHERE username = 'user2';
   ```

2. Buat user2 overtake user1:
   ```sql
   UPDATE users SET total_points = 110 WHERE username = 'user2';
   ```

3. Check notifikasi:
   ```sql
   SELECT * FROM notifications
   WHERE type = 'rivalActivity'
   ORDER BY created_at DESC;
   ```

   User1 should receive notification: "👥 RIVAL ALERT: @user2 just overtook you..."

### How It Works

- Trigger fires saat `users.total_points` di-update
- AchievementProvider sudah auto-update `total_points` saat achievement unlock
- Trigger calculate ranking dan send notif ke yang disalip
- Cooldown 24 jam untuk prevent spam

📖 **Detail Docs**: `supabase/migrations/README_RIVAL_ACTIVITY.md`

---

## ⏰ Deploy Inactive Reminder (Edge Function + Cron)

### Prerequisites
- Supabase CLI installed: `npm install -g supabase`
- Logged in: `supabase login`
- Project linked: `supabase link --project-ref YOUR_PROJECT_REF`

### Step 1: Deploy Edge Function

```bash
cd supabase
supabase functions deploy check-inactive-users
```

### Step 2: Enable pg_cron Extension

Via Supabase Dashboard → Database → Extensions:
- Enable `pg_cron` extension

### Step 3: Setup Cron Job

Via Supabase Dashboard → SQL Editor:

```sql
-- Enable pg_cron (jika belum)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule function to run daily at 8 AM UTC
SELECT cron.schedule(
  'check-inactive-users-daily',
  '0 8 * * *', -- 8:00 AM UTC setiap hari (3 PM WIB / 4 PM WITA)
  $$
  SELECT
    net.http_post(
      url := 'https://mewashdezyqhineaxzza.supabase.co/functions/v1/check-inactive-users',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ld2FzaGRlenlxaGluZWF4enphIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDkyMTQ5MSwiZXhwIjoyMDcwNDk3NDkxfQ.JR8vLMw6OoNp3R8q3RslkNV-jRVKEdJ1rEN_q-wtnwc'
      ),
      body := '{}'::jsonb
    );
  $$
);
```

**Replace:**
- `YOUR_PROJECT_REF` → Get from Project Settings → General → Reference ID
- `YOUR_SERVICE_ROLE_KEY` → Get from Project Settings → API → service_role key (secret!)

### Step 4: Verify Cron Job

Check scheduled jobs:
```sql
SELECT * FROM cron.job;
```

Should show job named `check-inactive-users-daily`.

### Step 5: Test Manually (Optional)

Test function without waiting for cron:

```bash
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/check-inactive-users' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json'
```

Response:
```json
{
  "success": true,
  "message": "Checked 10 users, sent 3 notifications",
  "notificationsSent": 3
}
```

### How It Works

- Cron runs daily at 8 AM UTC
- Edge function checks all users' last run date
- If user inactive for 3+ days → send notification
- Cooldown 7 days (won't spam same user)

📖 **Detail Docs**: `supabase/functions/check-inactive-users/README.md`

---

## ✅ Verification Checklist

After deployment, verify all notifications work:

- [ ] **Database Table**: `notifications` table exists with RLS policies
- [ ] **Opportunity**: Auto-generates for unclaimed territories
- [ ] **Under Attack**: Fires when running in owned territory
- [ ] **Territory Lost**: Fires when territory is conquered
- [ ] **Mission Complete**: Fires when achievement unlocked
- [ ] **Level Up**: Fires when reaching new level (every 100 points)
- [ ] **Rival Activity**: Database trigger installed and tested
- [ ] **Inactive Reminder**: Edge function deployed and cron scheduled

---

## 📊 Monitoring & Logs

### Check Recent Notifications

```sql
SELECT
  type,
  COUNT(*) as count,
  MAX(created_at) as last_sent
FROM notifications
GROUP BY type
ORDER BY last_sent DESC;
```

### Check Cron Job Status

```sql
-- View cron job runs
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'check-inactive-users-daily')
ORDER BY start_time DESC
LIMIT 10;
```

### View Edge Function Logs

Via Supabase Dashboard → Edge Functions → check-inactive-users → Logs

---

## 🐛 Troubleshooting

### Notifications Not Appearing in App?

1. **Check Supabase data:**
   ```sql
   SELECT * FROM notifications
   WHERE user_id = 'YOUR_USER_ID'
   ORDER BY created_at DESC;
   ```

2. **Check real-time subscription:**
   - Open Flutter app
   - Check logs for: `"Added new real-time notification"` or `"Skipped duplicate notification"`

3. **Check RLS policies:**
   ```sql
   SELECT * FROM notifications WHERE user_id = auth.uid();
   ```

### Rival Activity Not Triggering?

1. Verify trigger exists (see above)
2. Check if `total_points` is being updated:
   ```sql
   SELECT id, username, total_points, updated_at
   FROM users
   ORDER BY updated_at DESC
   LIMIT 5;
   ```
3. Make sure points actually increased (trigger has `WHEN (NEW.total_points > OLD.total_points)`)

### Inactive Reminder Not Sending?

1. Check cron job is scheduled:
   ```sql
   SELECT * FROM cron.job WHERE jobname = 'check-inactive-users-daily';
   ```

2. Check function logs in Supabase Dashboard

3. Test function manually (see Step 5 above)

---

## 🔧 Configuration

### Adjust Inactive Threshold

Edit `supabase/functions/check-inactive-users/index.ts`:

```typescript
const inactiveDaysThreshold = 3 // Change to 5, 7, etc.
```

Then redeploy:
```bash
supabase functions deploy check-inactive-users
```

### Adjust Rival Activity Cooldown

Edit trigger in database:

```sql
-- Change cooldown from 24 hours to 48 hours
-- Edit the function check_rival_overtake()
-- Line: AND created_at > NOW() - INTERVAL '24 hours'
-- To:   AND created_at > NOW() - INTERVAL '48 hours'
```

### Change Cron Schedule

```sql
-- Unschedule current job
SELECT cron.unschedule('check-inactive-users-daily');

-- Reschedule with new time (example: every 6 hours)
SELECT cron.schedule(
  'check-inactive-users-daily',
  '0 */6 * * *',
  $$ ... $$
);
```

---

## 📚 Additional Resources

- **Rival Activity Docs**: `supabase/migrations/README_RIVAL_ACTIVITY.md`
- **Inactive Reminder Docs**: `supabase/functions/check-inactive-users/README.md`
- **Notification Service Code**: `lib/data/services/notification_service.dart`
- **Notification Provider Code**: `lib/data/providers/notification/notification_provider.dart`

---

## 🎉 You're Done!

Semua 7 kategori notifikasi sekarang sudah berfungsi:

1. ✅ **5 kategori** otomatis via Flutter event-based
2. ✅ **1 kategori** via database trigger (Rival Activity)
3. ✅ **1 kategori** via edge function + cron (Inactive Reminder)

Happy running! 🏃‍♂️💨
