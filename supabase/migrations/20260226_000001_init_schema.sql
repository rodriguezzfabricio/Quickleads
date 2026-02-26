-- Phase 0: Initial schema foundation with tenant-safe RLS.

begin;

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 1 and 120),
  timezone text not null default 'America/New_York' check (char_length(trim(timezone)) between 1 and 100),
  created_by_auth_user_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  auth_user_id uuid not null unique,
  full_name text not null check (char_length(trim(full_name)) between 1 and 120),
  role text not null default 'owner' check (role in ('owner', 'manager', 'member')),
  phone_e164 text check (phone_e164 ~ '^\\+[1-9][0-9]{7,14}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  device_identifier text not null check (char_length(trim(device_identifier)) between 1 and 190),
  platform text not null check (platform in ('ios', 'android')),
  fcm_token text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, device_identifier)
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  created_by_profile_id uuid references public.profiles(id) on delete set null,
  client_name text not null check (char_length(trim(client_name)) between 1 and 120),
  phone_e164 text check (phone_e164 ~ '^\\+[1-9][0-9]{7,14}$'),
  email text,
  job_type text not null check (char_length(trim(job_type)) between 1 and 80),
  notes text,
  status text not null default 'new_callback' check (status in ('new_callback', 'estimate_sent', 'won', 'cold')),
  followup_state text not null default 'none' check (followup_state in ('none', 'active', 'paused', 'stopped', 'completed')),
  estimate_sent_at timestamptz,
  version bigint not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.followup_sequences (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  lead_id uuid not null unique references public.leads(id) on delete cascade,
  state text not null default 'active' check (state in ('active', 'paused', 'stopped', 'completed')),
  start_date_local date not null,
  timezone text not null check (char_length(trim(timezone)) between 1 and 100),
  next_send_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  paused_at timestamptz,
  stopped_at timestamptz,
  completed_at timestamptz
);

create table if not exists public.followup_messages (
  id uuid primary key default gen_random_uuid(),
  sequence_id uuid not null references public.followup_sequences(id) on delete cascade,
  step_number integer not null check (step_number > 0),
  channel text not null check (channel in ('sms', 'email')),
  template_key text not null check (char_length(trim(template_key)) between 1 and 100),
  scheduled_at timestamptz not null,
  sent_at timestamptz,
  status text not null default 'queued' check (status in ('queued', 'sent', 'failed', 'canceled')),
  retry_count integer not null default 0 check (retry_count >= 0),
  provider_message_id text,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  lead_id uuid unique references public.leads(id) on delete set null,
  client_name text not null check (char_length(trim(client_name)) between 1 and 120),
  job_type text not null check (char_length(trim(job_type)) between 1 and 80),
  phase text not null default 'demo' check (phase in ('demo', 'rough', 'electrical_plumbing', 'finishing', 'walkthrough', 'complete')),
  health_status text not null default 'green' check (health_status in ('green', 'yellow', 'red')),
  estimated_completion_date date,
  version bigint not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.job_photos (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  storage_path text not null check (char_length(trim(storage_path)) > 0),
  taken_at_source text,
  uploaded_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.call_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete set null,
  phone_e164 text not null check (phone_e164 ~ '^\\+[1-9][0-9]{7,14}$'),
  platform text not null check (platform in ('android', 'ios', 'unknown')),
  source text not null check (source in ('native_observer', 'resume_prompt', 'share_sheet', 'widget', 'siri_shortcut', 'manual', 'daily_sweep')),
  started_at timestamptz not null,
  duration_sec integer not null default 0 check (duration_sec >= 0),
  disposition text not null default 'unknown' check (disposition in ('unknown', 'saved_as_lead', 'skipped', 'matched_existing')),
  created_at timestamptz not null default now()
);

create table if not exists public.message_templates (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  template_key text not null check (char_length(trim(template_key)) between 1 and 100),
  sms_body text not null check (char_length(trim(sms_body)) > 0),
  email_subject text,
  email_body text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, template_key)
);

