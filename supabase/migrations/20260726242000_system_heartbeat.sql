create table public.system_heartbeat (
  id boolean primary key default true check (id),
  last_seen_at timestamptz not null default now()
);

alter table public.system_heartbeat enable row level security;

insert into public.system_heartbeat (id) values (true);

create or replace function public.keep_project_active()
returns timestamptz
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_seen_at timestamptz := now();
begin
  insert into public.system_heartbeat (id, last_seen_at)
  values (true, v_seen_at)
  on conflict (id)
  do update set last_seen_at = excluded.last_seen_at;

  return v_seen_at;
end;
$$;

revoke all on function public.keep_project_active() from public;
grant execute on function public.keep_project_active() to anon, authenticated;
