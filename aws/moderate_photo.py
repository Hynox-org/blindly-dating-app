"""Profile photo moderation.

The client sends up to six base64 images together with its Supabase access
token. Every image that passes is uploaded from here, straight into the
`user_photos` bucket, and the client only ever learns the storage path of a
photo that was accepted. A rejected photo has no path, so there is nothing the
client can hand to the database later -- moderation is not a suggestion it can
skip.

Decisions are returned as stable codes, never as prose. The app owns the
wording, in six languages; this function owns the verdict.

Environment: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_KEY.
"""

import base64
import json
import logging
import os
import urllib.error
import urllib.request
import uuid
from concurrent.futures import ThreadPoolExecutor

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

rekognition = boto3.client("rekognition", region_name="ap-south-1")

MAX_IMAGES = 6
MAX_IMAGE_BYTES = 5 * 1024 * 1024  # Rekognition's own ceiling for inline bytes
MIN_LABEL_CONFIDENCE = 60.0
MIN_FACE_CONFIDENCE = 95.0
MIN_FACE_WIDTH = 0.08  # a narrower face means a crowd shot, or scenery with a bystander

# Everything Rekognition flags is rejected except these two. Listing what
# passes rather than what fails means a renamed or newly added category lands
# on the reject side, which is the side to fail towards -- the previous
# implementation listed the categories to block and silently stopped matching
# any of them when AWS renamed the taxonomy.
ALLOWED_CATEGORIES = {"Swimwear or Underwear", "Alcohol"}

BUCKET = "user_photos"


def _env():
    url = os.environ.get("SUPABASE_URL", "").rstrip("/")
    anon = os.environ.get("SUPABASE_ANON_KEY", "")
    service = os.environ.get("SUPABASE_SERVICE_KEY", "")
    return (url, anon, service) if url and anon and service else None


# --------------------------------------------------------------- the verdict


def review_labels(labels):
    """Reject on anything flagged outside the allowlist. Returns a code or None.

    Rekognition returns the whole parent chain, so a swimwear photo arrives as
    both the top-level `Swimwear or Underwear` and its narrower children. Only
    the top-level entries are compared; the children add nothing.
    """
    if not labels:
        return None
    top_level = {l["Name"] for l in labels if not l.get("ParentName")}
    if not top_level:
        # Flagged, but in a response shape we don't recognise. Fail closed.
        logger.warning("labels with no top-level entry: %s", labels)
        return "unsafe"
    blocked = top_level - ALLOWED_CATEGORIES
    if blocked:
        logger.info("unsafe: %s", sorted(blocked))
        return "unsafe"
    return None


def review_faces(faces):
    """A profile photo is one person, recognisably. Returns a code or None."""
    usable = [f for f in faces if f.get("Confidence", 0) >= MIN_FACE_CONFIDENCE]
    if not usable:
        return "no_face"
    if len(usable) > 1:
        return "group_photo"
    if usable[0]["BoundingBox"]["Width"] < MIN_FACE_WIDTH:
        return "face_too_small"
    return None


def _decode(value):
    """Base64 in, image bytes out. Raises ValueError carrying a code."""
    if not isinstance(value, str):
        raise ValueError("bad_image")
    if value.startswith("data:"):
        value = value.split(",", 1)[-1]
    try:
        raw = base64.b64decode("".join(value.split()), validate=True)
    except (ValueError, TypeError):
        raise ValueError("bad_image")
    if not raw:
        raise ValueError("bad_image")
    if len(raw) > MAX_IMAGE_BYTES:
        raise ValueError("image_too_large")
    return raw


def _inspect(image_bytes):
    """Moderation first: it is the check worth paying for on the worst photos,
    and clearing it lets us skip the face call entirely."""
    labels = rekognition.detect_moderation_labels(
        Image={"Bytes": image_bytes}, MinConfidence=MIN_LABEL_CONFIDENCE
    )["ModerationLabels"]
    code = review_labels(labels)
    if code:
        return code
    faces = rekognition.detect_faces(
        Image={"Bytes": image_bytes}, Attributes=["DEFAULT"]
    )["FaceDetails"]
    return review_faces(faces)


# ------------------------------------------------------------------ supabase


def _user_id(token, url, anon):
    """Supabase says who the token belongs to. The client never names itself,
    so it cannot write into another user's folder."""
    req = urllib.request.Request(
        f"{url}/auth/v1/user",
        headers={"Authorization": f"Bearer {token}", "apikey": anon},
    )
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            return json.load(response).get("id")
    except (urllib.error.URLError, ValueError):
        return None


def _upload(image_bytes, user_id, url, service):
    path = f"{user_id}/{uuid.uuid4()}.jpg"
    req = urllib.request.Request(
        f"{url}/storage/v1/object/{BUCKET}/{path}",
        data=image_bytes,
        method="POST",
        headers={
            "Authorization": f"Bearer {service}",
            "apikey": service,
            "Content-Type": "image/jpeg",
            "Cache-Control": "3600",
        },
    )
    with urllib.request.urlopen(req, timeout=15) as response:
        response.read()
    return path


# ------------------------------------------------------------------ per image


def _process(value, user_id, url, service):
    try:
        image_bytes = _decode(value)
    except ValueError as e:
        return {"decision": "ERROR", "code": str(e)}

    try:
        code = _inspect(image_bytes)
    except ClientError as e:
        aws_code = e.response.get("Error", {}).get("Code", "")
        if aws_code in ("InvalidImageFormatException", "InvalidParameterException"):
            return {"decision": "ERROR", "code": "bad_image"}
        if aws_code == "ImageTooLargeException":
            return {"decision": "ERROR", "code": "image_too_large"}
        logger.exception("rekognition unavailable")
        return {"decision": "ERROR", "code": "unavailable"}
    except Exception:
        logger.exception("rekognition call failed")
        return {"decision": "ERROR", "code": "unavailable"}

    if code:
        return {"decision": "REJECT", "code": code}

    try:
        path = _upload(image_bytes, user_id, url, service)
    except Exception:
        logger.exception("upload failed")
        return {"decision": "ERROR", "code": "unavailable"}
    return {"decision": "ALLOW", "code": "ok", "path": path}


# -------------------------------------------------------------------- handler


def _reply(status, payload):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }


def lambda_handler(event, context):
    env = _env()
    if env is None:
        logger.error("missing SUPABASE_* environment")
        return _reply(500, {"error": "misconfigured"})
    url, anon, service = env

    headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}
    auth = headers.get("authorization", "")
    token = auth.split()[-1] if auth else ""
    if not token:
        return _reply(401, {"error": "unauthorized"})

    body = event.get("body") or "{}"
    try:
        payload = json.loads(body) if isinstance(body, str) else body
        images = payload["images"]
    except (ValueError, TypeError, KeyError):
        return _reply(400, {"error": "no_images"})

    if not isinstance(images, list) or not images:
        return _reply(400, {"error": "no_images"})
    if len(images) > MAX_IMAGES:
        return _reply(400, {"error": "too_many_images"})

    user_id = _user_id(token, url, anon)
    if not user_id:
        return _reply(401, {"error": "unauthorized"})

    with ThreadPoolExecutor(max_workers=MAX_IMAGES) as pool:
        results = list(
            pool.map(lambda v: _process(v, user_id, url, service), images)
        )

    logger.info("user=%s results=%s", user_id, [r["code"] for r in results])
    return _reply(200, {"results": results})
