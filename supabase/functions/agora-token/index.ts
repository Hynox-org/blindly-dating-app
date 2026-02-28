// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
// deno-lint-ignore-file no-explicit-any

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { RtcTokenBuilder, RtcRole } from "npm:agora-access-token";

// ==============================
// CORS HEADERS
// ==============================
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ==============================
// MAIN HANDLER
// ==============================
serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: corsHeaders }
    );
  }

  try {
    const body = await req.json();
    const channelName = body.channelName;
    const uid = Number(body.uid ?? 0);
    const roleType = body.role ?? "publisher";

    // ==============================
    // VALIDATION
    // ==============================
    if (!channelName || typeof channelName !== "string") {
      return new Response(
        JSON.stringify({ error: "Valid channelName is required" }),
        { status: 400, headers: corsHeaders }
      );
    }

    if (isNaN(uid)) {
      return new Response(
        JSON.stringify({ error: "UID must be a number" }),
        { status: 400, headers: corsHeaders }
      );
    }

    const appId = Deno.env.get("AGORA_APP_ID");
    const appCertificate = Deno.env.get("AGORA_APP_CERTIFICATE");

    if (!appId || !appCertificate) {
      console.error("Missing Agora credentials");
      return new Response(
        JSON.stringify({ error: "Agora credentials not configured" }),
        { status: 500, headers: corsHeaders }
      );
    }

    // ==============================
    // TOKEN CONFIG
    // ==============================
    const role =
      roleType === "subscriber"
        ? RtcRole.SUBSCRIBER
        : RtcRole.PUBLISHER;

    const expirationTimeInSeconds = 3600; // 1 hour
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpireTime =
      currentTimestamp + expirationTimeInSeconds;

    // ==============================
    // GENERATE TOKEN
    // ==============================
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role,
      privilegeExpireTime
    );

    return new Response(
      JSON.stringify({
        token,
        expiresIn: expirationTimeInSeconds,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error: any) {
    console.error("Token generation error:", error);

    return new Response(
      JSON.stringify({
        error: "Internal server error",
      }),
      {
        status: 500,
        headers: corsHeaders,
      }
    );
  }
});
/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/agora-token' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
