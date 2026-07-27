alter table public.gymnast_billing_profiles
  add column if not exists custom_cycle_amount_cents bigint
    check (custom_cycle_amount_cents is null or custom_cycle_amount_cents > 0),
  add column if not exists pricing_notes text;
