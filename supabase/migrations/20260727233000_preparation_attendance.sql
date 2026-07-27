create table public.preparation_sessions (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references public.preparation_programs(id) on delete cascade,
  session_on date not null,
  notes text,
  created_at timestamptz not null default now(),
  unique (program_id, session_on)
);

create table public.preparation_attendance (
  session_id uuid not null references public.preparation_sessions(id) on delete cascade,
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  status text not null check (status in ('attended', 'absent', 'double_class')),
  notes text,
  updated_at timestamptz not null default now(),
  primary key (session_id, gymnast_id)
);

alter table public.preparation_sessions enable row level security;
alter table public.preparation_attendance enable row level security;

create policy "management manages preparation sessions"
on public.preparation_sessions for all to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages preparation attendance"
on public.preparation_attendance for all to authenticated
using (public.is_management())
with check (public.is_management());

grant select, insert, update, delete on public.preparation_sessions to authenticated;
grant select, insert, update, delete on public.preparation_attendance to authenticated;

insert into public.preparation_programs (name, description, status)
select
  'Preparación Punta Cana',
  'Preparación para la próxima competencia en Punta Cana.',
  'draft'
where not exists (
  select 1 from public.preparation_programs
  where lower(name) = lower('Preparación Punta Cana')
);
