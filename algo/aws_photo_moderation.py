# https://docs.google.com/document/d/1o4yAKVF7h2xKkwR7H7Du4kHS0K7M_wc1Sb5Aa4mIznY/edit?usp=sharing

import json
import base64
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from PIL import Image
from io import BytesIO

# ------------------ AWS CLIENT ------------------

rekognition = boto3.client("rekognition")

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
MIN_FACE_AREA_RATIO = 0.15
MAX_FACES_ALLOWED = 1

# ------------------ BODY PARSER ------------------

def parse_body(event):
    if "body" not in event:
        return event

    body = event["body"]

    if event.get("isBase64Encoded"):
        body = base64.b64decode(body).decode("utf-8")

    if isinstance(body, str):
        return json.loads(body)

    return body

# ------------------ EXIF VALIDATION (KEY FEATURE) ------------------

def validate_exif(image_bytes):
    """
    Blocks edited / exported / AI / downloaded images
    """
    try:
        img = Image.open(BytesIO(image_bytes))
        exif = img._getexif()

        if not exif:
            return "BLOCK", "Edited or exported image detected (no EXIF)"

        # Camera Make & Model tags
        CAMERA_MAKE = 271
        CAMERA_MODEL = 272

        if CAMERA_MAKE not in exif or CAMERA_MODEL not in exif:
            return "BLOCK", "Camera metadata missing (possible filtered image)"

        return "ALLOW", None

    except Exception:
        return "BLOCK", "Invalid or manipulated image metadata"

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

    if len(faces) == 0:
        return "BLOCK", "No human face detected"

    if len(faces) > MAX_FACES_ALLOWED:
        if source == "profile":
            return "REVIEW", "Multiple faces detected"
        return "BLOCK", "Multiple faces not allowed"

    face = faces[0]

    if face["Confidence"] < MIN_FACE_CONFIDENCE:
        return "BLOCK", "Face confidence too low"

    box = face["BoundingBox"]
    face_area = box["Width"] * box["Height"]
    if face_area < MIN_FACE_AREA_RATIO:
        return "BLOCK", "Face too small in image"

    return "ALLOW", None

# ------------------ LAMBDA HANDLER ------------------

def handler(event, context):
    try:
        body = parse_body(event)
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
                image_base64 = image_base64.split(",")[-1]
                image_bytes = base64.b64decode(image_base64)
            except Exception:
                results.append({
                    "imageIndex": index,
                    "decision": "BLOCK",
                    "reason": "Invalid base64 image"
                })
                continue

            # ❌ Image size limit (5 MB)
            if len(image_bytes) > 5 * 1024 * 1024:
                results.append({
                    "imageIndex": index,
                    "decision": "BLOCK",
                    "reason": "Image too large"
                })
                continue

            # 1️⃣ EXIF VALIDATION (THIS BLOCKS YOUR IMAGE)
            exif_decision, exif_reason = validate_exif(image_bytes)
            if exif_decision != "ALLOW":
                results.append({
                    "imageIndex": index,
                    "decision": exif_decision,
                    "reason": exif_reason,
                    "labels": []
                })
                continue

            # 2️⃣ FACE VALIDATION
            face_decision, face_reason = validate_face(image_bytes, source)
            if face_decision != "ALLOW":
                results.append({
                    "imageIndex": index,
                    "decision": face_decision,
                    "reason": face_reason,
                    "labels": []
                })
                continue

            # 3️⃣ MODERATION CHECK
            moderation_response = rekognition.detect_moderation_labels(
                Image={"Bytes": image_bytes},
                MinConfidence=70
            )

            labels = moderation_response.get("ModerationLabels", [])
            decision = get_moderation_decision(labels, source)

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

    except (BotoCoreError, ClientError) as e:
        print("AWS ERROR:", str(e))
        raise

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
