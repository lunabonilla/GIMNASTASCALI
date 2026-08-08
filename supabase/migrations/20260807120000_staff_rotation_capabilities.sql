alter table public.daily_staff_assignments
  add column if not exists assistant_profile_id uuid references public.staff_profiles(id) on delete set null;

create table if not exists public.staff_coaching_capabilities (
  id uuid primary key default gen_random_uuid(),
  staff_profile_id uuid not null references public.staff_profiles(id) on delete cascade,
  level_name text not null,
  assignment_role text not null default 'lead' check (assignment_role in ('lead', 'support')),
  requires_support boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  unique (staff_profile_id, level_name, assignment_role)
);

alter table public.staff_coaching_capabilities enable row level security;

create policy "staff reads coaching capabilities"
on public.staff_coaching_capabilities for select
to authenticated
using (true);

create policy "management manages coaching capabilities"
on public.staff_coaching_capabilities for all
to authenticated
using (public.is_management())
with check (public.is_management());

update public.staff_profiles set full_name = 'Daniela'
where lower(trim(full_name)) = 'dani';
update public.staff_profiles set full_name = 'Gilary'
where lower(trim(full_name)) = 'gila';
update public.staff_profiles set full_name = 'Lizeth'
where lower(trim(full_name)) = 'liz';

insert into public.staff_profiles (full_name, role, active)
select 'Francisco', 'coach'::public.staff_role, true
where not exists (
  select 1 from public.staff_profiles where lower(trim(full_name)) = 'francisco'
);

delete from public.staff_coaching_capabilities;

with capabilities(coach_name, level_name, assignment_role, requires_support, notes) as (
  values
    ('Luna', 'PRENIVEL', 'lead', false, null),
    ('Luna', 'NIVEL 1', 'lead', false, null),
    ('Luna', 'NIVEL 2', 'lead', false, null),
    ('Luna', 'NIVEL 3', 'support', false, null),
    ('Luna', 'NIVEL 4', 'support', false, null),
    ('Luna', 'NIVEL 5', 'support', false, null),
    ('Luna', 'NIVEL 6', 'support', false, null),
    ('William', 'NIVEL 1', 'lead', false, null), ('William', 'NIVEL 2', 'lead', false, null), ('William', 'NIVEL 3', 'lead', false, null), ('William', 'NIVEL 4', 'lead', false, null), ('William', 'NIVEL 5', 'lead', false, null), ('William', 'NIVEL 6', 'lead', false, null),
    ('Fabi', 'NIVEL 1', 'lead', false, null), ('Fabi', 'NIVEL 2', 'lead', false, null), ('Fabi', 'NIVEL 3', 'lead', false, null), ('Fabi', 'NIVEL 4', 'lead', false, null), ('Fabi', 'NIVEL 5', 'lead', false, null), ('Fabi', 'NIVEL 6', 'lead', false, null),
    ('Angel', 'NIVEL 1', 'lead', false, null), ('Angel', 'NIVEL 2', 'lead', false, null), ('Angel', 'NIVEL 3', 'lead', false, null), ('Angel', 'NIVEL 4', 'lead', false, null), ('Angel', 'NIVEL 5', 'lead', false, null), ('Angel', 'NIVEL 6', 'lead', false, null),
    ('Angie', 'NIVEL 1', 'lead', false, null), ('Angie', 'NIVEL 2', 'lead', false, null), ('Angie', 'NIVEL 3', 'lead', false, null), ('Angie', 'NIVEL 4', 'lead', false, null), ('Angie', 'NIVEL 5', 'lead', false, null), ('Angie', 'NIVEL 6', 'lead', false, null),
    ('Diana', 'PRENIVEL', 'lead', false, null), ('Diana', 'NIVEL 1', 'lead', false, null), ('Diana', 'NIVEL 2', 'lead', false, null), ('Diana', 'NIVEL 3', 'lead', false, null),
    ('Daniela', 'PRENIVEL', 'lead', true, 'Trabaja con apoyo'), ('Daniela', 'NIVEL 1', 'lead', true, 'Trabaja con apoyo'), ('Daniela', 'NIVEL 2', 'lead', true, 'Trabaja con apoyo'), ('Daniela', 'NIVEL 3', 'lead', true, 'Trabaja con apoyo'),
    ('Francisco', 'PRENIVEL', 'lead', true, 'Trabaja con apoyo'), ('Francisco', 'NIVEL 1', 'lead', true, 'Trabaja con apoyo'), ('Francisco', 'NIVEL 2', 'lead', true, 'Trabaja con apoyo'),
    ('Gilary', 'PRENIVEL', 'lead', false, null), ('Gilary', 'NIVEL 1', 'lead', false, null), ('Gilary', 'NIVEL 2', 'lead', false, null), ('Gilary', 'NIVEL 3', 'lead', false, null), ('Gilary', 'NIVEL 4', 'lead', false, null),
    ('Lizeth', 'PRENIVEL', 'lead', false, null), ('Lizeth', 'NIVEL 1', 'lead', false, null), ('Lizeth', 'NIVEL 2', 'lead', false, null), ('Lizeth', 'NIVEL 3', 'lead', false, null), ('Lizeth', 'NIVEL 4', 'lead', false, null),
    ('Richard', 'PRENIVEL', 'lead', false, null), ('Richard', 'NIVEL 1', 'lead', false, null), ('Richard', 'NIVEL 2', 'lead', false, null),
    ('Majo', 'PRENIVEL', 'lead', false, null), ('Majo', 'NIVEL 1', 'lead', false, null), ('Majo', 'NIVEL 2', 'lead', false, null), ('Majo', 'NIVEL 3', 'support', false, null), ('Majo', 'NIVEL 4', 'support', false, null)
)
insert into public.staff_coaching_capabilities (
  staff_profile_id, level_name, assignment_role, requires_support, notes
)
select staff.id, capabilities.level_name, capabilities.assignment_role,
       capabilities.requires_support, capabilities.notes
from capabilities
join public.staff_profiles staff
  on lower(trim(staff.full_name)) = lower(trim(capabilities.coach_name));
