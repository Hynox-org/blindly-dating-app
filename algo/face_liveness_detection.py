#https://docs.google.com/document/d/1X6vrX9ZUnY4R2zgJv4suN5O_tFAdlasQIuE0Qzo6IKw/edit?usp=sharing
import json
import time
import boto3

rekognition = boto3.client("rekognition")

CONFIDENCE_THRESHOLD = 95
MAX_RETRIES = 3


def parse_body(event):
    body = event.get("body")
    if body is None:
        return {}

    if isinstance(body, dict):
        return body

    if isinstance(body, str):
        try:
            return json.loads(body)
        except Exception:
            return {}

    return {}


def lambda_handler(event, context):
    body = parse_body(event)
    action = body.get("action")

    # ---------- START SESSION ----------
    if action == "start":
        response = rekognition.create_face_liveness_session()
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "session_id": response["SessionId"]
            })
        }

    # ---------- GET RESULT ----------
    if action == "result":
        session_id = body.get("session_id")
        if not session_id:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": "session_id missing"})
            }

        for _ in range(MAX_RETRIES):
            result = rekognition.get_face_liveness_session_results(
                SessionId=session_id
            )

            if result["Status"] == "SUCCEEDED":
                confidence = result.get("Confidence", 0)
                return {
                    "statusCode": 200,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps({
                        "status": "SUCCEEDED",
                        "confidence": confidence,
                        "is_live": confidence >= CONFIDENCE_THRESHOLD
                    })
                }

            time.sleep(1)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "status": "TIMEOUT"
            })
        }

    # ---------- INVALID REQUEST ----------
    return {
        "statusCode": 400,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": "Invalid action"})
    }
