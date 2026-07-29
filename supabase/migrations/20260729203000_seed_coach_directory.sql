alter table public.staff_profiles
  drop constraint if exists staff_profiles_id_fkey;

alter table public.staff_profiles
  alter column id set default gen_random_uuid();

insert into public.staff_profiles (full_name, role, active)
select coach_name, 'coach'::public.staff_role, true
from (
  values
    ('Angel'),
    ('Fabi'),
    ('Dani'),
    ('Diana'),
    ('Luna'),
    ('William'),
    ('Gila'),
    ('Liz'),
    ('Angie'),
    ('Majo'),
    ('Richard')
) as coaches(coach_name)
where not exists (
  select 1
  from public.staff_profiles existing
  where lower(trim(existing.full_name)) = lower(trim(coach_name))
);
