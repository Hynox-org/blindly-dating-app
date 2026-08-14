-- The dry run was verified: 21 files, all belonging to deleted test accounts,
-- none referenced by any row. Switching the job from reporting to deleting.
select cron.unschedule('orphan-photo-cleanup')
where exists (select 1 from cron.job where jobname = 'orphan-photo-cleanup');

select cron.schedule(
  'orphan-photo-cleanup',
  '0 * * * *',
  $cron$ select public.cleanup_orphan_photos(dry_run => false); $cron$
);
