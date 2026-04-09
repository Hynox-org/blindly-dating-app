import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

// Initialize Supabase client once
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey)

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const logAudit = async (message_id: string, profile_id: string | null, step: string, status: string, details: any = {}) => {
  try {
    await supabase.from('notification_audit_logs').insert({
      message_id,
      profile_id,
      step,
      status,
      details
    });
  } catch (e) {
    console.error(`Audit Log Failed: ${e.message}`);
  }
};

serve(async (req) => {
  let currentMsgId = "unknown";
  try {
    const { message_id } = await req.json()
    currentMsgId = message_id;
    console.log(`Received trigger for message_id: ${message_id}`)

    if (!message_id) {
       return new Response(JSON.stringify({ error: "Missing message_id" }), { status: 400 })
    }

    await logAudit(message_id, null, 'edge_start', 'success', { info: 'Starting 5s delay check' });

    // 1. WhatsApp-Style Delay: Wait 5 seconds to give time for foreground reading
    await delay(5000)

    // 2. Fetch Message & Recipient details
    const { data: message, error: messageError } = await supabase
      .from('messages')
      .select('*, sender:profiles!fk_sender(display_name)')
      .eq('id', message_id)
      .single()

    if (messageError || !message) {
      await logAudit(message_id, null, 'edge_check', 'skipped', { 
        error: messageError ? messageError.message : 'Message not found',
        code: messageError?.code
      });
      return new Response(JSON.stringify({ message: "Message not found" }), { status: 200 })
    }

    // ✅ INSTAGRAM-STYLE: Only notify if the message has NOT been read yet
    if (message.is_read || message.read_at !== null) {
      await logAudit(message_id, message.receiver_profile_id, 'edge_check', 'skipped', { reason: 'Already read' });
      return new Response(JSON.stringify({ message: "Message already read" }), { status: 200 })
    }

    // 3. Prepare Notification Content
    const senderName = message.sender?.display_name || "Someone"
    
    // 4. Insert into Notifications table
    // This will trigger the 'deliver-push-notification' Edge Function automatically
    const { error: notifyError } = await supabase.from('notifications').insert({
      profile_id: message.receiver_profile_id,
      type: 'chat_message',
      title: `${senderName} sent you a message`,
      body: `Tap to reveal the message`,
      data: {
        message_id: message.id,
        match_id: message.match_id,
        route: '/chat_conversation'
      }
    });

    if (notifyError) {
      throw new Error(`Failed to insert notification: ${notifyError.message}`);
    }

    await logAudit(message_id, message.receiver_profile_id, 'edge_notification_inserted', 'success');

    return new Response(JSON.stringify({ message: "Notification inserted into queue" }), { status: 200 })
  } catch (error: any) {
    console.error("Error processing chat notification:", error.message)
    await logAudit(currentMsgId, null, 'edge_error', 'error', { error: error.message });
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})
