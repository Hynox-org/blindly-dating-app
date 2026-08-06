-- ============================================================================
-- Compatibility scoring.
--
-- Deliberately NOT computed in get_discovery_prospects: the score is shown
-- on demand behind a button, so paying for it on every card in every batch
-- would be wasted work. One pair, one call.
--
-- Two halves, following the same split as trust_score vs ai-icebreakers:
--   * the NUMBER is deterministic SQL (this file) -- reproducible, auditable,
--     and identical on every call, so a user can't screenshot two values.
--   * the WORDS are an LLM (compatibility-explanation edge function) that is
--     handed this breakdown and only phrases it. It never sees the raw
--     profiles and never invents the number.
--
-- Scoring rules that matter:
--   * Reciprocal. A one-sided score is the classic dating-app mistake: it
--     rewards profiles the viewer likes but who would never see the viewer.
--     We score both directions of filter fit and combine with a harmonic
--     mean, so a lopsided pair cannot score well.
--   * Weights renormalize over dimensions where BOTH sides actually filled
--     the fields in. A blank field is unknown, not a zero -- otherwise new
--     and private profiles get silently punished.
--   * religion / politics / star_sign are excluded on purpose. The trust
--     score rewrite already rejected scoring profile trivia, and these are
--     exactly the fields ai-icebreakers withholds from third parties.
--     (religion IS still honoured as a reciprocal *filter*, because there the
--     user explicitly asked for it.)
--   * The UI shows a band, not a percent. A precise-looking 73% invites
--     scrutiny that self-reported profile fields cannot survive.
-- ============================================================================


-- ---------------------------------------------------------------- helpers
-- Case/whitespace-insensitive, deduped, nulls and blanks dropped.
CREATE OR REPLACE FUNCTION public.compat_norm(p_vals TEXT[])
RETURNS TEXT[]
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $$
  SELECT COALESCE(
    ARRAY(
      SELECT DISTINCT LOWER(TRIM(v))
        FROM UNNEST(COALESCE(p_vals, '{}')) AS v
       WHERE TRIM(COALESCE(v, '')) <> ''
    ),
    '{}'
  );
$$;

-- Overlap of two sets, 0..1. NULL when either side is empty: that is "we
-- don't know", and it must not be averaged in as a zero.
CREATE OR REPLACE FUNCTION public.compat_jaccard(p_a TEXT[], p_b TEXT[])
RETURNS NUMERIC
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
AS $$
DECLARE
  a TEXT[] := public.compat_norm(p_a);
  b TEXT[] := public.compat_norm(p_b);
  inter INT;
  uni   INT;
BEGIN
  IF CARDINALITY(a) = 0 OR CARDINALITY(b) = 0 THEN
    RETURN NULL;
  END IF;

  SELECT COUNT(*) INTO inter FROM (SELECT UNNEST(a) INTERSECT SELECT UNNEST(b)) s;
  SELECT COUNT(*) INTO uni   FROM (SELECT UNNEST(a) UNION     SELECT UNNEST(b)) s;

  IF uni = 0 THEN RETURN NULL; END IF;
  RETURN ROUND(inter::NUMERIC / uni::NUMERIC, 4);
END;
$$;

-- 1 when two single-value fields agree, 0 when they disagree, NULL when
-- either is blank.
CREATE OR REPLACE FUNCTION public.compat_agree(p_a TEXT, p_b TEXT)
RETURNS NUMERIC
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $$
  SELECT CASE
    WHEN NULLIF(TRIM(COALESCE(p_a, '')), '') IS NULL THEN NULL
    WHEN NULLIF(TRIM(COALESCE(p_b, '')), '') IS NULL THEN NULL
    WHEN LOWER(TRIM(p_a)) = LOWER(TRIM(p_b)) THEN 1::NUMERIC
    ELSE 0::NUMERIC
  END;
$$;

-- Shared band vocabulary. The client renders these, never the number.
CREATE OR REPLACE FUNCTION public.compat_band(p_score NUMERIC)
RETURNS TEXT
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $$
  SELECT CASE
    WHEN p_score IS NULL  THEN 'unknown'
    WHEN p_score >= 0.75  THEN 'strong'
    WHEN p_score >= 0.60  THEN 'good'
    WHEN p_score >= 0.40  THEN 'some'
    ELSE                       'low'
  END;
$$;


