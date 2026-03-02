-- Extend sync_mutations entity_type check constraint to support
-- message_template outbox writes from Flutter.

begin;

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
    'followup_sequence',
    'call_log',
    'import',
    'notification',
    'device',
    'message_template'
  )
);

commit;
