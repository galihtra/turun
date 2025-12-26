// Supabase Edge Function to check for inactive users and send notifications
// This function should be scheduled to run daily via cron

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface User {
  id: string
  full_name: string
  username: string
}

interface RunSession {
  start_time: string
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    console.log('Starting inactive users check...')

    // Get all users
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id, full_name, username')

    if (usersError) {
      throw usersError
    }

    console.log(`Found ${users?.length || 0} users to check`)

    let notificationsSent = 0
    const inactiveDaysThreshold = 3 // Days of inactivity before sending reminder

    // Check each user's last run
    for (const user of users as User[]) {
      // Get user's most recent run
      const { data: lastRun, error: runError } = await supabase
        .from('run_sessions')
        .select('start_time')
        .eq('user_id', user.id)
        .eq('status', 'completed')
        .order('start_time', { ascending: false })
        .limit(1)
        .maybeSingle()

      if (runError) {
        console.error(`Error checking runs for user ${user.id}:`, runError)
        continue
      }

      // Calculate days since last run
      let daysSinceLastRun = 999 // Default to very high number if no runs

      if (lastRun) {
        const lastRunDate = new Date((lastRun as RunSession).start_time)
        const now = new Date()
        const diffTime = Math.abs(now.getTime() - lastRunDate.getTime())
        daysSinceLastRun = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      }

      // Send notification if inactive for threshold days or more
      if (daysSinceLastRun >= inactiveDaysThreshold) {
        // Check if we already sent a reminder in the last 7 days to avoid spam
        const sevenDaysAgo = new Date()
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

        const { data: recentReminders } = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('type', 'inactiveReminder')
          .gte('created_at', sevenDaysAgo.toISOString())

        // Skip if already sent reminder recently
        if (recentReminders && recentReminders.length > 0) {
          console.log(`Skipping user ${user.username} - already reminded recently`)
          continue
        }

        // Send inactive reminder notification
        const { error: notifError } = await supabase
          .from('notifications')
          .insert({
            user_id: user.id,
            title: '💤 WAKE UP, SOLDIER',
            message: 'Your legs are getting rusty. Run for 15 mins today to stay combat-ready!',
            type: 'inactiveReminder',
            is_read: false,
          })

        if (notifError) {
          console.error(`Failed to send notification to ${user.username}:`, notifError)
        } else {
          console.log(`✅ Sent inactive reminder to ${user.username} (${daysSinceLastRun} days inactive)`)
          notificationsSent++
        }
      } else {
        console.log(`User ${user.username} is active (last run ${daysSinceLastRun} days ago)`)
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Checked ${users?.length || 0} users, sent ${notificationsSent} notifications`,
        notificationsSent,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
