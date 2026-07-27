-- Completa fechas de nacimiento ya existentes en el control de ciclos de Notion.
-- No reemplaza ninguna fecha que haya sido registrada posteriormente en la plataforma.
with notion_birth_dates as (
  select
    lower(unaccent(trim(person_name))) as normalized_name,
    to_date(raw_data ->> 'Fecha de nacimiento', 'MM/DD/YYYY') as birth_date
  from public.notion_financial_archive
  where record_type = 'cycle'
    and coalesce(raw_data ->> 'Fecha de nacimiento', '') ~
      '^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/[0-9]{4}$'
),
consistent_birth_dates as (
  select normalized_name, min(birth_date) as birth_date
  from notion_birth_dates
  group by normalized_name
  having min(birth_date) = max(birth_date)
),
matched_gymnasts as (
  select
    gymnast.id,
    source.birth_date
  from public.gymnasts as gymnast
  join consistent_birth_dates as source
    on lower(
      unaccent(trim(concat_ws(' ', gymnast.first_name, gymnast.last_name)))
    ) = source.normalized_name
  where gymnast.birth_date is null
)
update public.gymnasts as gymnast
set
  birth_date = matched.birth_date,
  updated_at = now()
from matched_gymnasts as matched
where gymnast.id = matched.id;
