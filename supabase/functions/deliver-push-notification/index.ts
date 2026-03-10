import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"
import { JWT } from "npm:google-auth-library@9"

// Define the payload structure coming from the Postgres Trigger
interface WebhookPayload {
  type: 'INSERT' | 'UPDATE';
  table: string;
  schema: string;
  record: {
    id: string;
    profile_id: string;
    type: string;
    title: string;
    body: string;
    data: any;
    [key: string]: any;
  };
  old_record: null | any;
}

const getAccessToken = (serviceAccount: any): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens!.access_token!);
    });
  });
};

serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json()
    const record = payload.record

    // 1. Initialize Supabase client
    // We use the service_role key to bypass RLS and read user_push_tokens
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey)

    // 2. Fetch active tokens for the user's profile
    console.log(`Fetching tokens for profile_id: ${record.profile_id}`)
    const { data: tokens, error: tokenError } = await supabase
      .from('user_push_tokens')
      .select('token, platform')
      .eq('profile_id', record.profile_id)

    if (tokenError) {
      throw new Error(`Error fetching tokens: ${tokenError.message}`)
    }

    if (!tokens || tokens.length === 0) {
      console.log(`No tokens found for profile ${record.profile_id}. Skipping push notification.`)
      return new Response(JSON.stringify({ message: "No tokens found" }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      })
    }

    // 3. Prepare FCM logic
    const serviceAccountString = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountString) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT in Supabase Edge Function Secrets.")
    }
    const serviceAccount = JSON.parse(serviceAccountString)
    const projectId = serviceAccount.project_id
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`

    console.log("Generating Google Auth Token...")
    const accessToken = await getAccessToken(serviceAccount)

    const results = []

    for (const device of tokens) {
      console.log(`Sending to device token: ${device.token} (Platform: ${device.platform})`)

      // FCM v1 API requires all values in the data object to be strings.
      // We must stringify the nested JSON to prevent 400 errors from Google.
      const stringifiedData: Record<string, string> = {}

      // Inject the notification ID so the frontend knows which record to mark as read
      stringifiedData['notification_id'] = record.id;

      if (record.data && typeof record.data === 'object') {
        for (const [key, value] of Object.entries(record.data)) {
          stringifiedData[key] = typeof value === 'object' ? JSON.stringify(value) : String(value)
        }
      }

      const fcmResponse = await fetch(fcmUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: device.token,
            notification: {
              title: record.title,
              body: record.body,
            },
            data: stringifiedData, // FCM requires all keys to map to string values
          }
        })
      })

      const responseData = await fcmResponse.json()
      results.push(responseData)

      if (!fcmResponse.ok) {
        console.error(`FCM Error for token ${device.token}:`, responseData)
      } else {
        console.log(`Successfully sent to token ${device.token}`)
      }
    }

    return new Response(
      JSON.stringify({ message: "Push notifications dispatched", results }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      }
    )
  } catch (error: any) {
    console.error("Error processing webhook:", error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})
