# https://docs.google.com/document/d/1o4yAKVF7h2xKkwR7H7Du4kHS0K7M_wc1Sb5Aa4mIznY/edit?usp=sharing

import json
import base64
import boto3
from botocore.exceptions import BotoCoreError, ClientError

rekognition = boto3.client("rekognition", region_name="ap-south-1")

BLOCK_LABELS = {
    "Explicit Nudity",
    "Sexual Activity",
    "Violence",
    "Drugs",
    "Hate Symbols"
}

REVIEW_LABELS = {
    "Suggestive",
    "Alcohol",
    "Tobacco",
    "Gambling"
}

def get_decision(labels, source):
    # Block-level checks (always block)
    for label in labels:
        if label["Name"] in BLOCK_LABELS:
            return "BLOCK"

    # Context-based logic
    for label in labels:
        if label["Name"] in REVIEW_LABELS:
            if source == "verification":
                return "BLOCK"
            elif source == "profile":
                return "REVIEW"
            elif source == "chat":
                return "ALLOW"

    return "ALLOW"


def handler(event, context):
    try:
        body = json.loads(event["body"])
        images = body.get("images")
        source = body.get("source", "profile")  # default

        if not images or not isinstance(images, list):
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "images must be a non-empty array"})
            }

        results = []

        for index, image_base64 in enumerate(images):
            image_bytes = base64.b64decode(image_base64)

            response = rekognition.detect_moderation_labels(
                Image={"Bytes": image_bytes},
                MinConfidence=70
            )

            labels = response["ModerationLabels"]
            decision = get_decision(labels, source)

            results.append({
                "imageIndex": index,
                "decision": decision,
                "labels": labels
            })

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(results)
        }

    except (BotoCoreError, ClientError):
        # AWS fallback
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "status": "PENDING_REVIEW",
                "reason": "Moderation service unavailable"
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
