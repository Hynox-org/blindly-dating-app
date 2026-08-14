-- Voice intros leak the same way photos did, by a different route: recording a
-- new one uploads the file, deletes the old row, and leaves the old file in the
-- bucket forever. Abandoning the step leaves one too.
--
-- Rather than a second copy of the sweep, the existing one takes the bucket and
-- media type as arguments. The pairing is fixed: user_photos holds 'photo',
-- user_voices holds 'voice_intro'.

alter table public.orphan_photo_cleanup_log
  rename to orphan_media_cleanup_log;

alter table public.orphan_media_cleanup_log
  add column if not exists bucket text not null default 'user_photos';

-- Stop the job before the functions it calls disappear.
select cron.unschedule('orphan-photo-cleanup')
where exists (select 1 from cron.job where jobname = 'orphan-photo-cleanup');

drop function if exists public.cleanup_orphan_photos(boolean, interval);
drop function if exists public.orphan_photo_paths(interval);

-- Files older than the grace window that no row of the matching type claims.
--
-- ponytail: the LIKE covers legacy rows that stored a full URL instead of a
-- path, and makes this a scan rather than an index lookup. Fine at this size;
-- if either bucket grows past ~100k objects, normalise media_url and drop it.
create or replace function public.orphan_media_paths(
  bucket text,
  media_type text,
  grace interval
)
returns setof text
language sql
stable
security definer
set search_path = public
as $$
  select o.name
  from storage.objects o
  where o.bucket_id = bucket
    and o.created_at < now() - grace
    and not exists (
      select 1
      from public.profile_mode_media m
      where m.media_type = orphan_media_paths.media_type
        and (m.media_url = o.name or m.media_url like '%' || o.name)
    )
  order by o.created_at;
$$;

-- Deletes them through the Storage API. Removing rows from storage.objects
-- directly would leave the underlying file behind, so this goes through HTTP
-- even though it runs inside the database.
create or replace function public.cleanup_orphan_media(
  bucket text,
  media_type text,
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
  select array_agg(path) into v_paths
  from public.orphan_media_paths(bucket, media_type, grace) as path;
  v_paths := coalesce(v_paths, '{}');

  if array_length(v_paths, 1) is null then
    insert into public.orphan_media_cleanup_log (bucket, dry_run, paths, deleted_count, note)
    values (bucket, dry_run, '{}', 0, 'nothing to sweep');
    return 0;
  end if;

  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_key from vault.decrypted_secrets where name = 'service_role_key';

  if v_url is null or v_key is null then
    dry_run := true;
    v_note := 'vault secrets project_url/service_role_key missing -- forced dry run';
  end if;

  if dry_run then
    insert into public.orphan_media_cleanup_log (bucket, dry_run, paths, deleted_count, note)
    values (bucket, true, v_paths, 0, coalesce(v_note, 'dry run'));
    return 0;
  end if;

  i := 1;
  while i <= array_length(v_paths, 1) loop
    v_batch := v_paths[i : i + 99];
    perform net.http_delete(
      url => v_url || '/storage/v1/object/' || bucket,
      headers => jsonb_build_object(
        'Authorization', 'Bearer ' || v_key,
        'Content-Type', 'application/json'
      ),
      body => jsonb_build_object('prefixes', to_jsonb(v_batch)),
      timeout_milliseconds => 20000
    );
    i := i + 100;
  end loop;

  insert into public.orphan_media_cleanup_log (bucket, dry_run, paths, deleted_count, note)
  values (bucket, false, v_paths, array_length(v_paths, 1), 'deleted');

  return array_length(v_paths, 1);
end;
$$;

revoke all on function public.orphan_media_paths(text, text, interval) from public;
revoke all on function public.cleanup_orphan_media(text, text, boolean, interval) from public;

-- Both buckets, hourly. Photos stay armed -- that run was already verified.
-- Voices join armed too: the bucket is empty, so there is nothing to get wrong.
select cron.schedule(
  'orphan-media-cleanup',
  '0 * * * *',
  $cron$
    select public.cleanup_orphan_media('user_photos', 'photo', false),
           public.cleanup_orphan_media('user_voices', 'voice_intro', false);
  $cron$
);