create table if not exists public.imports (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id) on delete restrict,
  file_name text not null check (char_length(trim(file_name)) > 0),
  status text not null default 'pending' check (status in ('pending', 'processing', 'completed', 'failed')),
  total_rows integer not null default 0 check (total_rows >= 0),
  success_rows integer not null default 0 check (success_rows >= 0),
  failed_rows integer not null default 0 check (failed_rows >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.import_rows (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  row_number integer not null check (row_number > 0),
  raw_payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending' check (status in ('pending', 'imported', 'failed', 'skipped')),
  error_reason text,
  lead_id uuid references public.leads(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (import_id, row_number)
);

create table if not exists public.sync_mutations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  entity_id uuid,
  entity_type text not null check (entity_type in ('lead', 'job', 'followup_sequence', 'call_log', 'import', 'notification', 'device')),
  mutation_type text not null check (mutation_type in ('insert', 'update', 'delete', 'status_transition')),
  client_mutation_id uuid not null,
  base_version bigint check (base_version is null or base_version > 0),
  payload jsonb not null default '{}'::jsonb,
  had_conflict boolean not null default false,
  resolution text,
  created_at timestamptz not null default now(),
  processed_at timestamptz
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete set null,
  type text not null check (char_length(trim(type)) > 0),
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued' check (status in ('queued', 'sent', 'failed', 'read')),
  scheduled_at timestamptz,
  sent_at timestamptz,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.is_organization_member(target_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.auth_user_id = auth.uid()
      and p.organization_id = target_organization_id
  );
$$;

create or replace function public.is_organization_owner(target_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.auth_user_id = auth.uid()
      and p.organization_id = target_organization_id
      and p.role = 'owner'
  );
$$;

create or replace function public.current_organization_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.organization_id
  from public.profiles p
  where p.auth_user_id = auth.uid()
  order by p.created_at asc
  limit 1;
$$;

grant execute on function public.is_organization_member(uuid) to authenticated, service_role;
grant execute on function public.is_organization_owner(uuid) to authenticated, service_role;
grant execute on function public.current_organization_id() to authenticated, service_role;

create index if not exists idx_organizations_created_by_auth_user_id
  on public.organizations (created_by_auth_user_id);

create index if not exists idx_profiles_organization_id
  on public.profiles (organization_id);

create index if not exists idx_profiles_auth_user_id
  on public.profiles (auth_user_id);

create index if not exists idx_devices_organization_id
  on public.devices (organization_id);

create index if not exists idx_devices_profile_id
  on public.devices (profile_id);

create index if not exists idx_devices_last_seen_at_desc
  on public.devices (organization_id, last_seen_at desc);

create index if not exists idx_leads_org_status_updated_at_desc
  on public.leads (organization_id, status, updated_at desc);

create unique index if not exists idx_leads_org_phone_unique_active
  on public.leads (organization_id, phone_e164)
  where phone_e164 is not null and deleted_at is null;

create index if not exists idx_leads_org_updated_at_desc
  on public.leads (organization_id, updated_at desc);

create index if not exists idx_followup_sequences_org_state_next_send
  on public.followup_sequences (organization_id, state, next_send_at);

create index if not exists idx_followup_sequences_lead_id
  on public.followup_sequences (lead_id);

create unique index if not exists idx_followup_messages_sequence_step_unique
  on public.followup_messages (sequence_id, step_number);

create index if not exists idx_followup_messages_status_scheduled_at
  on public.followup_messages (status, scheduled_at);

create index if not exists idx_jobs_org_phase_health
  on public.jobs (organization_id, phase, health_status);

create index if not exists idx_jobs_org_updated_at_desc
  on public.jobs (organization_id, updated_at desc);

create index if not exists idx_job_photos_org_job
  on public.job_photos (organization_id, job_id);

create index if not exists idx_call_logs_org_disposition_started_desc
  on public.call_logs (organization_id, disposition, started_at desc);

create index if not exists idx_call_logs_org_phone
  on public.call_logs (organization_id, phone_e164);

create index if not exists idx_message_templates_org_active
  on public.message_templates (organization_id, active);

create index if not exists idx_imports_org_created_at_desc
  on public.imports (organization_id, created_at desc);

create index if not exists idx_import_rows_import_status
  on public.import_rows (import_id, status);

create unique index if not exists idx_sync_mutations_org_client_mutation_id_unique
  on public.sync_mutations (organization_id, client_mutation_id);

create index if not exists idx_sync_mutations_org_created_at_desc
  on public.sync_mutations (organization_id, created_at desc);

create index if not exists idx_notifications_org_status_scheduled
  on public.notifications (organization_id, status, scheduled_at);

create index if not exists idx_notifications_profile_status
  on public.notifications (profile_id, status);

drop trigger if exists organizations_set_updated_at on public.organizations;
create trigger organizations_set_updated_at
before update on public.organizations
for each row execute function public.set_updated_at();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists devices_set_updated_at on public.devices;
create trigger devices_set_updated_at
before update on public.devices
for each row execute function public.set_updated_at();

drop trigger if exists leads_set_updated_at on public.leads;
create trigger leads_set_updated_at
before update on public.leads
for each row execute function public.set_updated_at();

drop trigger if exists followup_sequences_set_updated_at on public.followup_sequences;
create trigger followup_sequences_set_updated_at
before update on public.followup_sequences
for each row execute function public.set_updated_at();

drop trigger if exists followup_messages_set_updated_at on public.followup_messages;
create trigger followup_messages_set_updated_at
before update on public.followup_messages
for each row execute function public.set_updated_at();

drop trigger if exists jobs_set_updated_at on public.jobs;
create trigger jobs_set_updated_at
before update on public.jobs
for each row execute function public.set_updated_at();

drop trigger if exists message_templates_set_updated_at on public.message_templates;
create trigger message_templates_set_updated_at
before update on public.message_templates
for each row execute function public.set_updated_at();

drop trigger if exists imports_set_updated_at on public.imports;
create trigger imports_set_updated_at
before update on public.imports
for each row execute function public.set_updated_at();

drop trigger if exists import_rows_set_updated_at on public.import_rows;
create trigger import_rows_set_updated_at
before update on public.import_rows
for each row execute function public.set_updated_at();

drop trigger if exists notifications_set_updated_at on public.notifications;
create trigger notifications_set_updated_at
before update on public.notifications
for each row execute function public.set_updated_at();

grant select, insert, update, delete on table
  public.organizations,
  public.profiles,
  public.devices,
  public.leads,
  public.followup_sequences,
  public.followup_messages,
  public.jobs,
  public.job_photos,
  public.call_logs,
  public.message_templates,
  public.imports,
  public.import_rows,
  public.sync_mutations,
  public.notifications
to authenticated;

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.devices enable row level security;
alter table public.leads enable row level security;
alter table public.followup_sequences enable row level security;
alter table public.followup_messages enable row level security;
alter table public.jobs enable row level security;
alter table public.job_photos enable row level security;
alter table public.call_logs enable row level security;
alter table public.message_templates enable row level security;
alter table public.imports enable row level security;
alter table public.import_rows enable row level security;
alter table public.sync_mutations enable row level security;
alter table public.notifications enable row level security;

alter table public.organizations force row level security;
alter table public.profiles force row level security;
alter table public.devices force row level security;
alter table public.leads force row level security;
alter table public.followup_sequences force row level security;
alter table public.followup_messages force row level security;
alter table public.jobs force row level security;
alter table public.job_photos force row level security;
alter table public.call_logs force row level security;
alter table public.message_templates force row level security;
alter table public.imports force row level security;
alter table public.import_rows force row level security;
alter table public.sync_mutations force row level security;
alter table public.notifications force row level security;

drop policy if exists organizations_select_member on public.organizations;
create policy organizations_select_member
on public.organizations
for select
to authenticated
using (public.is_organization_member(id));

drop policy if exists organizations_insert_creator on public.organizations;
create policy organizations_insert_creator
on public.organizations
for insert
to authenticated
with check (created_by_auth_user_id = auth.uid());

drop policy if exists organizations_update_owner on public.organizations;
create policy organizations_update_owner
on public.organizations
for update
to authenticated
using (public.is_organization_owner(id))
with check (public.is_organization_owner(id));

drop policy if exists organizations_delete_owner on public.organizations;
create policy organizations_delete_owner
on public.organizations
for delete
to authenticated
using (public.is_organization_owner(id));

drop policy if exists profiles_select_member on public.profiles;
create policy profiles_select_member
on public.profiles
for select
to authenticated
using (
  auth_user_id = auth.uid()
  or public.is_organization_member(organization_id)
);

drop policy if exists profiles_insert_self_or_member on public.profiles;
create policy profiles_insert_self_or_member
on public.profiles
for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  and (
    public.is_organization_member(organization_id)
    or exists (
      select 1
      from public.organizations o
      where o.id = profiles.organization_id
        and o.created_by_auth_user_id = auth.uid()
    )
  )
);

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self
on public.profiles
for update
to authenticated
using (
  auth_user_id = auth.uid()
  and public.is_organization_member(organization_id)
)
with check (
  auth_user_id = auth.uid()
  and public.is_organization_member(organization_id)
);

drop policy if exists profiles_delete_owner on public.profiles;
create policy profiles_delete_owner
on public.profiles
for delete
to authenticated
using (public.is_organization_owner(organization_id));

drop policy if exists devices_select_member on public.devices;
create policy devices_select_member
on public.devices
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists devices_insert_self on public.devices;
create policy devices_insert_self
on public.devices
for insert
to authenticated
with check (
  public.is_organization_member(organization_id)
  and exists (
    select 1
    from public.profiles p
    where p.id = devices.profile_id
      and p.organization_id = devices.organization_id
      and p.auth_user_id = auth.uid()
  )
);

drop policy if exists devices_update_self on public.devices;
create policy devices_update_self
on public.devices
for update
to authenticated
using (
  public.is_organization_member(organization_id)
  and exists (
    select 1
    from public.profiles p
    where p.id = devices.profile_id
      and p.organization_id = devices.organization_id
      and p.auth_user_id = auth.uid()
  )
)
with check (
  public.is_organization_member(organization_id)
  and exists (
    select 1
    from public.profiles p
    where p.id = devices.profile_id
      and p.organization_id = devices.organization_id
      and p.auth_user_id = auth.uid()
  )
);

drop policy if exists devices_delete_self on public.devices;
create policy devices_delete_self
on public.devices
for delete
to authenticated
using (
  public.is_organization_member(organization_id)
  and exists (
    select 1
    from public.profiles p
    where p.id = devices.profile_id
      and p.organization_id = devices.organization_id
      and p.auth_user_id = auth.uid()
  )
);

drop policy if exists leads_select_member on public.leads;
create policy leads_select_member
on public.leads
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists leads_insert_member on public.leads;
create policy leads_insert_member
on public.leads
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists leads_update_member on public.leads;
create policy leads_update_member
on public.leads
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists leads_delete_member on public.leads;
create policy leads_delete_member
on public.leads
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists followup_sequences_select_member on public.followup_sequences;
create policy followup_sequences_select_member
on public.followup_sequences
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists followup_sequences_insert_member on public.followup_sequences;
create policy followup_sequences_insert_member
on public.followup_sequences
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists followup_sequences_update_member on public.followup_sequences;
create policy followup_sequences_update_member
on public.followup_sequences
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists followup_sequences_delete_member on public.followup_sequences;
create policy followup_sequences_delete_member
on public.followup_sequences
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists followup_messages_select_member on public.followup_messages;
create policy followup_messages_select_member
on public.followup_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.followup_sequences fs
    where fs.id = followup_messages.sequence_id
      and public.is_organization_member(fs.organization_id)
  )
);

