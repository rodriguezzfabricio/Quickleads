-- Schedule followup-dispatcher edge function every 15 minutes.

begin;

create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net with schema extensions;

-- Replace existing schedule to keep migration idempotent.
do $$
declare
  existing_job_id bigint;
begin
  select jobid
  into existing_job_id
  from cron.job
  where jobname = 'followup-dispatcher-every-15-min'
  limit 1;

  if existing_job_id is not null then
    perform cron.unschedule(existing_job_id);
  end if;
end
$$;

-- Requires Vault secrets:
--   project_url (e.g. https://<project-ref>.supabase.co)
--   service_role_key
-- Optional:
--   followup_dispatcher_secret (if FOLLOWUP_DISPATCHER_SECRET is configured)
select cron.schedule(
  'followup-dispatcher-every-15-min',
  '*/15 * * * *',
  $$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url') || '/functions/v1/followup-dispatcher',
    headers := jsonb_strip_nulls(
      jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key'),
        'x-dispatcher-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'followup_dispatcher_secret')
      )
    ),
    body := '{}'::jsonb
  );
  $$
);

commit;
