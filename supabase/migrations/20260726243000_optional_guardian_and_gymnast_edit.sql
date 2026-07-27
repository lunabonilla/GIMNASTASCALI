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
    first_name, last_name, birth_date, identity_document, level_id, joined_on
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

  if nullif(trim(p_guardian_name), '') is not null
    or nullif(trim(p_guardian_phone), '') is not null then
    insert into public.guardians (
      full_name, phone, relationship, email
    )
    values (
      coalesce(nullif(trim(p_guardian_name), ''), 'Responsable por completar'),
      coalesce(nullif(trim(p_guardian_phone), ''), 'Por completar'),
      nullif(trim(p_guardian_relationship), ''),
      nullif(trim(p_guardian_email), '')
    )
    returning id into v_guardian_id;

    insert into public.gymnast_guardians (
      gymnast_id, guardian_id, is_primary
    )
    values (v_gymnast_id, v_guardian_id, true);
  end if;

  insert into public.audit_logs (
    actor_id, action, entity_type, entity_id
  )
  values (auth.uid(), 'gymnast.created', 'gymnast', v_gymnast_id);

  return v_gymnast_id;
end;
$$;

create or replace function public.update_gymnast_profile(
  p_gymnast_id uuid,
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
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_guardian_id uuid;
begin
  if not public.is_superadmin() then
    raise exception 'No tienes permiso para editar gimnastas';
  end if;

  update public.gymnasts
  set
    first_name = trim(p_first_name),
    last_name = trim(p_last_name),
    birth_date = p_birth_date,
    identity_document = nullif(trim(p_identity_document), ''),
    level_id = p_level_id
  where id = p_gymnast_id;

  select guardian_id
  into v_guardian_id
  from public.gymnast_guardians
  where gymnast_id = p_gymnast_id and is_primary
  limit 1;

  if v_guardian_id is not null then
    update public.guardians
    set
      full_name = coalesce(nullif(trim(p_guardian_name), ''), 'Responsable por completar'),
      phone = coalesce(nullif(trim(p_guardian_phone), ''), 'Por completar'),
      relationship = nullif(trim(p_guardian_relationship), ''),
      email = nullif(trim(p_guardian_email), '')
    where id = v_guardian_id;
  elsif nullif(trim(p_guardian_name), '') is not null
    or nullif(trim(p_guardian_phone), '') is not null then
    insert into public.guardians (full_name, phone, relationship, email)
    values (
      coalesce(nullif(trim(p_guardian_name), ''), 'Responsable por completar'),
      coalesce(nullif(trim(p_guardian_phone), ''), 'Por completar'),
      nullif(trim(p_guardian_relationship), ''),
      nullif(trim(p_guardian_email), '')
    )
    returning id into v_guardian_id;

    insert into public.gymnast_guardians (gymnast_id, guardian_id, is_primary)
    values (p_gymnast_id, v_guardian_id, true);
  end if;

  insert into public.audit_logs (actor_id, action, entity_type, entity_id)
  values (auth.uid(), 'gymnast.updated', 'gymnast', p_gymnast_id);
end;
$$;

revoke all on function public.update_gymnast_profile(
  uuid, text, text, date, text, uuid, text, text, text, text
) from public;

grant execute on function public.update_gymnast_profile(
  uuid, text, text, date, text, uuid, text, text, text, text
) to authenticated;
