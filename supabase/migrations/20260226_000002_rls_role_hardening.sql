-- Phase 0 hardening: least-privilege role checks for destructive policies.

begin;

create or replace function public.has_organization_role(
  target_organization_id uuid,
  allowed_roles text[]
)
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
      and p.role = any(allowed_roles)
  );
$$;

create or replace function public.is_organization_owner(target_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_organization_role(target_organization_id, array['owner']);
$$;

create or replace function public.is_organization_manager(target_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_organization_role(target_organization_id, array['manager']);
$$;

create or replace function public.is_organization_manager_or_owner(target_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_organization_role(target_organization_id, array['owner', 'manager']);
$$;

grant execute on function public.has_organization_role(uuid, text[]) to authenticated, service_role;
grant execute on function public.is_organization_owner(uuid) to authenticated, service_role;
grant execute on function public.is_organization_manager(uuid) to authenticated, service_role;
grant execute on function public.is_organization_manager_or_owner(uuid) to authenticated, service_role;

drop policy if exists leads_delete_member on public.leads;
create policy leads_delete_member
on public.leads
for delete
to authenticated
using (public.is_organization_manager_or_owner(organization_id));

drop policy if exists jobs_delete_member on public.jobs;
create policy jobs_delete_member
on public.jobs
for delete
to authenticated
using (public.is_organization_manager_or_owner(organization_id));

drop policy if exists message_templates_delete_member on public.message_templates;
create policy message_templates_delete_member
on public.message_templates
for delete
to authenticated
using (public.is_organization_manager_or_owner(organization_id));

drop policy if exists imports_delete_member on public.imports;
create policy imports_delete_member
on public.imports
for delete
to authenticated
using (
  public.is_organization_manager_or_owner(organization_id)
  or exists (
    select 1
    from public.profiles p
    where p.id = imports.uploaded_by
      and p.organization_id = imports.organization_id
      and p.auth_user_id = auth.uid()
  )
);

drop policy if exists notifications_delete_member on public.notifications;
create policy notifications_delete_member
on public.notifications
for delete
to authenticated
using (
  public.is_organization_manager_or_owner(organization_id)
  or exists (
    select 1
    from public.profiles p
    where p.id = notifications.profile_id
      and p.organization_id = notifications.organization_id
      and p.auth_user_id = auth.uid()
  )
);

commit;