-- ------------------------------------------------------------------ cache
-- The explanation costs an LLM call, so it is written back here by the edge
-- function and reused. The numeric half is cheap enough to always recompute.
CREATE TABLE IF NOT EXISTS public.compatibility_reports (
  viewer_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  band         TEXT NOT NULL,
  score        INT  NOT NULL,
  breakdown    JSONB NOT NULL,
  explanation  JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (viewer_id, target_id)
);

ALTER TABLE public.compatibility_reports ENABLE ROW LEVEL SECURITY;

-- Read-only, and only your own side of the pair. All writes go through the
-- edge function's service_role client, which bypasses RLS.
DROP POLICY IF EXISTS "own compatibility reports" ON public.compatibility_reports;
CREATE POLICY "own compatibility reports"
  ON public.compatibility_reports
  FOR SELECT
  USING (viewer_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid()));


-- ------------------------------------------------------- reciprocal fit
-- What fraction of p_filters' *stated* criteria does the candidate meet?
-- Criteria the user left unset are not counted either way, so someone with a
-- wide-open filter set is neither rewarded nor punished for it.
CREATE OR REPLACE FUNCTION public.compat_filter_fit(
  p_filters       JSONB,
  p_cand          public.profiles,
  p_cand_mode_id  UUID,
  p_distance_km   NUMERIC
)
RETURNS JSONB
LANGUAGE plpgsql STABLE
SET search_path = public
AS $$
DECLARE
  v_filters JSONB := COALESCE(p_filters, '{}'::JSONB);
  v_met     INT := 0;
  v_total   INT := 0;
  v_failed  TEXT[] := '{}';

  v_gender_pref  TEXT;
  v_min_age      INT;
  v_max_age      INT;
  v_distance     NUMERIC;
  v_cand_age     INT;
  v_interests    TEXT[];
  v_languages    TEXT[];
  v_single       TEXT;
  v_ok           BOOLEAN;

  -- filter key -> candidate column, for the four simple equality filters
  v_pairs TEXT[][] := ARRAY[
    ARRAY['religion',          'religion'],
    ARRAY['relationshipType',  'relationship_type'],
    ARRAY['sexualOrientation', 'sexual_orientation'],
    ARRAY['datingIntention',   'dating_intention']
  ];
  v_pair TEXT[];
  v_cand_val TEXT;