drop policy if exists followup_messages_insert_member on public.followup_messages;
create policy followup_messages_insert_member
on public.followup_messages
for insert
to authenticated
with check (
  exists (
    select 1
    from public.followup_sequences fs
    where fs.id = followup_messages.sequence_id
      and public.is_organization_member(fs.organization_id)
  )
);

drop policy if exists followup_messages_update_member on public.followup_messages;
create policy followup_messages_update_member
on public.followup_messages
for update
to authenticated
using (
  exists (
    select 1
    from public.followup_sequences fs
    where fs.id = followup_messages.sequence_id
      and public.is_organization_member(fs.organization_id)
  )
)
with check (
  exists (
    select 1
    from public.followup_sequences fs
    where fs.id = followup_messages.sequence_id
      and public.is_organization_member(fs.organization_id)
  )
);

drop policy if exists followup_messages_delete_member on public.followup_messages;
create policy followup_messages_delete_member
on public.followup_messages
for delete
to authenticated
using (
  exists (
    select 1
    from public.followup_sequences fs
    where fs.id = followup_messages.sequence_id
      and public.is_organization_member(fs.organization_id)
  )
);

drop policy if exists jobs_select_member on public.jobs;
create policy jobs_select_member
on public.jobs
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists jobs_insert_member on public.jobs;
create policy jobs_insert_member
on public.jobs
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists jobs_update_member on public.jobs;
create policy jobs_update_member
on public.jobs
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists jobs_delete_member on public.jobs;
create policy jobs_delete_member
on public.jobs
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists job_photos_select_member on public.job_photos;
create policy job_photos_select_member
on public.job_photos
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists job_photos_insert_member on public.job_photos;
create policy job_photos_insert_member
on public.job_photos
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists job_photos_update_member on public.job_photos;
create policy job_photos_update_member
on public.job_photos
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists job_photos_delete_member on public.job_photos;
create policy job_photos_delete_member
on public.job_photos
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists call_logs_select_member on public.call_logs;
create policy call_logs_select_member
on public.call_logs
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists call_logs_insert_member on public.call_logs;
create policy call_logs_insert_member
on public.call_logs
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists call_logs_update_member on public.call_logs;
create policy call_logs_update_member
on public.call_logs
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists call_logs_delete_member on public.call_logs;
create policy call_logs_delete_member
on public.call_logs
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists message_templates_select_member on public.message_templates;
create policy message_templates_select_member
on public.message_templates
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists message_templates_insert_member on public.message_templates;
create policy message_templates_insert_member
on public.message_templates
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists message_templates_update_member on public.message_templates;
create policy message_templates_update_member
on public.message_templates
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists message_templates_delete_member on public.message_templates;
create policy message_templates_delete_member
on public.message_templates
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists imports_select_member on public.imports;
create policy imports_select_member
on public.imports
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists imports_insert_member on public.imports;
create policy imports_insert_member
on public.imports
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists imports_update_member on public.imports;
create policy imports_update_member
on public.imports
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists imports_delete_member on public.imports;
create policy imports_delete_member
on public.imports
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists import_rows_select_member on public.import_rows;
create policy import_rows_select_member
on public.import_rows
for select
to authenticated
using (
  exists (
    select 1
    from public.imports i
    where i.id = import_rows.import_id
      and public.is_organization_member(i.organization_id)
  )
);

