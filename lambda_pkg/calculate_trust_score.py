import os
import json
import logging
from datetime import datetime, timedelta, timezone

import psycopg2
import psycopg2.extras

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------------------------------------------------
# DB connection
# ---------------------------------------------------------------------

def get_db_connection():
    """Read DATABASE_URL from the Lambda environment variable and return a psycopg2 connection."""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise ValueError("DATABASE_URL environment variable is missing")
    conn = psycopg2.connect(database_url)
    conn.cursor_factory = psycopg2.extras.RealDictCursor
    psycopg2.extras.register_uuid(conn_or_curs=conn)
    return conn

# ---------------------------------------------------------------------
# 1. PROFILE COMPLETENESS (max 50)
# ---------------------------------------------------------------------

def score_core_profile(profile: dict) -> int:
    """Section A – core fields from the profiles table (max 25 points)."""
    pts = 0
    def filled(v):
        return v is not None and str(v).strip() != ""
    if filled(profile.get("display_name")):                     pts += 3
    if filled(profile.get("birth_date")):                       pts += 3
    if filled(profile.get("gender")):                           pts += 2
    if filled(profile.get("city")) and filled(profile.get("state")): pts += 2
    if profile.get("height_cm") is not None:                    pts += 1
    if filled(profile.get("work_title")) or filled(profile.get("work_company")):
        pts += 2
    if filled(profile.get("education_school")) or filled(profile.get("education_level")):
        pts += 2
    if filled(profile.get("sexual_orientation")):               pts += 1
    if filled(profile.get("relationship_type")):                pts += 1
    if filled(profile.get("dating_intention")):                 pts += 2
    if filled(profile.get("kids_preference")):
        pts += 1
    if filled(profile.get("drinking")) and filled(profile.get("smoking")) and filled(profile.get("exercise")):
        pts += 2
    if filled(profile.get("religion")) or filled(profile.get("star_sign")):
        pts += 1
    if profile.get("pronouns") not in (None, "prefer_not"):
        pts += 2
    return min(pts, 25)

def score_mode_profile(cur, profile_id: str, mode: str, max_pts: int) -> int:
    """Sections B & C – per‑mode scoring (max 13 for date, 12 for bff)."""
    pts = 0
    # Fetch active mode row
    cur.execute(
        """
        SELECT id, bio, looking_for
        FROM   profile_modes
        WHERE  profile_id = %s
          AND  mode       = %s
          AND  is_active  = true
        LIMIT 1
        """,
        (profile_id, mode),
    )
    mode_row = cur.fetchone()
    if not mode_row:
        return 0
    mode_id = mode_row["id"]
    # Bio length >= 30 chars
    bio = mode_row.get("bio") or ""
    if len(bio.strip()) >= 30:
        pts += 2
    # Approved photos
    cur.execute(
        """
        SELECT COUNT(*) AS cnt
        FROM   profile_mode_media
        WHERE  profile_mode_id   = %s
          AND  media_type        = 'photo'
          AND  moderation_status = 'approved'
          AND  is_deleted        = false
        """,
        (mode_id,),
    )
    photo_count = cur.fetchone()["cnt"]
    if photo_count >= 1:
        pts += 2
    if photo_count >= 3:
        pts += 2
    # Prompts
    cur.execute(
        """
        SELECT COUNT(*) AS cnt
        FROM   profile_mode_prompts
        WHERE  profile_mode_id = %s
        """,
        (mode_id,),
    )
    prompt_count = cur.fetchone()["cnt"]
    if prompt_count >= 1:
        pts += 2
    if prompt_count >= 2:
        pts += 1
    # Interest chips
    cur.execute(
        """
        SELECT 1 FROM profile_mode_interestchips WHERE profile_mode_id = %s LIMIT 1
        """,
        (mode_id,),
    )
    if cur.fetchone():
        pts += 1
    # Lifestyle chips
    cur.execute(
        """
        SELECT 1 FROM profile_mode_lifestylechips WHERE profile_mode_id = %s LIMIT 1
        """,
        (mode_id,),
    )
    if cur.fetchone():
        pts += 1
    # looking_for array
    looking_for = mode_row.get("looking_for") or []
    if looking_for:
        pts += 2 if mode == "date" else 1
    return min(pts, max_pts)

def calc_profile_completeness(cur, profile_id: str, profile: dict) -> dict:
    a = score_core_profile(profile)
    b = score_mode_profile(cur, profile_id, "date", 13)
    c = score_mode_profile(cur, profile_id, "bff", 12)
    total = min(a + b + c, 50)
    return {"core": a, "date_mode": b, "bff_mode": c, "total": total}

# ---------------------------------------------------------------------
# 2. VERIFICATION (max 30)
# ---------------------------------------------------------------------

