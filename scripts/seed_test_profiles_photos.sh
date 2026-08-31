#!/usr/bin/env bash
# Uploads three photos for each of the 30 seeded test profiles.
#
# The user_photos bucket is private and its INSERT policy is
# (storage.foldername(name))[1] = auth.uid(), so there is no way to push a file
# into somebody's folder except as that person. Hence the sign-in per user —
# no service-role key needed, only the anon key the app already ships.
#
# Faces come from xsgames.co's AI-generated avatar set: real-looking, nobody's
# actual likeness, and gender-controllable, which randomised sources are not.
# ponytail: 256x256, so cards look soft full-screen. Swap SRC for a higher-res
# set if the photos themselves ever become what is being tested.
#
# Run after section 1-3 of seed_test_profiles.sql, before section 4.
set -euo pipefail

URL="https://icvncmawahwbpiohrcxv.supabase.co"
ANON="$(grep '^SUPABASE_ANON_KEY=' "$(dirname "$0")/../.env.production" | cut -d= -f2-)"
SRC="https://xsgames.co/randomusers/assets/avatars"
PASSWORD="Seed@12345"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# idx sex photo1 photo2 photo3 — kept in step with the "sex"/"photos" fields in
# seed_test_profiles.sql. Indices are unique per gender so no two profiles wear
# the same face.
ROWS='
1 female 1 31 61
2 female 2 32 62
3 female 3 33 63
4 female 4 34 64
5 female 5 35 65
6 female 6 36 66
7 female 7 37 67
8 female 8 38 68
9 female 9 39 69
10 female 10 40 70
11 female 11 41 71
12 female 12 42 72
13 female 13 43 73
14 female 14 44 74
15 female 15 45 75
16 female 16 46 76
17 female 17 47 77
18 female 18 48 78
19 female 19 49 60
20 female 20 50 59
21 male 1 31 61
22 male 2 32 62
23 male 3 33 63
24 male 4 34 64
25 male 5 35 65
26 male 6 36 66
27 male 7 37 67
28 male 8 38 68
29 female 21 51 58
30 male 9 39 69
'

while read -r idx sex p1 p2 p3; do
  [ -z "${idx:-}" ] && continue
  nn=$(printf '%02d' "$idx")
  uid="aaaaaaaa-0000-4000-8000-$(printf '%012d' "$idx")"

  token=$(curl -sS -X POST "$URL/auth/v1/token?grant_type=password" \
    -H "apikey: $ANON" -H 'Content-Type: application/json' \
    -d "{\"email\":\"seed$nn@blindly.test\",\"password\":\"$PASSWORD\"}" \
    | python -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')

  n=1
  for p in "$p1" "$p2" "$p3"; do
    curl -sS -fL -o "$TMP/img.jpg" "$SRC/$sex/$p.jpg"
    # upsert, so a re-run overwrites instead of failing on "already exists"
    curl -sS -f -X POST "$URL/storage/v1/object/user_photos/$uid/$n.jpg" \
      -H "apikey: $ANON" -H "Authorization: Bearer $token" \
      -H 'Content-Type: image/jpeg' -H 'x-upsert: true' \
      --data-binary "@$TMP/img.jpg" > /dev/null
    n=$((n + 1))
  done
  echo "seed$nn -> 3 photos"
done <<< "$ROWS"

echo "done. now run section 4 of scripts/seed_test_profiles.sql"
