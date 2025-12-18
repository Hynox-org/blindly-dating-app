import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Keys
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const TWILIO_SID = Deno.env.get('TWILIO_ACCOUNT_SID')!
const TWILIO_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN')!
const TWILIO_MSG_SID = Deno.env.get('TWILIO_MESSAGE_SERVICE_SID')!
const MSG91_AUTH_KEY = Deno.env.get('MSG91_AUTH_KEY')!

const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

serve(async (req) => {
  try {
    const { user, sms } = await req.json()
    const phone = user.phone 
    const otp = sms.otp
    
    // --- 🛑 RATE LIMIT CHECK ---
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000).toISOString()
    const { count, error } = await supabaseAdmin
      .from('otp_logs')
      .select('*', { count: 'exact', head: true })
      .eq('phone', phone)
      .gte('created_at', tenMinutesAgo)

    if (count && count >= 3) {
      console.error(`🚫 Rate Limit Exceeded for ${phone}`)
      // FIX 1: Added Header here
      return new Response(JSON.stringify({ error: "Too many requests" }), {
        status: 429,
        headers: { "Content-Type": "application/json" } 
      })
    }

    // Log attempt
    await supabaseAdmin.from('otp_logs').insert({ phone: phone })

    const message = `${otp} is your verification code for Blindly. Valid for 10 mins. Team Blindly`
    console.log(`🚀 Attempting to send OTP to ${phone}`)

    // --- ATTEMPT 1: TWILIO ---
    try {
      const twilioResp = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_SID}/Messages.json`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic ' + btoa(`${TWILIO_SID}:${TWILIO_TOKEN}`),
          },
          body: new URLSearchParams({
            To: phone,
            MessagingServiceSid: TWILIO_MSG_SID,
            Body: message,
          }),
        }
      )

      if (twilioResp.ok) {
        console.log("✅ Twilio Success")
        // FIX 2: Added Header here (Success Case)
        return new Response(JSON.stringify({ success: true }), { 
            status: 200,
            headers: { "Content-Type": "application/json" }
        })
      } else {
        console.error("⚠️ Twilio Failed. Switching to Backup...")
      }
    } catch (error) {
      console.error("⚠️ Twilio Error:", error)
    }

    // --- ATTEMPT 2: MSG91 ---
    try {
      const cleanPhone = phone.replace('+', '')
      const msg91Resp = await fetch("https://api.msg91.com/api/v5/flow/", {
        method: "POST",
        headers: {
          "authkey": MSG91_AUTH_KEY,
          "content-type": "application/json"
        },
        body: JSON.stringify({
          "template_id": "YOUR_MSG91_TEMPLATE_ID", 
          "recipients": [{ "mobiles": cleanPhone, "otp": otp }]
        })
      })

      if (msg91Resp.ok) {
        console.log("✅ MSG91 Backup Success")
        // FIX 3: Added Header here (Backup Success Case)
        return new Response(JSON.stringify({ success: true }), { 
            status: 200, 
            headers: { "Content-Type": "application/json" }
        })
      } else {
        throw new Error("All providers failed")
      }
    } catch (error) {
      // FIX 4: Added Header here (Failure Case)
      return new Response(JSON.stringify({ error: "Failed to send SMS" }), { 
          status: 500,
          headers: { "Content-Type": "application/json" }
      })
    }

  } catch (err) {
    // FIX 5: Added Header here (Catch-all)
    return new Response(JSON.stringify({ error: err.message }), { 
        status: 500,
        headers: { "Content-Type": "application/json" }
    })
  }
})