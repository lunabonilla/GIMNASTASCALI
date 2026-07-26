create or replace function public.handle_new_staff_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  assigned_role public.staff_role;
begin
  perform pg_advisory_xact_lock(hashtext('club-first-staff-user'));

  if exists (select 1 from public.staff_profiles) then
    assigned_role := 'coach';
  else
    assigned_role := 'superadmin';
  end if;

  insert into public.staff_profiles (id, full_name, role)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      split_part(new.email, '@', 1)
    ),
    assigned_role
  )
  on conflict (id) do nothing;

  return new;
end;
$$;
