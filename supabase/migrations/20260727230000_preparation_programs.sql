create table public.preparation_programs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  coach_name text,
  starts_on date,
  ends_on date,
  base_price_cents bigint check (base_price_cents is null or base_price_cents >= 0),
  status text not null default 'draft'
    check (status in ('draft', 'open', 'active', 'finished', 'cancelled')),
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint preparation_program_dates_valid check (
    ends_on is null or starts_on is null or ends_on >= starts_on
  )
);

create table public.preparation_program_enrollments (
  program_id uuid not null references public.preparation_programs(id) on delete cascade,
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  agreed_price_cents bigint check (agreed_price_cents is null or agreed_price_cents >= 0),
  notes text,
  status text not null default 'active'
    check (status in ('active', 'completed', 'cancelled')),
  enrolled_at timestamptz not null default now(),
  primary key (program_id, gymnast_id)
);

create trigger preparation_programs_updated_at
before update on public.preparation_programs
for each row execute function public.set_updated_at();

alter table public.preparation_programs enable row level security;
alter table public.preparation_program_enrollments enable row level security;

create policy "management manages preparation programs"
on public.preparation_programs for all to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages preparation enrollments"
on public.preparation_program_enrollments for all to authenticated
using (public.is_management())
with check (public.is_management());

grant select, insert, update, delete on public.preparation_programs to authenticated;
grant select, insert, update, delete on public.preparation_program_enrollments to authenticated;
