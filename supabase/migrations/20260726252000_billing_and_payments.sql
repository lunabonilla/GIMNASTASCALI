create table public.billing_charges (
  id uuid primary key default gen_random_uuid(),
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  concept text not null,
  category text not null default 'monthly_fee'
    check (category in ('monthly_fee', 'extra_class', 'private_class', 'product', 'competition', 'other')),
  description text,
  issued_on date not null default current_date,
  due_on date not null,
  period_starts_on date,
  period_ends_on date,
  amount_cents bigint not null check (amount_cents > 0),
  voided_at timestamptz,
  void_reason text,
  created_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint billing_period_valid check (
    period_ends_on is null
    or period_starts_on is null
    or period_ends_on >= period_starts_on
  )
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  gymnast_id uuid not null references public.gymnasts(id) on delete restrict,
  paid_on date not null default current_date,
  amount_cents bigint not null check (amount_cents > 0),
  payment_method text not null default 'transfer'
    check (payment_method in ('cash', 'transfer', 'card', 'other')),
  reference text,
  notes text,
  received_by uuid references public.staff_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.payment_allocations (
  payment_id uuid not null references public.payments(id) on delete cascade,
  charge_id uuid not null references public.billing_charges(id) on delete restrict,
  amount_cents bigint not null check (amount_cents > 0),
  created_at timestamptz not null default now(),
  primary key (payment_id, charge_id)
);

create index billing_charges_gymnast_due_idx
  on public.billing_charges(gymnast_id, due_on);

create index payments_gymnast_paid_idx
  on public.payments(gymnast_id, paid_on desc);

create index payment_allocations_charge_idx
  on public.payment_allocations(charge_id);

create trigger billing_charges_updated_at
before update on public.billing_charges
for each row execute function public.set_updated_at();

create or replace function public.validate_payment_allocation()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  payment_total bigint;
  payment_gymnast uuid;
  charge_total bigint;
  charge_gymnast uuid;
  allocated_to_payment bigint;
  allocated_to_charge bigint;
begin
  select amount_cents, gymnast_id
  into payment_total, payment_gymnast
  from public.payments
  where id = new.payment_id;

  select amount_cents, gymnast_id
  into charge_total, charge_gymnast
  from public.billing_charges
  where id = new.charge_id and voided_at is null;

  if payment_gymnast is null or charge_gymnast is null then
    raise exception 'El pago o el cargo no existe';
  end if;

  if payment_gymnast <> charge_gymnast then
    raise exception 'El pago y el cargo pertenecen a gimnastas diferentes';
  end if;

  select coalesce(sum(amount_cents), 0)
  into allocated_to_payment
  from public.payment_allocations
  where payment_id = new.payment_id
    and charge_id <> new.charge_id;

  select coalesce(sum(amount_cents), 0)
  into allocated_to_charge
  from public.payment_allocations
  where charge_id = new.charge_id
    and payment_id <> new.payment_id;

  if allocated_to_payment + new.amount_cents > payment_total then
    raise exception 'La distribución supera el valor del pago';
  end if;

  if allocated_to_charge + new.amount_cents > charge_total then
    raise exception 'El abono supera el saldo pendiente del cargo';
  end if;

  return new;
end;
$$;

create trigger validate_payment_allocation_before_write
before insert or update on public.payment_allocations
for each row execute function public.validate_payment_allocation();

alter table public.billing_charges enable row level security;
alter table public.payments enable row level security;
alter table public.payment_allocations enable row level security;

create policy "management manages billing charges"
on public.billing_charges for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages payments"
on public.payments for all
to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages payment allocations"
on public.payment_allocations for all
to authenticated
using (public.is_management())
with check (public.is_management());

grant select, insert, update, delete on public.billing_charges to authenticated;
grant select, insert, update, delete on public.payments to authenticated;
grant select, insert, update, delete on public.payment_allocations to authenticated;
