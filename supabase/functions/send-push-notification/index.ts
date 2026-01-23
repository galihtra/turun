// Supabase Edge Function to send FCM push notifications
// Triggered by database webhook when new notification is inserted

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationPayload {
  type: 'INSERT'
  table: string
  record: {
    id: string
    user_id: string
    title: string
    message: string
    type: string
    territory_id?: number
    territory_name?: string
    created_at: string
  }
}

interface FCMMessage {
  message: {
    token: string
    notification: {
      title: string
      body: string
    }
    data?: Record<string, string>
    android?: {
      priority: string
      notification: {
        channel_id: string
        sound: string
      }
    }
    apns?: {
      payload: {
        aps: {
          sound: string
          badge: number
        }
      }
    }
  }
}

async function getAccessToken(serviceAccount: any): Promise<string> {
  // Create JWT header
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  }

  // Create JWT claims
  const now = Math.floor(Date.now() / 1000)
  const claims = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  }

  // Encode header and claims
  const encoder = new TextEncoder()
  const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const claimsB64 = btoa(JSON.stringify(claims)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const unsignedToken = `${headerB64}.${claimsB64}`

  // Import private key and sign
  const privateKeyPem = serviceAccount.private_key
  const pemContents = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')
  
  const binaryKey = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0))
  
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    encoder.encode(unsignedToken)
  )

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')

  const jwt = `${unsignedToken}.${signatureB64}`

  // Exchange JWT for access token
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

async function sendFCMNotification(
  accessToken: string,
  projectId: string,
  fcmToken: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<boolean> {
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`

  const message: FCMMessage = {
    message: {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data,
      android: {
        priority: 'high',
        notification: {
          channel_id: 'turun_notifications',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    },
  }

  const response = await fetch(fcmUrl, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(message),
  })

  if (!response.ok) {
    const error = await response.text()
    console.error('FCM Error:', error)
    return false
  }

  return true
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse the webhook payload
    const payload: NotificationPayload = await req.json()
    
    console.log('Received notification webhook:', payload.record?.id)

    // Only process INSERT events
    if (payload.type !== 'INSERT') {
      return new Response(
        JSON.stringify({ message: 'Not an INSERT event, skipping' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
      )
    }

    const notification = payload.record
    if (!notification) {
      throw new Error('No notification record in payload')
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get user's FCM token
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('fcm_token, username')
      .eq('id', notification.user_id)
      .single()

    if (userError) {
      console.error('Error fetching user:', userError)
      throw userError
    }

    if (!user?.fcm_token) {
      console.log(`User ${notification.user_id} has no FCM token, skipping push notification`)
      return new Response(
        JSON.stringify({ message: 'User has no FCM token', skipped: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
      )
    }

    // Get Firebase service account from environment
    const firebaseServiceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!firebaseServiceAccountJson) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT not configured')
    }

    const serviceAccount = JSON.parse(firebaseServiceAccountJson)
    const projectId = serviceAccount.project_id

    // Get access token for FCM
    const accessToken = await getAccessToken(serviceAccount)

    // Prepare notification data
    const notificationData: Record<string, string> = {
      notification_id: notification.id,
      type: notification.type,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    }

    if (notification.territory_id) {
      notificationData.territory_id = notification.territory_id.toString()
    }
    if (notification.territory_name) {
      notificationData.territory_name = notification.territory_name
    }

    // Send FCM notification
    const success = await sendFCMNotification(
      accessToken,
      projectId,
      user.fcm_token,
      notification.title,
      notification.message,
      notificationData
    )

    if (success) {
      console.log(`✅ Push notification sent to ${user.username}`)
    } else {
      console.log(`❌ Failed to send push notification to ${user.username}`)
    }

    return new Response(
      JSON.stringify({
        success,
        message: success ? 'Push notification sent' : 'Failed to send push notification',
        user_id: notification.user_id,
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
