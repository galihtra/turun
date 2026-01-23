-- Migration to add database webhook trigger for push notifications
-- This trigger calls the send-push-notification Edge Function when a new notification is inserted

-- Create the trigger function
CREATE OR REPLACE FUNCTION notify_push_notification()
RETURNS trigger AS $$
DECLARE
  payload json;
BEGIN
  -- Build the payload
  payload := json_build_object(
    'type', TG_OP,
    'table', TG_TABLE_NAME,
    'record', row_to_json(NEW)
  );

  -- Call the Edge Function via pg_net extension
  -- Note: You need to enable pg_net extension first: CREATE EXTENSION IF NOT EXISTS pg_net;
  PERFORM net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-push-notification',
    headers := json_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
    )::jsonb,
    body := payload::jsonb
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on notifications table
DROP TRIGGER IF EXISTS on_notification_insert ON notifications;
CREATE TRIGGER on_notification_insert
  AFTER INSERT ON notifications
  FOR EACH ROW
  EXECUTE FUNCTION notify_push_notification();

-- Note: Alternative approach using Supabase Database Webhooks (GUI)
-- If pg_net is not available, you can set up a Database Webhook in Supabase Dashboard:
-- 1. Go to Database > Webhooks
-- 2. Create new webhook
-- 3. Table: notifications
-- 4. Events: INSERT
-- 5. URL: Your Edge Function URL (https://your-project.supabase.co/functions/v1/send-push-notification)
-- 6. HTTP Method: POST
-- 7. Headers: Content-Type: application/json, Authorization: Bearer <service_role_key>
