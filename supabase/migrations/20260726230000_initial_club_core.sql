create extension if not exists pgcrypto;

create type public.staff_role as enum ('superadmin', 'administration', 'coach');
create type public.gymnast_status as enum ('active', 'suspended', 'retired');
create type public.group_type as enum ('regular', 'integral');
create type public.trial_status as enum (
  'scheduled',
  'attended',
  'no_show',
  'cancelled',
  'converted'
);
create type public.attendance_status as enum (
  'present',
  'absent',
  'excused',
  'makeup'
);

create table public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role public.staff_role not null default 'coach',
  phone text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.guardians (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  identity_document text,
  phone text not null,
  alternate_phone text,
  email text,
  relationship text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.levels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.gymnasts (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text not null,
  birth_date date not null,
  identity_document text unique,
  level_id uuid references public.levels(id) on delete set null,
  experience_notes text,
  joined_on date,
  status public.gymnast_status not null default 'active',
  status_effective_on date,
  status_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.gymnast_private_details (
  gymnast_id uuid primary key references public.gymnasts(id) on delete cascade,
  address text,
  health_provider text,
  allergies_conditions text,
  emergency_contact_name text,
  emergency_contact_phone text,
  medical_notes text,
  updated_at timestamptz not null default now()
);

create table public.gymnast_guardians (
  gymnast_id uuid not null references public.gymnasts(id) on delete cascade,
  guardian_id uuid not null references public.guardians(id) on delete cascade,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (gymnast_id, guardian_id)
);

create unique index gymnast_one_primary_guardian
  on public.gymnast_guardians(gymnast_id)
  where is_primary;

create table public.training_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  group_type public.group_type not null,
  level_id uuid references public.levels(id) on delete set null,
  coach_profile_id uuid references public.staff_profiles(id) on delete set null,
  minimum_age integer check (minimum_age is null or minimum_age >= 0),
  maximum_age integer check (
    maximum_age is null
    or maximum_age >= coalesce(minimum_age, 0)
  ),
  experience_requirement text,
  capacity integer not null check (capacity > 0),
  monthly_fee_cents bigint not null default 0 check (monthly_fee_cents >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.group_schedule_slots (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.training_groups(id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time not null,
  ends_at time not null,
  location text,
  created_at timestamptz not null default now(),
  constraint schedule_ends_after_start check (ends_at > starts_at),
  unique (group_id, weekday, starts_at)
);

create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  group_id uuid not null references public.training_groups(id) on delete restrict,
  starts_on date not null,
  ends_on date,
  active boolean not null default true,
  capacity_override boolean not null default false,
  override_reason text,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint enrollment_dates_valid check (
    ends_on is null or ends_on >= starts_on
  )
);

create unique index gymnast_one_active_enrollment
  on public.enrollments(gymnast_id)
  where active;

create table public.trial_bookings (
  id uuid primary key default gen_random_uuid(),
  prospect_first_name text not null,
  prospect_last_name text not null,
  birth_date date not null,
  guardian_name text not null,
  guardian_phone text not null,
  guardian_email text,
  experience_notes text,
  scheduled_for timestamptz not null,
  status public.trial_status not null default 'scheduled',
  attended boolean,
  evaluation_notes text,
  recommended_level_id uuid references public.levels(id) on delete set null,
  recommended_group_id uuid references public.training_groups(id) on delete set null,
  converted_gymnast_id uuid references public.gymnasts(id) on delete set null,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.class_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.training_groups(id) on delete restrict,
  schedule_slot_id uuid references public.group_schedule_slots(id) on delete set null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  cancelled_at timestamptz,
  cancellation_reason text,
  created_at timestamptz not null default now(),
  constraint class_ends_after_start check (ends_at > starts_at),
  unique (group_id, starts_at)
);

create table public.attendance_records (
  session_id uuid not null references public.class_sessions(id) on delete cascade,
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  status public.attendance_status not null,
  notes text,
  recorded_by uuid not null references public.staff_profiles(id) on delete restrict,
  recorded_at timestamptz not null default now(),
  primary key (session_id, gymnast_id)
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.staff_profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger staff_profiles_updated_at
before update on public.staff_profiles
for each row execute function public.set_updated_at();

create trigger guardians_updated_at
before update on public.guardians
for each row execute function public.set_updated_at();

create trigger gymnasts_updated_at
before update on public.gymnasts
for each row execute function public.set_updated_at();

create trigger gymnast_private_details_updated_at
before update on public.gymnast_private_details
for each row execute function public.set_updated_at();

create trigger training_groups_updated_at
before update on public.training_groups
for each row execute function public.set_updated_at();

create trigger trial_bookings_updated_at
before update on public.trial_bookings
for each row execute function public.set_updated_at();

create or replace function public.current_staff_role()
returns public.staff_role
language sql
stable
security definer
set search_path = ''
as $$
  select role
  from public.staff_profiles
  where id = auth.uid() and active = true;
$$;

create or replace function public.is_management()
returns boolean
language sql
stable
as $$
  select public.current_staff_role() in ('superadmin', 'administration');
$$;

create or replace function public.is_superadmin()
returns boolean
language sql
stable
as $$
  select public.current_staff_role() = 'superadmin';
$$;

alter table public.staff_profiles enable row level security;
alter table public.guardians enable row level security;
alter table public.levels enable row level security;
alter table public.gymnasts enable row level security;
alter table public.gymnast_private_details enable row level security;
alter table public.gymnast_guardians enable row level security;
alter table public.training_groups enable row level security;
alter table public.group_schedule_slots enable row level security;
alter table public.enrollments enable row level security;
alter table public.trial_bookings enable row level security;
alter table public.class_sessions enable row level security;
alter table public.attendance_records enable row level security;
alter table public.audit_logs enable row level security;

create policy "staff can read own profile"
on public.staff_profiles for select
to authenticated
using (id = auth.uid() or public.is_superadmin());

create policy "superadmin manages staff"
on public.staff_profiles for all
to authenticated
using (public.is_superadmin())
with check (public.is_superadmin());

create policy "management reads guardians"
on public.guardians for select
to authenticated
using (public.is_management());

create policy "superadmin manages guardians"
on public.guardians for all
to authenticated
using (public.is_superadmin())
with check (public.is_superadmin());

create policy "staff reads active levels"
on public.levels for select
to authenticated
using (active or public.is_management());

create policy "management manages levels"
on public.levels for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "authorized staff reads gymnasts"
on public.gymnasts for select
to authenticated
using (
  public.is_management()
  or exists (
    select 1
    from public.enrollments e
    join public.training_groups g on g.id = e.group_id
    where e.gymnast_id = gymnasts.id
      and e.active = true
      and g.coach_profile_id = auth.uid()
  )
);

create policy "superadmin manages gymnasts"
on public.gymnasts for all
to authenticated
using (public.is_superadmin())
with check (public.is_superadmin());

create policy "superadmin manages private details"
on public.gymnast_private_details for all
to authenticated
using (public.is_superadmin())
with check (public.is_superadmin());

create policy "management reads family links"
on public.gymnast_guardians for select
to authenticated
using (public.is_management());

create policy "superadmin manages family links"
on public.gymnast_guardians for all
to authenticated
using (public.is_superadmin())
with check (public.is_superadmin());

create policy "staff reads groups"
on public.training_groups for select
to authenticated
using (
  public.is_management()
  or coach_profile_id = auth.uid()
);

create policy "management manages groups"
on public.training_groups for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "staff reads schedule slots"
on public.group_schedule_slots for select
to authenticated
using (
  public.is_management()
  or exists (
    select 1 from public.training_groups g
    where g.id = group_schedule_slots.group_id
      and g.coach_profile_id = auth.uid()
  )
);

create policy "management manages schedule slots"
on public.group_schedule_slots for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "staff reads relevant enrollments"
on public.enrollments for select
to authenticated
using (
  public.is_management()
  or exists (
    select 1 from public.training_groups g
    where g.id = enrollments.group_id
      and g.coach_profile_id = auth.uid()
  )
);

create policy "management manages enrollments"
on public.enrollments for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages trials"
on public.trial_bookings for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "staff reads relevant sessions"
on public.class_sessions for select
to authenticated
using (
  public.is_management()
  or exists (
    select 1 from public.training_groups g
    where g.id = class_sessions.group_id
      and g.coach_profile_id = auth.uid()
  )
);

create policy "management manages sessions"
on public.class_sessions for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "staff reads relevant attendance"
on public.attendance_records for select
to authenticated
using (
  public.is_management()
  or exists (
    select 1
    from public.class_sessions s
    join public.training_groups g on g.id = s.group_id
    where s.id = attendance_records.session_id
      and g.coach_profile_id = auth.uid()
  )
);

create policy "staff records relevant attendance"
on public.attendance_records for all
to authenticated
using (
  public.is_management()
  or exists (
    select 1
    from public.class_sessions s
    join public.training_groups g on g.id = s.group_id
    where s.id = attendance_records.session_id
      and g.coach_profile_id = auth.uid()
  )
)
with check (
  public.is_management()
  or (
    recorded_by = auth.uid()
    and exists (
      select 1
      from public.class_sessions s
      join public.training_groups g on g.id = s.group_id
      where s.id = attendance_records.session_id
        and g.coach_profile_id = auth.uid()
    )
  )
);

create policy "superadmin reads audit logs"
on public.audit_logs for select
to authenticated
using (public.is_superadmin());

grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;
grant execute on function public.current_staff_role() to authenticated;
grant execute on function public.is_management() to authenticated;
grant execute on function public.is_superadmin() to authenticated;
