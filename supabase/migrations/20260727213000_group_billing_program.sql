alter table public.training_groups
  add column if not exists billing_program text
  check (billing_program is null or billing_program in ('Minis', 'Regular', 'Intensivo'));

update public.training_groups
set billing_program = case
  when group_type = 'integral' then 'Intensivo'
  else 'Regular'
end
where billing_program is null;
