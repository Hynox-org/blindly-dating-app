-- Photos are uploaded the moment they pass moderation, before the user taps
-- Continue. That is what makes moderation unskippable, but it means a user who
-- picks photos and closes the app leaves files in the bucket that no row points
-- at. This sweeps them.
--
-- The three hour grace window is also the draft window: within it, the app can
-- restore an unfinished pick, so a user who closes the app and comes back finds
-- their photos still waiting. Shortening the window shortens both.

create table if not exists public.orphan_photo_cleanup_log (
  id bigint generated always as identity primary key,
  ran_at timestamptz not null default now(),
  dry_run boolean not null,
  paths text[] not null,
  deleted_count integer not null,
  note text
);

-- No policies: nothing outside a definer function or the service role reads it.
alter table public.orphan_photo_cleanup_log enable row level security;

-- Files in user_photos older than the grace window that no photo row claims.
--
-- ponytail: the LIKE covers legacy rows that stored a full URL instead of a
-- path, and makes this a scan rather than an index lookup. Fine at this size;
-- if the bucket grows past ~100k objects, normalise media_url and drop it.
create or replace function public.orphan_photo_paths(grace interval)
returns setof text
language sql
stable
security definer
set search_path = public
as $$
  select o.name
  from storage.objects o
  where o.bucket_id = 'user_photos'
    and o.created_at < now() - grace
    and not exists (
      select 1
      from public.profile_mode_media m
      where m.media_type = 'photo'
        and (m.media_url = o.name or m.media_url like '%' || o.name)
    )
  order by o.created_at;
$$;

-- Deletes those files through the Storage API. Removing rows from
-- storage.objects directly would leave the underlying file behind, so this goes
-- through HTTP even though it runs inside the database.
--
-- Defaults to dry_run: it records what it would delete and deletes nothing.
-- Flip the cron job to dry_run => false once the log looks right.
create or replace function public.cleanup_orphan_photos(
  dry_run boolean default true,
  grace interval default '3 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_paths text[];
  v_batch text[];
  v_url text;
  v_key text;
  v_note text;
  i integer;
begin
  select array_agg(path) into v_paths from public.orphan_photo_paths(grace) as path;
  v_paths := coalesce(v_paths, '{}');

  if array_length(v_paths, 1) is null then
    insert into public.orphan_photo_cleanup_log (dry_run, paths, deleted_count, note)
    values (dry_run, '{}', 0, 'nothing to sweep');
    return 0;
  end if;

  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_key from vault.decrypted_secrets where name = 'service_role_key';

  -- Without credentials there is nothing to do but report, and reporting is
  -- better than failing silently in a cron job nobody watches.
  if v_url is null or v_key is null then
    dry_run := true;
    v_note := 'vault secrets project_url/service_role_key missing -- forced dry run';
  end if;

  if dry_run then
    insert into public.orphan_photo_cleanup_log (dry_run, paths, deleted_count, note)
    values (true, v_paths, 0, coalesce(v_note, 'dry run'));
    return 0;
  end if;

  -- Storage takes a list per call; keep the batches modest.
  i := 1;
  while i <= array_length(v_paths, 1) loop
    v_batch := v_paths[i : i + 99];
    perform net.http_delete(
      url => v_url || '/storage/v1/object/user_photos',
      headers => jsonb_build_object(
        'Authorization', 'Bearer ' || v_key,
        'Content-Type', 'application/json'
      ),
      body => jsonb_build_object('prefixes', to_jsonb(v_batch)),
      timeout_milliseconds => 20000
    );
    i := i + 100;
  end loop;

  insert into public.orphan_photo_cleanup_log (dry_run, paths, deleted_count, note)
  values (false, v_paths, array_length(v_paths, 1), 'deleted');

  return array_length(v_paths, 1);
end;
$$;

revoke all on function public.orphan_photo_paths(interval) from public;
revoke all on function public.cleanup_orphan_photos(boolean, interval) from public;

-- Hourly, in dry run. Once the log reads right, swap the argument to false.
select cron.unschedule('orphan-photo-cleanup')
where exists (select 1 from cron.job where jobname = 'orphan-photo-cleanup');

select cron.schedule(
  'orphan-photo-cleanup',
  '0 * * * *',
  $cron$ select public.cleanup_orphan_photos(dry_run => true); $cron$
);