BEGIN
  -- age -----------------------------------------------------------------
  v_min_age := COALESCE(ROUND((v_filters->>'minAge')::NUMERIC)::INT, 18);
  v_max_age := COALESCE(ROUND((v_filters->>'maxAge')::NUMERIC)::INT, 60);
  IF p_cand.birth_date IS NOT NULL THEN
    v_cand_age := DATE_PART('year', AGE(NOW(), p_cand.birth_date))::INT;
    v_total := v_total + 1;
    IF v_cand_age BETWEEN v_min_age AND v_max_age THEN
      v_met := v_met + 1;
    ELSE
      v_failed := v_failed || 'age'::TEXT;
    END IF;
  END IF;

  -- gender --------------------------------------------------------------
  v_gender_pref := COALESCE(v_filters->>'genderPreference', 'Everyone');
  IF p_cand.gender IS NOT NULL THEN
    v_total := v_total + 1;
    v_ok := v_gender_pref = 'Everyone'
         OR (v_gender_pref = 'Women' AND p_cand.gender::TEXT IN ('F', 'NB'))
         OR (v_gender_pref = 'Men'   AND p_cand.gender::TEXT IN ('M', 'NB'));
    IF v_ok THEN v_met := v_met + 1; ELSE v_failed := v_failed || 'gender'::TEXT; END IF;
  END IF;

  -- distance ------------------------------------------------------------
  -- 200 on the slider means "anywhere", so it stops being a real criterion.
  v_distance := COALESCE((v_filters->>'distanceLimit')::NUMERIC, 50);
  IF p_distance_km IS NOT NULL AND v_distance < 200 THEN
    v_total := v_total + 1;
    IF p_distance_km <= v_distance THEN
      v_met := v_met + 1;
    ELSE
      v_failed := v_failed || 'distance'::TEXT;
    END IF;
  END IF;

  -- simple equality filters ---------------------------------------------
  FOREACH v_pair SLICE 1 IN ARRAY v_pairs LOOP
    v_single := NULLIF(TRIM(COALESCE(v_filters->>v_pair[1], '')), '');
    CONTINUE WHEN v_single IS NULL;

    v_cand_val := CASE v_pair[2]
      WHEN 'religion'           THEN p_cand.religion
      WHEN 'relationship_type'  THEN p_cand.relationship_type
      WHEN 'sexual_orientation' THEN p_cand.sexual_orientation
      WHEN 'dating_intention'   THEN p_cand.dating_intention
    END;

    v_total := v_total + 1;
    IF v_cand_val IS NOT NULL AND LOWER(TRIM(v_cand_val)) = LOWER(v_single) THEN
      v_met := v_met + 1;
    ELSE
      v_failed := v_failed || v_pair[1];
    END IF;
  END LOOP;

  -- languages: any overlap satisfies it ---------------------------------
  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedLanguages', '[]'::JSONB)))
    INTO v_languages;
  IF CARDINALITY(public.compat_norm(v_languages)) > 0 THEN
    v_total := v_total + 1;
    IF public.compat_norm(p_cand.languages) && public.compat_norm(v_languages) THEN
      v_met := v_met + 1;
    ELSE
      v_failed := v_failed || 'languages'::TEXT;
    END IF;
  END IF;

  -- interests: any overlap satisfies it ---------------------------------
  SELECT ARRAY(SELECT jsonb_array_elements_text(COALESCE(v_filters->'selectedInterests', '[]'::JSONB)))
    INTO v_interests;
  IF CARDINALITY(public.compat_norm(v_interests)) > 0 AND p_cand_mode_id IS NOT NULL THEN
    v_total := v_total + 1;
    IF EXISTS (
      SELECT 1
        FROM profile_mode_interestchips pmic
        JOIN interest_chips ic ON ic.id = pmic.chip_id
       WHERE pmic.profile_mode_id = p_cand_mode_id
         AND LOWER(TRIM(ic.label)) = ANY (public.compat_norm(v_interests))
    ) THEN
      v_met := v_met + 1;
    ELSE
      v_failed := v_failed || 'interests'::TEXT;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'fit',    CASE WHEN v_total = 0 THEN NULL ELSE ROUND(v_met::NUMERIC / v_total, 4) END,
    'met',    v_met,
    'total',  v_total,
    'failed', to_jsonb(v_failed)
  );
END;
$$;


-- ----------------------------------------------------------------- main
DROP FUNCTION IF EXISTS public.get_compatibility(UUID);

