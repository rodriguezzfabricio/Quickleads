-- Phase 1 auth bootstrap fix:
-- Ensure bootstrap_organization sets organizations.created_by_auth_user_id.

begin;

create or replace function public.bootstrap_organization(
  p_auth_user_id uuid,
  p_business_name text,
  p_full_name text,
  p_timezone text default 'America/New_York'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_org_id uuid;
  v_profile_id uuid;
begin
  -- Guard: only service_role may call this
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'bootstrap_organization requires service_role';
  end if;

  -- Guard: user must not already own an organization
  if exists (
    select 1 from public.profiles
    where auth_user_id = p_auth_user_id and role = 'owner'
  ) then
    raise exception 'user already has an owner profile';
  end if;

  insert into public.organizations (name, timezone, created_by_auth_user_id)
  values (trim(p_business_name), p_timezone, p_auth_user_id)
  returning id into v_org_id;

  insert into public.profiles (organization_id, auth_user_id, full_name, role)
  values (v_org_id, p_auth_user_id, trim(p_full_name), 'owner')
  returning id into v_profile_id;

  insert into public.message_templates (organization_id, template_key, sms_body, email_subject, email_body, active)
  values
    (v_org_id, 'day_2_followup',
     'Hi {client_name}, this is {contractor_name}. Just checking in on the {job_type} estimate I sent. Any questions?',
     'Following up on your {job_type} estimate',
     'Hi {client_name},\n\nJust checking in on the {job_type} estimate I sent over. Let me know if you have any questions.\n\nBest,\n{contractor_name}',
     true),
    (v_org_id, 'day_5_followup',
     'Hi {client_name}, wanted to follow up on the {job_type} estimate. Happy to adjust anything. - {contractor_name}',
     'Quick follow-up: {job_type} estimate',
     'Hi {client_name},\n\nWanted to follow up on the {job_type} estimate. I am happy to go over it or make adjustments if needed.\n\nBest,\n{contractor_name}',
     true),
    (v_org_id, 'day_10_followup',
     'Hi {client_name}, final check-in on the {job_type} estimate. No pressure — just let me know either way. - {contractor_name}',
     'Last follow-up: {job_type} estimate',
     'Hi {client_name},\n\nThis is my last follow-up on the {job_type} estimate. No pressure at all — just let me know if you would like to move forward or if you have gone another direction.\n\nBest,\n{contractor_name}',
     true);

  return jsonb_build_object(
    'organization_id', v_org_id,
    'profile_id', v_profile_id
  );
end;
$$;

commit;
