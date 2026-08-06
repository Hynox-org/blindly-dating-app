-- Linter follow-up on the compatibility objects.
--
-- 1. The four pure helpers had a mutable search_path. They touch no tables and
--    every internal call is schema-qualified, so an empty search_path is safe
--    and closes the injection vector.
-- 2. PUBLIC holds EXECUTE on new functions by default, so anon could reach
--    get_compatibility over /rest/v1/rpc. It already raises on a NULL
--    auth.uid(), but a SECURITY DEFINER function should not be reachable
--    unauthenticated at all -- defence in depth rather than a live hole.

ALTER FUNCTION public.compat_norm(TEXT[])          SET search_path = '';
ALTER FUNCTION public.compat_jaccard(TEXT[],TEXT[]) SET search_path = '';
ALTER FUNCTION public.compat_agree(TEXT,TEXT)       SET search_path = '';
ALTER FUNCTION public.compat_band(NUMERIC)          SET search_path = '';

REVOKE ALL ON FUNCTION public.get_compatibility(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_compatibility(UUID) TO authenticated;