def calc_verification(profile: dict) -> dict:
    level = profile.get("verification_level") or "unverified"
    is_verified = bool(profile.get("is_verified", False))
    score_map = {"unverified": 0, "liveness_only": 10, "full_verified": 20}
    pts = score_map.get(level, 0)
    if level == "full_verified" and is_verified:
        pts = 30
    return {"level": level, "is_verified": is_verified, "total": pts}

# ---------------------------------------------------------------------
# 3. ACTIVITY & BEHAVIOR (max 20)
# ---------------------------------------------------------------------

def calc_activity(cur, profile_id: str, profile: dict) -> dict:
    now = datetime.now(timezone.utc)
    # Recency
    last_active = profile.get("last_active")
    recency_pts = 0
    if last_active:
        if isinstance(last_active, str):
            last_active = datetime.fromisoformat(last_active.replace("Z", "+00:00"))
        days = (now - last_active).days
        if   days <= 1:  recency_pts = 10
        elif days <= 3:  recency_pts = 8
        elif days <= 7:  recency_pts = 5
        elif days <= 14: recency_pts = 2
    # Engagement – profile_views in last 7 days
    week_ago = now - timedelta(days=7)
    cur.execute(
        """
        SELECT COUNT(*) AS cnt FROM profile_views WHERE viewed_profile_id = %s AND created_at >= %s
        """,
        (profile_id, week_ago),
    )
    view_count = cur.fetchone()["cnt"]
    if   view_count == 0:  engagement_pts = 0
    elif view_count <= 5:  engagement_pts = 3
    elif view_count <= 15: engagement_pts = 5
    else:                  engagement_pts = 7
    # Safety penalty – flags in last 30 days
    user_id = profile.get("user_id")
    month_ago = now - timedelta(days=30)
    cur.execute(
        """
        SELECT COUNT(*) AS cnt FROM safety_flags WHERE user_id = %s AND created_at >= %s
        """,
        (user_id, month_ago),
    )
    flag_count = cur.fetchone()["cnt"]
    if   flag_count == 0:  penalty = 0
    elif flag_count == 1:  penalty = 3
    elif flag_count == 2:  penalty = 6
    else:                  penalty = 10
    total = max(0, min(recency_pts + engagement_pts - penalty, 20))
    return {"recency": recency_pts, "engagement": engagement_pts, "safety_penalty": penalty, "total": total}

# ---------------------------------------------------------------------
# Derived flag – is_verified based on trust_score & verification level
# ---------------------------------------------------------------------

def derive_is_verified(trust_score: int, verification: dict) -> bool:
    return trust_score >= 85 and verification["level"] == "full_verified"

# ---------------------------------------------------------------------
# Lambda handler
# ---------------------------------------------------------------------

def lambda_handler(event, context):
    profile_id = (event.get("profile_id") or "").strip()
    if not profile_id:
        return {"statusCode": 400, "body": json.dumps({"error": "profile_id is required"})}

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Fetch profile row (core fields needed for scoring)
        cur.execute(
            """
            SELECT id, user_id,
                   display_name, birth_date, gender,
                   city, state, height_cm,
                   work_title, work_company,
                   education_school, education_level,
                   sexual_orientation, relationship_type,
                   dating_intention, kids_preference,
                   drinking, smoking, exercise,
                   religion, star_sign,
                   pronouns, verification_level, is_verified,
                   last_active
            FROM profiles
            WHERE id = %s
            LIMIT 1
            """,
            (profile_id,),
        )
        profile = cur.fetchone()
        if not profile:
            return {"statusCode": 404, "body": json.dumps({"error": f"Profile {profile_id} not found"})}
        profile = dict(profile)
        # Calculate components
        completeness = calc_profile_completeness(cur, profile_id, profile)
        verification = calc_verification(profile)
        activity = calc_activity(cur, profile_id, profile)
        trust_score = min(100, completeness["total"] + verification["total"] + activity["total"])
        is_verified_flag = derive_is_verified(trust_score, verification)
        # Write back to DB
        cur.execute(
            """
            UPDATE profiles
            SET trust_score = %s,
                is_verified = %s,
                updated_at  = NOW()
            WHERE id = %s
            """,
            (trust_score, is_verified_flag, profile_id),
        )
        conn.commit()
        result = {
            "profile_id": profile_id,
            "trust_score": trust_score,
            "is_verified": is_verified_flag,
            "breakdown": {
                "profile_completeness": completeness,
                "verification": verification,
                "activity_behavior": activity,
            },
        }
        logger.info("trust_score_result: %s", json.dumps(result))
        return {"statusCode": 200, "body": json.dumps(result)}
    except psycopg2.Error as e:
        logger.error("DB error: %s", e)
        if conn:
            conn.rollback()
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
    except Exception as e:
        logger.exception("Unexpected error calculating trust score")
        if conn:
            conn.rollback()
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
    finally:
        if conn:
            conn.close()
