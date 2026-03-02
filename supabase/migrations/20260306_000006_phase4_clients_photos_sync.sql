begin;

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 120),
  phone text check (phone is null or phone ~ '^\\+[1-9][0-9]{7,14}$'),
  email text,
  address text,
  notes text,
  source_lead_id uuid references public.leads(id) on delete set null,
  project_count integer not null default 0 check (project_count >= 0),
  version bigint not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists idx_clients_org_updated_at_desc
  on public.clients (organization_id, updated_at desc);

create index if not exists idx_clients_org_source_lead
  on public.clients (organization_id, source_lead_id)
  where deleted_at is null;

create unique index if not exists idx_clients_org_name_phone_active
  on public.clients (organization_id, lower(name), coalesce(phone, ''))
  where deleted_at is null;

drop trigger if exists trg_clients_set_updated_at on public.clients;
create trigger trg_clients_set_updated_at
before update on public.clients
for each row execute function public.set_updated_at();

alter table public.clients enable row level security;
alter table public.clients force row level security;

drop policy if exists clients_select_member on public.clients;
create policy clients_select_member
on public.clients
for select
using (public.is_organization_member(organization_id));

drop policy if exists clients_insert_member on public.clients;
create policy clients_insert_member
on public.clients
for insert
with check (public.is_organization_member(organization_id));

drop policy if exists clients_update_member on public.clients;
create policy clients_update_member
on public.clients
for update
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

drop policy if exists clients_delete_member on public.clients;
create policy clients_delete_member
on public.clients
for delete
using (public.is_organization_member(organization_id));

-- Extend sync_mutations entity_type check to include client.
do $$
declare
  constraint_name text;
begin
  select c.conname
  into constraint_name
  from pg_constraint c
  join pg_class t on t.oid = c.conrelid
  join pg_namespace n on n.oid = t.relnamespace
  where n.nspname = 'public'
    and t.relname = 'sync_mutations'
    and c.contype = 'c'
    and pg_get_constraintdef(c.oid) like '%entity_type%';

  if constraint_name is not null then
    execute format(
      'alter table public.sync_mutations drop constraint %I',
      constraint_name
    );
  end if;
end
$$;

alter table public.sync_mutations
add constraint sync_mutations_entity_type_check
check (
  entity_type in (
    'lead',
    'job',
    'client',
    'followup_sequence',
    'call_log',
    'import',
    'notification',
    'device',
    'message_template'
  )
);

-- Storage bucket and policies for job photos.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'job-photos',
  'job-photos',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

drop policy if exists job_photos_select_member on storage.objects;
create policy job_photos_select_member
on storage.objects
for select
to authenticated
using (
  bucket_id = 'job-photos'
  and split_part(name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
  and public.is_organization_member((split_part(name, '/', 1))::uuid)
);

drop policy if exists job_photos_insert_member on storage.objects;
create policy job_photos_insert_member
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'job-photos'
  and split_part(name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
  and public.is_organization_member((split_part(name, '/', 1))::uuid)
);

drop policy if exists job_photos_update_member on storage.objects;
create policy job_photos_update_member
on storage.objects
for update
to authenticated
using (
  bucket_id = 'job-photos'
  and split_part(name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
  and public.is_organization_member((split_part(name, '/', 1))::uuid)
)
with check (
  bucket_id = 'job-photos'
  and split_part(name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
  and public.is_organization_member((split_part(name, '/', 1))::uuid)
);

drop policy if exists job_photos_delete_member on storage.objects;
create policy job_photos_delete_member
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'job-photos'
  and split_part(name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
  and public.is_organization_member((split_part(name, '/', 1))::uuid)
);

commit;
