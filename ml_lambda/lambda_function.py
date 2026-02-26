import json
import math
from datetime import datetime
import random

def haversine(lat1, lon1, lat2, lon2):
    """Calculate the great circle distance between two points on the earth."""
    R = 6371  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c

def extract_coords(geom_str):
    """Extract lat/lon from a PostGIS POINT string e.g., 'POINT(lon lat)'."""
    try:
        if geom_str and geom_str.startswith("POINT("):
            parts = geom_str[6:-1].split()
            return float(parts[1]), float(parts[0]) # lat, lon
    except Exception:
        pass
    return None, None

def jaccard_similarity(list1, list2):
    """Calculate the similarity between two lists."""
    if not list1 or not list2:
        return 0.0
    set1, set2 = set(list1), set(list2)
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    return intersection / union if union > 0 else 0.0

def calculate_recency_score(last_active_at_str):
    """Score from 1.0 (just now) down to 0.0 (old) based on last active time."""
    if not last_active_at_str:
        return 0.0
    try:
        # Assuming ISO format like "2023-10-27T10:00:00Z"
        # Truncate fractional seconds for easier parsing if needed, but fromisoformat handles simple Z
        clean_str = last_active_at_str.replace('Z', '+00:00')
        # Handle fractional seconds if they exist
        if '.' in clean_str:
             clean_str = clean_str.split('+')[0][:19] + '+00:00'
             
        last_active = datetime.fromisoformat(clean_str)
        now = datetime.now(last_active.tzinfo)
        diff_hours = (now - last_active).total_seconds() / 3600
        
        # Score decays based on hours inactive. 
        # e.g., e^(-0.014 * hours_inactive) -> approx half-life 48 hours
        score = math.exp(-0.014 * diff_hours)
        return max(0.0, min(1.0, score))
    except Exception as e:
        print(f"Error parsing date {last_active_at_str}: {e}")
        return 0.0

def lambda_handler(event, context):
    try:
        # 1. Parse Input from API Gateway
        body = event.get('body', '{}')
        if isinstance(body, str):
            payload = json.loads(body)
        else:
            payload = body

        current_user = payload.get('current_user', {})
        candidate_pool = payload.get('candidate_pool', [])
        requirements = payload.get('requirements', {})
        max_per_category = requirements.get('max_per_category', 5)

        # 2. Extract current user features
        cu_lat, cu_lon = extract_coords(current_user.get('location_geom'))
        cu_interests = current_user.get('interests', [])
        cu_lifestyle = current_user.get('lifestyle', [])

        # 3. Score Candidates against Current User
        scored_candidates = []
        for candidate in candidate_pool:
            c_lat, c_lon = extract_coords(candidate.get('location_geom'))
            
            # Feature: Distance Score (Max 1.0 at 0km, 0.0 at >100km)
            distance_km = float('inf')
            dist_score = 0.0
            if cu_lat is not None and c_lat is not None:
                distance_km = haversine(cu_lat, cu_lon, c_lat, c_lon)
                dist_score = max(0.0, 1.0 - (distance_km / 100))
            
            # Feature: Similarity Scores
            int_score = jaccard_similarity(cu_interests, candidate.get('interests', []))
            life_score = jaccard_similarity(cu_lifestyle, candidate.get('lifestyle', []))
            
            # Feature: Recency Score
            rec_score = calculate_recency_score(candidate.get('last_active_at'))
            
            # Combined ML Composite Score
            # Weighting: 40% Interests, 25% Distance, 20% Lifestyle, 15% Recency
            composite_score = (0.4 * int_score) + (0.25 * dist_score) + (0.2 * life_score) + (0.15 * rec_score)

            scored_candidates.append({
                'profile_id': candidate.get('profile_id'),
                'distance_km': distance_km,
                'int_score': int_score,
                'rec_score': rec_score,
                'composite_score': composite_score
            })
            
        # 4. Smart Categorization & Deduplication
        categories = {
            'top_picks': [],
            'nearby': [],
            'shared_interests': [],
            'recently_active': [],
            'new_faces': []
        }
        
        assigned_ids = set()
        
        def assign_to_category(cat_name, sort_key, reverse=True):
            # Sort the remaining unassigned candidates by the specific metric
            sorted_candidates = sorted(
                [c for c in scored_candidates if c['profile_id'] not in assigned_ids],
                key=lambda x: x[sort_key],
                reverse=reverse
            )
            
            count = 0
            for c in sorted_candidates:
                if count >= max_per_category:
                    break
                categories[cat_name].append(c['profile_id'])
                assigned_ids.add(c['profile_id'])
                count += 1
                
        # Top Picks: Highest overall match score
        assign_to_category('top_picks', 'composite_score', reverse=True)
        
        # Nearby: Smallest distance in km
        assign_to_category('nearby', 'distance_km', reverse=False)
        
        # Shared Interests: Highest pure interest match
        assign_to_category('shared_interests', 'int_score', reverse=True)
        
        # Recently Active: Highest recency score
        assign_to_category('recently_active', 'rec_score', reverse=True)
        
        # New Faces: Randomize the remaining pool for serendipity
        remaining = [c for c in scored_candidates if c['profile_id'] not in assigned_ids]
        random.shuffle(remaining)
        categories['new_faces'] = [c['profile_id'] for c in remaining[:max_per_category]]
        
        # 5. Return Output for Supabase Edge Function
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'categories': categories})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }
