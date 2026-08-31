-- ============================================================================
-- Spotlight: a user pays to sit at the top of the swipe deck for everyone in
-- their district, for a fixed window.
--
-- Two tables and two RPCs. The deck function itself is rewritten in
-- 20260831120100_spotlight_deck.sql, which is where the ordering lives.
--
-- No payment provider is wired up yet. purchase_spotlight writes a row with
-- payment_provider = 'none' and payment_status = 'completed'; when a real
-- gateway arrives it becomes 'pending' until the webhook confirms, and the
-- deck query already refuses anything that is not 'completed'.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- profiles.district
--
-- Spotlight audience is "same district", so both the buyer and the viewer need
-- one. It is written by update_passport_location below, from a Mapbox reverse
-- geocode the client already knows how to do (see _resolveDistrictFromGeom).
-- Stored as Mapbox returns it; compared case- and space-insensitively, because
-- "Coimbatore" and "coimbatore " must be the same audience.
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS district TEXT;

CREATE INDEX IF NOT EXISTS idx_profiles_district
  ON public.profiles (lower(btrim(district)))
  WHERE district IS NOT NULL;


-- ---------------------------------------------------------------------------
-- Packages.
--
-- This is a table rather than three constants in the client because the price
-- must be server-authoritative: purchase_spotlight reads the amount from here
-- and never from its caller, so a tampered client cannot buy an hour for ₹1.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.spotlight_packages (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code             TEXT NOT NULL UNIQUE,
  duration_minutes INT  NOT NULL CHECK (duration_minutes > 0),
  price_inr        NUMERIC(10,2) NOT NULL CHECK (price_inr >= 0),
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order       SMALLINT NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.spotlight_packages (code, duration_minutes, price_inr, sort_order)
VALUES ('spotlight_5m',   5, 250,  1),
       ('spotlight_25m', 25, 2000, 2),
       ('spotlight_60m', 60, 5000, 3)
ON CONFLICT (code) DO UPDATE
  SET duration_minutes = EXCLUDED.duration_minutes,
      price_inr        = EXCLUDED.price_inr,
      sort_order       = EXCLUDED.sort_order;


-- ---------------------------------------------------------------------------
-- Purchases. One row per purchase; "is a spotlight active" is derived from
-- now() BETWEEN starts_at AND expires_at, so nothing has to expire anything —
-- no cron, no status column drifting out of sync with the clock.
--
-- district is frozen at purchase time. The buyer can drive to another district
-- and their spotlight stays where they bought it, which is both what was asked
-- for and what stops one purchase being farmed across three audiences.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.spotlight_purchases (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  package_id       UUID NOT NULL REFERENCES public.spotlight_packages(id),
  mode             TEXT NOT NULL CHECK (mode IN ('date', 'bff')),

  -- Audience, frozen at purchase.
  district         TEXT NOT NULL,
  purchased_geom   geography(Point, 4326),

  -- What was actually charged, copied off the package so a later price change
  -- does not rewrite history.
  amount_inr       NUMERIC(10,2) NOT NULL,
  payment_status   payment_status NOT NULL DEFAULT 'completed',
  payment_provider TEXT NOT NULL DEFAULT 'none',
  payment_ref      TEXT,

  starts_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at       TIMESTAMPTZ NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

  CHECK (expires_at > starts_at)
);

-- The deck hits this on every fetch: "active spotlights in my district, my
-- mode". expires_at cannot live in the predicate (now() is not immutable), so
-- it is a leading column instead.
CREATE INDEX IF NOT EXISTS idx_spotlight_active
  ON public.spotlight_purchases (mode, district, expires_at DESC)
  WHERE payment_status = 'completed';

CREATE INDEX IF NOT EXISTS idx_spotlight_by_profile
  ON public.spotlight_purchases (profile_id, expires_at DESC);


-- ---------------------------------------------------------------------------
-- RLS. Packages are a public price list. Purchases are private to the buyer,
-- and are only ever written by purchase_spotlight (SECURITY DEFINER) — there
-- is deliberately no INSERT policy, so a client cannot mint itself a spotlight.
-- ---------------------------------------------------------------------------
ALTER TABLE public.spotlight_packages  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spotlight_purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS spotlight_packages_read ON public.spotlight_packages;
CREATE POLICY spotlight_packages_read ON public.spotlight_packages
  FOR SELECT TO authenticated USING (is_active);

DROP POLICY IF EXISTS spotlight_purchases_read_own ON public.spotlight_purchases;
CREATE POLICY spotlight_purchases_read_own ON public.spotlight_purchases
  FOR SELECT TO authenticated
  USING (profile_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid()));

GRANT SELECT ON public.spotlight_packages  TO authenticated;
GRANT SELECT ON public.spotlight_purchases TO authenticated;


