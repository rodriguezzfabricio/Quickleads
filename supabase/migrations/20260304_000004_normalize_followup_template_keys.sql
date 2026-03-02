-- Normalize legacy follow-up template keys to canonical format:
-- day_2_followup, day_5_followup, day_10_followup

begin;

-- Deactivate legacy keys if a canonical key already exists.
update public.message_templates mt
set active = false
where mt.template_key in ('followup_day_2', 'followup_day_5', 'followup_day_10')
  and exists (
    select 1
    from public.message_templates canonical
    where canonical.organization_id = mt.organization_id
      and canonical.template_key = case mt.template_key
        when 'followup_day_2' then 'day_2_followup'
        when 'followup_day_5' then 'day_5_followup'
        when 'followup_day_10' then 'day_10_followup'
        else canonical.template_key
      end
  );

-- Rename remaining legacy keys to canonical keys when no canonical row exists.
update public.message_templates
set template_key = 'day_2_followup'
where template_key = 'followup_day_2'
  and not exists (
    select 1 from public.message_templates existing
    where existing.organization_id = message_templates.organization_id
      and existing.template_key = 'day_2_followup'
  );

update public.message_templates
set template_key = 'day_5_followup'
where template_key = 'followup_day_5'
  and not exists (
    select 1 from public.message_templates existing
    where existing.organization_id = message_templates.organization_id
      and existing.template_key = 'day_5_followup'
  );

update public.message_templates
set template_key = 'day_10_followup'
where template_key = 'followup_day_10'
  and not exists (
    select 1 from public.message_templates existing
    where existing.organization_id = message_templates.organization_id
      and existing.template_key = 'day_10_followup'
  );

commit;
