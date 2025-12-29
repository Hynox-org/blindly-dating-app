# https://docs.google.com/document/d/1o4yAKVF7h2xKkwR7H7Du4kHS0K7M_wc1Sb5Aa4mIznY/edit?usp=sharing

import json
import base64
import boto3
from botocore.exceptions import BotoCoreError, ClientError

# AWS Client
rekognition = boto3.client("rekognition", region_name="ap-south-1")

# ------------------ MODERATION RULES ------------------

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

# ------------------ FACE CONSTRAINTS ------------------

MIN_FACE_CONFIDENCE = 90
MIN_FACE_AREA_RATIO = 0.15   # 15% of image
MAX_FACES_ALLOWED = 1

# ------------------ MODERATION DECISION ------------------

def get_moderation_decision(labels, source):
    for label in labels:
        if label["Name"] in BLOCK_LABELS:
            return "BLOCK"

    for label in labels:
        if label["Name"] in REVIEW_LABELS:
            if source == "verification":
                return "BLOCK"
            elif source == "profile":
                return "REVIEW"
            elif source == "chat":
                return "ALLOW"

    return "ALLOW"

# ------------------ FACE VALIDATION ------------------

def validate_face(image_bytes, source):
    response = rekognition.detect_faces(
        Image={"Bytes": image_bytes},
        Attributes=["ALL"]
    )

    faces = response.get("FaceDetails", [])

    # ❌ No face
    if len(faces) == 0:
        return "BLOCK", "No human face detected"

    # ❌ Multiple faces
    if len(faces) > MAX_FACES_ALLOWED:
        if source == "profile":
            return "REVIEW", "Multiple faces detected"
        return "BLOCK", "Multiple faces not allowed"

    face = faces[0]

    # ❌ Low confidence
    if face["Confidence"] < MIN_FACE_CONFIDENCE:
        return "BLOCK", "Face confidence too low"

    # ❌ Face too small (background-heavy image)
    box = face["BoundingBox"]
    face_area = box["Width"] * box["Height"]

    if face_area < MIN_FACE_AREA_RATIO:
        return "BLOCK", "Face too small in image"

    # ❌ Fake / cartoon face detection (heuristic)
    if not face.get("EyesOpen") or not face.get("MouthOpen"):
        return "BLOCK", "Non-real or unclear face detected"

    return "ALLOW", None

# ------------------ LAMBDA HANDLER ------------------

def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        images = body.get("images")
        source = body.get("source", "profile")  # profile | verification | chat

        if not images or not isinstance(images, list):
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "images must be a non-empty array"})
            }

        results = []

        for index, image_base64 in enumerate(images):
            try:
                image_bytes = base64.b64decode(image_base64)
            except Exception:
                results.append({
                    "imageIndex": index,
                    "decision": "BLOCK",
                    "reason": "Invalid base64 image"
                })
                continue

            # 1️⃣ Face validation first
            face_decision, face_reason = validate_face(image_bytes, source)

            if face_decision != "ALLOW":
                results.append({
                    "imageIndex": index,
                    "decision": face_decision,
                    "reason": face_reason,
                    "labels": []
                })
                continue

            # 2️⃣ Moderation check
            moderation_response = rekognition.detect_moderation_labels(
                Image={"Bytes": image_bytes},
                MinConfidence=70
            )

            labels = moderation_response.get("ModerationLabels", [])
            moderation_decision = get_moderation_decision(labels, source)

            results.append({
                "imageIndex": index,
                "decision": moderation_decision,
                "labels": labels
            })

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(results)
        }

    except (BotoCoreError, ClientError) as e:
        print("AWS ERROR:", str(e))
        raise

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