drop policy if exists import_rows_insert_member on public.import_rows;
create policy import_rows_insert_member
on public.import_rows
for insert
to authenticated
with check (
  exists (
    select 1
    from public.imports i
    where i.id = import_rows.import_id
      and public.is_organization_member(i.organization_id)
  )
);

drop policy if exists import_rows_update_member on public.import_rows;
create policy import_rows_update_member
on public.import_rows
for update
to authenticated
using (
  exists (
    select 1
    from public.imports i
    where i.id = import_rows.import_id
      and public.is_organization_member(i.organization_id)
  )
)
with check (
  exists (
    select 1
    from public.imports i
    where i.id = import_rows.import_id
      and public.is_organization_member(i.organization_id)
  )
);

drop policy if exists import_rows_delete_member on public.import_rows;
create policy import_rows_delete_member
on public.import_rows
for delete
to authenticated
using (
  exists (
    select 1
    from public.imports i
    where i.id = import_rows.import_id
      and public.is_organization_member(i.organization_id)
  )
);

drop policy if exists sync_mutations_select_member on public.sync_mutations;
create policy sync_mutations_select_member
on public.sync_mutations
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists sync_mutations_insert_member on public.sync_mutations;
create policy sync_mutations_insert_member
on public.sync_mutations
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists sync_mutations_update_member on public.sync_mutations;
create policy sync_mutations_update_member
on public.sync_mutations
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists sync_mutations_delete_member on public.sync_mutations;
create policy sync_mutations_delete_member
on public.sync_mutations
for delete
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists notifications_select_member on public.notifications;
create policy notifications_select_member
on public.notifications
for select
to authenticated
using (public.is_organization_member(organization_id));

drop policy if exists notifications_insert_member on public.notifications;
create policy notifications_insert_member
on public.notifications
for insert
to authenticated
with check (public.is_organization_member(organization_id));

drop policy if exists notifications_update_member on public.notifications;
create policy notifications_update_member
on public.notifications
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists notifications_delete_member on public.notifications;
create policy notifications_delete_member
on public.notifications
for delete
to authenticated
using (public.is_organization_member(organization_id));

commit;
