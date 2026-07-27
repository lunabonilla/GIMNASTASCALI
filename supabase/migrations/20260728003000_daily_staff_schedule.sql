create table public.daily_staff_assignments (
  id uuid primary key default gen_random_uuid(),
  work_date date not null,
  group_id uuid not null references public.training_groups(id) on delete cascade,
  schedule_slot_id uuid not null references public.group_schedule_slots(id) on delete cascade,
  coach_profile_id uuid references public.staff_profiles(id) on delete set null,
  notes text,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_date, schedule_slot_id)
);

create index daily_staff_assignments_date_idx
  on public.daily_staff_assignments(work_date);

create index daily_staff_assignments_coach_date_idx
  on public.daily_staff_assignments(coach_profile_id, work_date);

create trigger daily_staff_assignments_updated_at
before update on public.daily_staff_assignments
for each row execute function public.set_updated_at();

alter table public.daily_staff_assignments enable row level security;

create policy "staff reads daily assignments"
on public.daily_staff_assignments for select
to authenticated
using (
  public.is_management()
  or coach_profile_id = auth.uid()
);

create policy "management manages daily assignments"
on public.daily_staff_assignments for all
to authenticated
using (public.is_management())
with check (public.is_management());

