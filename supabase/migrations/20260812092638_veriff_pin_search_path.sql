-- SECURITY DEFINER without a pinned search_path lets a caller who can create
-- objects shadow `profiles`/`veriff_verifications` and have the function
-- operate on their table instead. The other two Veriff functions already pin it.
ALTER FUNCTION public.create_veriff_session(uuid, text, text) SET search_path = public;
ALTER FUNCTION public.get_active_veriff_session(uuid) SET search_path = public;