-- ---------------------------------------------------------------------------
-- update_passport_location gains the district.
--
-- p_district defaults to NULL and a NULL leaves the stored value alone, so the
-- existing two-argument callers keep working unchanged while the client is
-- updated.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_passport_location(
  p_lat      DOUBLE PRECISION,
  p_long     DOUBLE PRECISION,
  p_district TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  UPDATE public.profiles
     SET passport_location_geom = ST_SetSRID(ST_MakePoint(p_long, p_lat), 4326),
         district    = COALESCE(NULLIF(btrim(p_district), ''), district),
         last_active = CURRENT_TIMESTAMP
   WHERE user_id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_passport_location(DOUBLE PRECISION, DOUBLE PRECISION, TEXT) TO authenticated;


-- ---------------------------------------------------------------------------
-- purchase_spotlight
--
-- The whole payment step for now. Price and duration come off the package, the
-- district off the buyer's profile; the caller only chooses which package and
-- which mode.
--
-- Buying while a spotlight is already running in the same district and mode
-- appends to it rather than starting a second overlapping window — otherwise
-- two purchases could burn the same minutes.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.purchase_spotlight(
  p_package_id UUID,
  p_mode       TEXT
)
RETURNS public.spotlight_purchases
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_me       UUID;
  v_district TEXT;
  v_geom     geography;
  v_mode     TEXT;
  v_pkg      public.spotlight_packages;
  v_starts   TIMESTAMPTZ;
  v_row      public.spotlight_purchases;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '28000';
  END IF;

  v_mode := lower(btrim(p_mode));
  IF v_mode NOT IN ('date', 'bff') THEN
    RAISE EXCEPTION 'Invalid mode: %', p_mode USING ERRCODE = '22023';
  END IF;

  SELECT p.id, btrim(p.district), COALESCE(p.passport_location_geom, p.location_geom)
    INTO v_me, v_district, v_geom
    FROM public.profiles p
   WHERE p.user_id = auth.uid() AND p.is_active AND NOT p.is_deleted;

  IF v_me IS NULL THEN
    RAISE EXCEPTION 'Profile not found' USING ERRCODE = 'P0002';
  END IF;

  -- Without a district there is no audience to be spotlighted to. The client
  -- turns this into "we could not work out where you are" and offers a retry
  -- rather than taking money for nothing.
  IF v_district IS NULL OR v_district = '' THEN
    RAISE EXCEPTION 'No district set' USING ERRCODE = 'P0002';
  END IF;

  SELECT * INTO v_pkg
    FROM public.spotlight_packages
   WHERE id = p_package_id AND is_active;

  IF v_pkg.id IS NULL THEN
    RAISE EXCEPTION 'Unknown or inactive package' USING ERRCODE = '22023';
  END IF;

  -- Stack rather than overlap.
  SELECT max(sp.expires_at) INTO v_starts
    FROM public.spotlight_purchases sp
   WHERE sp.profile_id = v_me
     AND sp.mode = v_mode
     AND lower(btrim(sp.district)) = lower(v_district)
     AND sp.payment_status = 'completed'
     AND sp.expires_at > now();

  v_starts := COALESCE(v_starts, now());

  INSERT INTO public.spotlight_purchases (
    profile_id, package_id, mode, district, purchased_geom,
    amount_inr, payment_status, payment_provider,
    starts_at, expires_at
  ) VALUES (
    v_me, v_pkg.id, v_mode, v_district, v_geom,
    v_pkg.price_inr, 'completed', 'none',
    v_starts, v_starts + make_interval(mins => v_pkg.duration_minutes)
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

REVOKE ALL ON FUNCTION public.purchase_spotlight(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.purchase_spotlight(UUID, TEXT) TO authenticated;


-- ---------------------------------------------------------------------------
-- get_my_spotlight — what the profile screen shows: the live window, if any.
-- Returns at most one row per mode.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_my_spotlight()
RETURNS TABLE (
  id                UUID,
  mode              TEXT,
  district          TEXT,
  starts_at         TIMESTAMPTZ,
  expires_at        TIMESTAMPTZ,
  seconds_remaining INT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
  SELECT DISTINCT ON (sp.mode)
         sp.id, sp.mode, sp.district, sp.starts_at, sp.expires_at,
         GREATEST(0, EXTRACT(EPOCH FROM (sp.expires_at - now()))::INT)
    FROM public.spotlight_purchases sp
    JOIN public.profiles p ON p.id = sp.profile_id
   WHERE p.user_id = auth.uid()
     AND sp.payment_status = 'completed'
     AND sp.expires_at > now()
   ORDER BY sp.mode, sp.expires_at DESC;
$$;

GRANT EXECUTE ON FUNCTION public.get_my_spotlight() TO authenticated;
