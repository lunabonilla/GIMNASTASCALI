create or replace function public.register_gymnast(
  p_first_name text,
  p_last_name text,
  p_birth_date date,
  p_identity_document text,
  p_level_id uuid,
  p_guardian_name text,
  p_guardian_phone text,
  p_guardian_relationship text,
  p_guardian_email text
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_gymnast_id uuid;
  v_guardian_id uuid;
begin
  if not public.is_superadmin() then
    raise exception 'No tienes permiso para registrar gimnastas';
  end if;

  insert into public.gymnasts (
    first_name,
    last_name,
    birth_date,
    identity_document,
    level_id,
    joined_on
  )
  values (
    trim(p_first_name),
    trim(p_last_name),
    p_birth_date,
    nullif(trim(p_identity_document), ''),
    p_level_id,
    current_date
  )
  returning id into v_gymnast_id;

  insert into public.guardians (
    full_name,
    phone,
    relationship,
    email
  )
  values (
    trim(p_guardian_name),
    trim(p_guardian_phone),
    nullif(trim(p_guardian_relationship), ''),
    nullif(trim(p_guardian_email), '')
  )
  returning id into v_guardian_id;

  insert into public.gymnast_guardians (
    gymnast_id,
    guardian_id,
    is_primary
  )
  values (v_gymnast_id, v_guardian_id, true);

  insert into public.audit_logs (
    actor_id,
    action,
    entity_type,
    entity_id
  )
  values (
    auth.uid(),
    'gymnast.created',
    'gymnast',
    v_gymnast_id
  );

  return v_gymnast_id;
end;
$$;

revoke all on function public.register_gymnast(
  text, text, date, text, uuid, text, text, text, text
) from public;

grant execute on function public.register_gymnast(
  text, text, date, text, uuid, text, text, text, text
) to authenticated;