CREATE FUNCTION public.get_compatibility(p_target_profile_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me      public.profiles;
  v_them    public.profiles;
  v_my_mode public.profile_modes;
  v_tg_mode public.profile_modes;
  v_mode    TEXT;

  v_distance NUMERIC;
  v_age_gap  INT;

  v_my_interests  TEXT[];
  v_tg_interests  TEXT[];
  v_my_lifestyle  TEXT[];
  v_tg_lifestyle  TEXT[];

  -- dimension accumulators
  v_dims        JSONB := '[]'::JSONB;
  v_weighted    NUMERIC := 0;
  v_weight_used NUMERIC := 0;

  v_parts     NUMERIC[];
  v_dim_score NUMERIC;

  v_content     NUMERIC;
  v_coverage    NUMERIC;
  v_my_fit      JSONB;
  v_tg_fit      JSONB;
  v_f           NUMERIC;
  v_b           NUMERIC;
  v_mutual      NUMERIC;
  v_final       NUMERIC;
  v_band        TEXT;

  v_shared_interests TEXT[];
  v_shared_lifestyle TEXT[];
  v_shared_qualities TEXT[];
  v_shared_causes    TEXT[];
  v_shared_languages TEXT[];

  -- appends one dimension's result; declared as a local block below instead
  -- of a nested function, since plpgsql has no closures.
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT * INTO v_me FROM profiles
   WHERE user_id = auth.uid() AND is_active AND NOT is_deleted;
  IF v_me.id IS NULL THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF p_target_profile_id = v_me.id THEN
    RAISE EXCEPTION 'Cannot score compatibility with yourself';
  END IF;

  SELECT * INTO v_them FROM profiles
   WHERE id = p_target_profile_id AND is_active AND NOT is_deleted;
  IF v_them.id IS NULL THEN
    RAISE EXCEPTION 'Target profile not found';
  END IF;

  -- SECURITY DEFINER bypasses RLS, so the block check has to be explicit.
  IF EXISTS (
    SELECT 1 FROM match_blocks b
     WHERE (b.user_a_id = v_me.id   AND b.user_b_id = v_them.id)
        OR (b.user_a_id = v_them.id AND b.user_b_id = v_me.id)
  ) THEN
    RAISE EXCEPTION 'Not available';
  END IF;

  -- Compare like with like: both sides in the mode the viewer is browsing.
  v_mode := LOWER(COALESCE(v_me.current_mode, 'date'));

  SELECT * INTO v_my_mode FROM profile_modes
   WHERE profile_id = v_me.id AND mode = v_mode;
  SELECT * INTO v_tg_mode FROM profile_modes
   WHERE profile_id = v_them.id AND mode = v_mode AND is_active;

  IF v_tg_mode.id IS NULL THEN
    RAISE EXCEPTION 'Target is not active in % mode', v_mode;
  END IF;

  -- ------------------------------------------------------------- inputs
  IF COALESCE(v_me.passport_location_geom, v_me.location_geom) IS NOT NULL
     AND COALESCE(v_them.passport_location_geom, v_them.location_geom) IS NOT NULL THEN
    v_distance := ROUND(
      (ST_Distance(
        COALESCE(v_me.passport_location_geom, v_me.location_geom),
        COALESCE(v_them.passport_location_geom, v_them.location_geom)
      ) / 1000.0)::NUMERIC, 1);
  END IF;

  IF v_me.birth_date IS NOT NULL AND v_them.birth_date IS NOT NULL THEN
    v_age_gap := ABS(
      DATE_PART('year', AGE(NOW(), v_me.birth_date))::INT
      - DATE_PART('year', AGE(NOW(), v_them.birth_date))::INT
    );
  END IF;

  SELECT COALESCE(ARRAY(
    SELECT ic.label FROM profile_mode_interestchips pmic
      JOIN interest_chips ic ON ic.id = pmic.chip_id
     WHERE pmic.profile_mode_id = v_my_mode.id), '{}') INTO v_my_interests;
  SELECT COALESCE(ARRAY(
    SELECT ic.label FROM profile_mode_interestchips pmic
      JOIN interest_chips ic ON ic.id = pmic.chip_id
     WHERE pmic.profile_mode_id = v_tg_mode.id), '{}') INTO v_tg_interests;
  SELECT COALESCE(ARRAY(
    SELECT lc.label FROM profile_mode_lifestylechips pmlc
      JOIN lifestyle_chips lc ON lc.id = pmlc.chip_id
     WHERE pmlc.profile_mode_id = v_my_mode.id), '{}') INTO v_my_lifestyle;
  SELECT COALESCE(ARRAY(
    SELECT lc.label FROM profile_mode_lifestylechips pmlc
      JOIN lifestyle_chips lc ON lc.id = pmlc.chip_id
     WHERE pmlc.profile_mode_id = v_tg_mode.id), '{}') INTO v_tg_lifestyle;

  -- ---------------------------------------------------------- dimensions
  -- Each dimension averages its non-NULL components. A dimension with no
  -- usable components at all drops out entirely and its weight is not
  -- counted in the denominator.

  -- INTENT (25) -- what each of them says they are here for.
  v_parts := ARRAY(SELECT x FROM UNNEST(ARRAY[
    public.compat_agree(v_me.relationship_type, v_them.relationship_type),
    public.compat_agree(v_me.dating_intention,  v_them.dating_intention),
    public.compat_agree(v_me.kids_preference,   v_them.kids_preference),
    public.compat_jaccard(v_my_mode.looking_for, v_tg_mode.looking_for)
  ]) x WHERE x IS NOT NULL);
  IF CARDINALITY(v_parts) > 0 THEN
    SELECT AVG(x) INTO v_dim_score FROM UNNEST(v_parts) x;
    v_weighted := v_weighted + 25 * v_dim_score;
    v_weight_used := v_weight_used + 25;
    v_dims := v_dims || jsonb_build_object(
      'key', 'intent', 'label', 'What you both want', 'weight', 25,
      'band', public.compat_band(v_dim_score),
      'mine',   jsonb_build_object('relationship_type', v_me.relationship_type,
                                   'dating_intention', v_me.dating_intention,
                                   'kids', v_me.kids_preference,
                                   'looking_for', to_jsonb(COALESCE(v_my_mode.looking_for, '{}'))),
      'theirs', jsonb_build_object('relationship_type', v_them.relationship_type,
                                   'dating_intention', v_them.dating_intention,
                                   'kids', v_them.kids_preference,
                                   'looking_for', to_jsonb(COALESCE(v_tg_mode.looking_for, '{}')))
    );
  END IF;

  -- VALUES (20) -- qualities they look for, causes they care about.
  v_shared_qualities := ARRAY(
    SELECT UNNEST(public.compat_norm(v_me.qualities))
    INTERSECT SELECT UNNEST(public.compat_norm(v_them.qualities)));
  v_shared_causes := ARRAY(
    SELECT UNNEST(public.compat_norm(v_me.causes_communities))
    INTERSECT SELECT UNNEST(public.compat_norm(v_them.causes_communities)));

  v_parts := ARRAY(SELECT x FROM UNNEST(ARRAY[
    public.compat_jaccard(v_me.qualities,          v_them.qualities),
    public.compat_jaccard(v_me.causes_communities, v_them.causes_communities)
  ]) x WHERE x IS NOT NULL);
  IF CARDINALITY(v_parts) > 0 THEN
    SELECT AVG(x) INTO v_dim_score FROM UNNEST(v_parts) x;
    v_weighted := v_weighted + 20 * v_dim_score;
    v_weight_used := v_weight_used + 20;
    v_dims := v_dims || jsonb_build_object(
      'key', 'values', 'label', 'Values', 'weight', 20,
      'band', public.compat_band(v_dim_score),
      'shared_qualities', to_jsonb(v_shared_qualities),
      'shared_causes',    to_jsonb(v_shared_causes)
    );
  END IF;

  -- LIFESTYLE (20) -- habits that tend to matter day to day.
  v_parts := ARRAY(SELECT x FROM UNNEST(ARRAY[
    public.compat_agree(v_me.drinking, v_them.drinking),
    public.compat_agree(v_me.smoking,  v_them.smoking),
    public.compat_agree(v_me.exercise, v_them.exercise)
  ]) x WHERE x IS NOT NULL);
  IF CARDINALITY(v_parts) > 0 THEN
    SELECT AVG(x) INTO v_dim_score FROM UNNEST(v_parts) x;
    v_weighted := v_weighted + 20 * v_dim_score;
    v_weight_used := v_weight_used + 20;
    v_dims := v_dims || jsonb_build_object(
      'key', 'lifestyle', 'label', 'Lifestyle', 'weight', 20,
      'band', public.compat_band(v_dim_score),
      'mine',   jsonb_build_object('drinking', v_me.drinking,   'smoking', v_me.smoking,   'exercise', v_me.exercise),
      'theirs', jsonb_build_object('drinking', v_them.drinking, 'smoking', v_them.smoking, 'exercise', v_them.exercise)
    );
  END IF;

  -- INTERESTS (20) -- overlap breadth, not raw count, so a profile that
  -- ticks forty chips doesn't out-score a focused one.
  v_shared_interests := ARRAY(
    SELECT UNNEST(public.compat_norm(v_my_interests))
    INTERSECT SELECT UNNEST(public.compat_norm(v_tg_interests)));
  v_shared_lifestyle := ARRAY(
    SELECT UNNEST(public.compat_norm(v_my_lifestyle))
    INTERSECT SELECT UNNEST(public.compat_norm(v_tg_lifestyle)));

  v_parts := ARRAY(SELECT x FROM UNNEST(ARRAY[
    public.compat_jaccard(v_my_interests, v_tg_interests),
    public.compat_jaccard(v_my_lifestyle, v_tg_lifestyle)
  ]) x WHERE x IS NOT NULL);
  IF CARDINALITY(v_parts) > 0 THEN
    SELECT AVG(x) INTO v_dim_score FROM UNNEST(v_parts) x;
    v_weighted := v_weighted + 20 * v_dim_score;
    v_weight_used := v_weight_used + 20;
    v_dims := v_dims || jsonb_build_object(
      'key', 'interests', 'label', 'Shared interests', 'weight', 20,
      'band', public.compat_band(v_dim_score),
      'shared_interests', to_jsonb(v_shared_interests),
      'shared_lifestyle', to_jsonb(v_shared_lifestyle)
    );
  END IF;

  -- PRACTICAL (15) -- distance, age gap, a language in common.
  v_shared_languages := ARRAY(
    SELECT UNNEST(public.compat_norm(v_me.languages))
    INTERSECT SELECT UNNEST(public.compat_norm(v_them.languages)));

  v_parts := ARRAY(SELECT x FROM UNNEST(ARRAY[
    CASE WHEN v_distance IS NULL THEN NULL
         ELSE GREATEST(0, LEAST(1, (100 - v_distance) / 90.0)) END,
    CASE WHEN v_age_gap IS NULL THEN NULL
         ELSE GREATEST(0, LEAST(1, (15 - v_age_gap) / 12.0)) END,
    CASE WHEN CARDINALITY(public.compat_norm(v_me.languages)) = 0
           OR CARDINALITY(public.compat_norm(v_them.languages)) = 0 THEN NULL
         WHEN CARDINALITY(v_shared_languages) > 0 THEN 1 ELSE 0 END
  ]) x WHERE x IS NOT NULL);
  IF CARDINALITY(v_parts) > 0 THEN
    SELECT AVG(x) INTO v_dim_score FROM UNNEST(v_parts) x;
    v_weighted := v_weighted + 15 * v_dim_score;
    v_weight_used := v_weight_used + 15;
    v_dims := v_dims || jsonb_build_object(
      'key', 'practical', 'label', 'Practical fit', 'weight', 15,
      'band', public.compat_band(v_dim_score),
      'distance_km', v_distance,
      'age_gap', v_age_gap,
      'shared_languages', to_jsonb(v_shared_languages)
    );
  END IF;

  v_coverage := ROUND(v_weight_used / 100.0, 4);
  v_content  := CASE WHEN v_weight_used = 0 THEN NULL
                     ELSE v_weighted / v_weight_used END;

  -- --------------------------------------------------------- reciprocity
  v_my_fit := public.compat_filter_fit(v_my_mode.filters, v_them, v_tg_mode.id, v_distance);
  v_tg_fit := public.compat_filter_fit(v_tg_mode.filters, v_me,   v_my_mode.id, v_distance);

  v_f := (v_my_fit->>'fit')::NUMERIC;
  v_b := (v_tg_fit->>'fit')::NUMERIC;

  -- Harmonic mean, so one strong direction cannot carry a weak one. When a
  -- side states no criteria at all it is treated as fully open (1.0) rather
  -- than as a failure.
  v_f := COALESCE(v_f, 1);
  v_b := COALESCE(v_b, 1);
  v_mutual := CASE WHEN (v_f + v_b) = 0 THEN 0
                   ELSE ROUND((2 * v_f * v_b) / (v_f + v_b), 4) END;

  -- Reciprocity scales the content score rather than being averaged into
  -- it: a pair who would never surface to each other should not be able to
  -- score "strong" on shared hobbies alone. The 0.35 floor keeps it a
  -- damper rather than an eraser, and is chosen so that the multiplier at
  -- mutual = 0.5 is 0.675 -- below the 0.75 "strong" cut even at a perfect
  -- content score of 1.0. In other words, poor mutual fit makes "strong"
  -- arithmetically unreachable, which is the whole point of scoring both
  -- directions. (A 0.5 floor did not have this property.)
  v_final := CASE WHEN v_content IS NULL THEN NULL
                  ELSE v_content * (0.35 + 0.65 * v_mutual) END;

  -- Below this much coverage the inputs are too thin to band honestly.
  IF v_content IS NULL OR v_coverage < 0.40 THEN
    v_band := 'unknown';
  ELSE
    v_band := public.compat_band(v_final);
  END IF;

  RETURN jsonb_build_object(
    'target_id',  v_them.id,
    'target_name', v_them.display_name,
    'mode',       v_mode,
    'band',       v_band,
    'score',      CASE WHEN v_final IS NULL THEN NULL ELSE ROUND(v_final * 100)::INT END,
    'coverage',   v_coverage,
    'reciprocity', jsonb_build_object(
      'band',        public.compat_band(v_mutual),
      'mutual',      v_mutual,
      'you_fit_them', v_tg_fit,
      'they_fit_you', v_my_fit
    ),
    'dimensions', v_dims,
    'shared', jsonb_build_object(
      'interests', to_jsonb(v_shared_interests),
      'lifestyle', to_jsonb(v_shared_lifestyle),
      'qualities', to_jsonb(v_shared_qualities),
      'causes',    to_jsonb(v_shared_causes),
      'languages', to_jsonb(v_shared_languages)
    ),
    'computed_at', NOW()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_compatibility(UUID) TO authenticated;
