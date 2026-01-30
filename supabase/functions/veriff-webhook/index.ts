// File: supabase/functions/veriff-webhook/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

console.log("Veriff Webhook listener is running!")

serve(async (req) => {
  try {
    // 1. Get the JSON data sent by Veriff
    const data = await req.json();
    console.log("Received Webhook from Veriff:", JSON.stringify(data));

    const verification = data.verification;
    if (!verification) {
      return new Response("No verification data", { status: 400 });
    }

    // 2. Extract Key Info
    const status = verification.status; // 'approved', 'declined', 'resubmission_requested'
    const userId = verification.vendorData; // We sent the User ID here in the previous step!

    console.log(`Update User: ${userId} -> Status: ${status}`);

    if (!userId) {
        return new Response("No VendorData (User ID) found", { status: 400 });
    }

    // 3. Connect to Supabase (Admin mode to update users)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // <--- IMPORTANT: Use Service Role Key for Admin rights
    );

    // 4. Update the User's Profile in your Database
    // (Assuming you have a 'profiles' or 'users' table. Adjust table name if needed)
    if (status === 'approved') {
        const { error } = await supabaseAdmin
            .from('profiles') // <--- Make sure this matches your actual table name
            .update({ 
                is_identity_verified: true, // Your column name for verification status
                veriff_session_id: verification.id
            })
            .eq('id', userId);

        if (error) console.error("Database Update Error:", error);
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("Webhook Error:", error.message);
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }
})