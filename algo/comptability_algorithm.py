## https://docs.google.com/document/d/1Z6YFigpajv33mOttULJADySUjfKl-0vNg8EWrXq_WWk/edit?usp=sharing


import json
import math
from typing import Any, Dict, List

import numpy as np
from supabase import create_client

import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

NLTK_DATA_DIR = "/tmp/nltk_data"

# Ensure NLTK data path
if NLTK_DATA_DIR not in nltk.data.path:
    nltk.data.path.append(NLTK_DATA_DIR)

# Download only once per Lambda container
try:
    nltk.data.find("sentiment/vader_lexicon.zip")
except LookupError:
    nltk.download("vader_lexicon", download_dir=NLTK_DATA_DIR, quiet=True)

# Initialize once (reused across invocations)
sia = SentimentIntensityAnalyzer()

# Supabase client get the keys form supabase/settings/apikeys
supabase = create_client("Project_url","anon public key")

# Utility helpers
def clamp(x: float, lo: float, hi: float) -> float:
    return lo if x < lo else hi if x > hi else x

def safe_list(x: Any) -> List[Any]:
    return x if isinstance(x, list) else []

def safe_dict(x: Any) -> Dict[str, Any]:
    return x if isinstance(x, dict) else {}

def cosine_sim(a: np.ndarray, b: np.ndarray) -> float:
    na = np.linalg.norm(a)
    nb = np.linalg.norm(b)
    if na == 0 or nb == 0:
        return 0.0
    return float(np.dot(a, b) / (na * nb))

# 1) Interests (30%)

def interest_score(a: List[str], b: List[str]) -> float:
    sa = set(x.lower() for x in a if isinstance(x, str))
    sb = set(x.lower() for x in b if isinstance(x, str))
    if not sa or not sb:
        return 0.0
    return len(sa & sb) / len(sa | sb)


# 2) Lifestyle (25%)

EDU_RANK = {"hs": 0, "diploma": 1, "bachelor": 2, "master": 3, "phd": 4}

DIET_MATRIX = {
    "veg": {"veg": 1.0, "vegan": 1.0, "nonveg": 0.3},
    "vegan": {"vegan": 1.0, "veg": 1.0, "nonveg": 0.1},
    "nonveg": {"nonveg": 1.0, "veg": 0.5, "vegan": 0.2},
}

def lifestyle_score(u: Dict, c: Dict) -> float:
    u, c = safe_dict(u), safe_dict(c)

    if u.get("strict_veg") and c.get("diet") == "nonveg":
        return 0.0

    scores = []

    if u.get("diet") and c.get("diet"):
        scores.append(DIET_MATRIX.get(u["diet"], {}).get(c["diet"], 0.5))

    if u.get("education") and c.get("education"):
        diff = abs(EDU_RANK.get(u["education"], 2) - EDU_RANK.get(c["education"], 2))
        scores.append(clamp(1 - 0.25 * diff, 0, 1))

    return sum(scores) / len(scores) if scores else 0.5


# 3) Activity (20%)

def normalize_hours(x):
    arr = np.array(x if isinstance(x, list) else [0]*24, dtype=float)
    arr = arr[:24] if len(arr) > 24 else np.pad(arr, (0, 24-len(arr)))
    s = arr.sum()
    return arr / s if s > 0 else arr

def activity_score(u: Dict, c: Dict) -> float:
    h1 = normalize_hours(u.get("hours_hist"))
    h2 = normalize_hours(c.get("hours_hist"))

    s_hours = cosine_sim(h1, h2)

    r1 = float(u.get("med_resp_time_hours", 24))
    r2 = float(c.get("med_resp_time_hours", 24))
    s_resp = clamp(1 - abs(math.log(r1 + 1) - math.log(r2 + 1)) / 3, 0, 1)

    e1 = float(u.get("engagement_level", 0.5))
    e2 = float(c.get("engagement_level", 0.5))
    s_eng = 1 - abs(e1 - e2)

    return 0.5*s_hours + 0.3*s_resp + 0.2*s_eng


