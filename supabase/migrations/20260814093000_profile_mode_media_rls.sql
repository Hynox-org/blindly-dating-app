-- profile_mode_media had RLS switched off entirely, so any signed-in user could
-- insert, edit or delete anyone else's photo rows -- including deleting a
-- stranger's whole profile gallery.
--
-- Reads stay open. Discovery, the incoming-call avatar and profile viewing all
-- read other people's media straight from the client, and the photos are
-- already readable through the user_photos bucket policy, so narrowing SELECT
-- would break the app without closing anything.
--
-- Writes become owner-only, which is what was missing.

-- Ownership is two joins away, and the policies need it three times. A
-- definer function keeps the policy expressions readable and avoids leaning on
-- whatever RLS the profiles table has at the time.
create or replace function public.owns_profile_mode(mode_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from profile_modes pm
    join profiles p on p.id = pm.profile_id
    where pm.id = mode_id
      and p.user_id = auth.uid()
  );
$$;

revoke all on function public.owns_profile_mode(uuid) from public;
grant execute on function public.owns_profile_mode(uuid) to authenticated;

alter table public.profile_mode_media enable row level security;

drop policy if exists "media readable by signed-in users" on public.profile_mode_media;
create policy "media readable by signed-in users"
  on public.profile_mode_media
  for select
  to authenticated
  using (true);

drop policy if exists "owners insert their media" on public.profile_mode_media;
create policy "owners insert their media"
  on public.profile_mode_media
  for insert
  to authenticated
  with check (public.owns_profile_mode(profile_mode_id));

drop policy if exists "owners update their media" on public.profile_mode_media;
create policy "owners update their media"
  on public.profile_mode_media
  for update
  to authenticated
  using (public.owns_profile_mode(profile_mode_id))
  with check (public.owns_profile_mode(profile_mode_id));

drop policy if exists "owners delete their media" on public.profile_mode_media;
create policy "owners delete their media"
  on public.profile_mode_media
  for delete
  to authenticated
  using (public.owns_profile_mode(profile_mode_id));
