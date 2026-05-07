import json
import logging
import os
import urllib.request
import urllib.parse

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
SUPABASE_URL = "https://icvncmawahwbpiohrcxv.supabase.co"
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY")

def fetch_from_supabase(table, select="*", filters=None):
    encoded_select = urllib.parse.quote(select)
    url = f"{SUPABASE_URL}/rest/v1/{table}?select={encoded_select}"
    
    if filters:
        for k, v in filters.items():
            url += f"&{k}=eq.{urllib.parse.quote(str(v))}"
    
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0"
    }
    
    try:
        logger.info(f"FETCHING SUPABASE: {url}")
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        logger.error(f"SUPABASE ERROR {e.code}: {body}")
        raise Exception(f"SUPABASE_ERROR_{e.code}: {body}")

def call_gemini(prompt):
    """Call Gemini using the stable v1 endpoint with fallback to a supported model.
    The API key must have the Generative Language API enabled and billing attached.
    """
    # Try flash first, then pro if flash is unavailable
    for model_name in ("gemini-1.5-flash", "gemini-1.5-pro"):
        url = f"https://generativelanguage.googleapis.com/v1/models/{model_name}:generateContent?key={GOOGLE_API_KEY}"
        data = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.8, "maxOutputTokens": 1000},
        }
        headers = {"Content-Type": "application/json", "User-Agent": "Mozilla/5.0"}
        try:
            logger.info(f"Calling Gemini model {model_name}")
            req = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=15) as response:
                result = json.loads(response.read().decode())
                return result["candidates"][0]["content"]["parts"][0]["text"]
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            logger.error(f"GEMINI_ERROR_{e.code}: {body}")
            # If the model is not found (404), try the next one
            if e.code != 404:
                raise Exception(f"GEMINI_ERROR_{e.code}: {body}")
    # If we exit the loop, none of the models succeeded
    raise Exception("All Gemini model calls failed – check API key and model access.")

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}')) if isinstance(event.get('body'), str) else event
        s_id = body.get('sender_id')
        r_id = body.get('recipient_id')

        if not s_id or not r_id:
            return {"statusCode": 400, "body": json.dumps({"error": "Missing IDs"})}

        query = "*,profile_modes(bio,profile_mode_interestchips(interest_chips(label))),profile_prompts(user_response,prompt_templates(prompt_text))"
        
        sender = fetch_from_supabase("profiles", select=query, filters={"id": s_id})[0]
        recipient = fetch_from_supabase("profiles", select=query, filters={"id": r_id})[0]

        prompt = f"Write 3 icebreakers for {recipient['display_name']} based on {json.dumps(sender, default=str)}. Return JSON only."
        
        ai_response = call_gemini(prompt)
        
        return {
            "statusCode": 200,
            "body": ai_response # Return directly since we asked AI for JSON
        }
    except Exception as e:
        logger.error(f"FATAL ERROR: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}