# 4) Personality (25%)
def personality_score(a: str, b: str) -> float:
    if not a or not b:
        return 0.5

    a = a.lower()
    b = b.lower()

    # 1) Positivity (sentiment)
    sa = (sia.polarity_scores(a)["compound"] + 1) / 2  # normalize to 0–1
    sb = (sia.polarity_scores(b)["compound"] + 1) / 2
    s_pos = 1 - abs(sa - sb)

    # 2) Sociability
    
    social_words = {
        "friends", "people", "social", "meet", "talk",
        "community", "network", "hangout", "team"
    }
    soc_a = sum(1 for w in social_words if w in a) / len(social_words)
    soc_b = sum(1 for w in social_words if w in b) / len(social_words)
    s_soc = 1 - abs(soc_a - soc_b)

    
    # 3) Ambition
    ambition_words = {
        "career", "goal", "startup", "business", "growth",
        "learn", "learning", "ambitious", "driven"
    }
    amb_a = sum(1 for w in ambition_words if w in a) / len(ambition_words)
    amb_b = sum(1 for w in ambition_words if w in b) / len(ambition_words)
    s_amb = 1 - abs(amb_a - amb_b)

    # 4) Creativity
    
    creative_words = {
        "music", "art", "design", "write", "writing",
        "photography", "dance", "creative"
    }
    cre_a = sum(1 for w in creative_words if w in a) / len(creative_words)
    cre_b = sum(1 for w in creative_words if w in b) / len(creative_words)
    s_cre = 1 - abs(cre_a - cre_b)

    # Final personality similarity

    personality_similarity = (
        0.4 * s_pos +
        0.2 * s_soc +
        0.2 * s_amb +
        0.2 * s_cre
    )

    return round(personality_similarity, 4)


# Explanation builder
def build_explanation(
    common_interests: List[str],
    lifestyle_score: float,
    activity_score: float,
    personality_score: float
) -> List[str]:
    explanations = []

    # 1️⃣ Interests (highest priority)
    if common_interests:
        explanations.append(
            f"You both like {', '.join(common_interests[:3])}"
        )

    # 2️⃣ Lifestyle (only if strong)
    if len(explanations) < 3 and lifestyle_score >= 0.75:
        explanations.append("Lifestyle choices align well")

    # 3️⃣ Activity (only if strong)
    if len(explanations) < 3 and activity_score >= 0.70:
        explanations.append("You have similar activity patterns")

    # 4️⃣ Personality (only if strong)
    if len(explanations) < 3 and personality_score >= 0.60:
        explanations.append("Your personality tone feels compatible")

    # Ensure max 3 explanations
    return explanations[:3] if explanations else [
        "Profiles show potential compatibility"
    ]

# Final Score

def final_score_0_100(raw_score: float, power: float = 1.35) -> float:
    x = clamp(raw_score / 100.0, 0.0, 1.0)
    y = x ** power
    return round(y * 100.0, 2)



# Lambda handler
def lambda_handler(event, context):
    try:
        # Parse request
        
        if isinstance(event.get("body"), str):
            body = json.loads(event["body"])
        else:
            body = event

        target_id = body["target_user_id"]
        candidate_ids = body["candidate_user_ids"]
        all_ids = [target_id] + candidate_ids

        
        # Fetch profiles
        
        profiles = supabase.table("profiles") \
            .select("id,bio") \
            .in_("id", all_ids) \
            .execute().data

        
        # Build profile map FIRST
        
        P = {
            p["id"]: {
                "bio": p.get("bio", ""),
                "interests": [],
                "lifestyle": {}
            }
            for p in profiles
        }

        
        # Fetch interests
        
        interests_res = supabase.table("profile_interest_chips") \
            .select("profile_id, interest_chips(label)") \
            .in_("profile_id", all_ids) \
            .execute()

        for row in interests_res.data or []:
            P[row["profile_id"]]["interests"].append(
                row["interest_chips"]["label"].lower()
            )

       
        # Fetch lifestyle
        
        lifestyle_res = supabase.table("profile_lifestyle_chips") \
            .select("profile_id, lifestyle_chips(label)") \
            .in_("profile_id", all_ids) \
            .execute()

        for row in lifestyle_res.data or []:
            label = row["lifestyle_chips"]["label"].lower()
            P[row["profile_id"]]["lifestyle"].setdefault("labels", []).append(label)

        
        # Scoring
        
        target = P[target_id]
        results = []

        for cid in candidate_ids:
            if cid not in P:
                continue
            cand = P[cid]


            si = interest_score(target["interests"], cand["interests"])
            sl = lifestyle_score(target["lifestyle"], cand["lifestyle"])
            sp = personality_score(target["bio"], cand["bio"])

            raw = 100 * (
                0.4 * si +
                0.3 * sl +
                0.3 * sp
            )

            score = final_score_0_100(raw)

            explanation = build_explanation(
                list(set(target["interests"]) & set(cand["interests"])),
                sl,
                0.0,  # activity removed
                sp
            )

            results.append({
                "candidate_id": cid,
                "score": score,
                "raw_score": round(raw, 2),
                "explanation": explanation,
                "factors": {
                    "interests": round(si, 3),
                    "lifestyle": round(sl, 3),
                    "personality": round(sp, 3)
                }
            })

        results.sort(key=lambda x: x["score"], reverse=True)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "target_user_id": target_id,
                "results": results
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
