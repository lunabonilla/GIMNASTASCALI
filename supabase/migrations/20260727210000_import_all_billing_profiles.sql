insert into public.gymnast_billing_profiles (
  gymnast_id, program, days_per_week
)
select
  (array_agg(gymnasts.id))[1],
  archive.raw_data->>'Programa',
  null
from public.notion_financial_archive archive
join public.gymnasts
  on lower(unaccent(trim(gymnasts.first_name || ' ' || gymnasts.last_name)))
   = lower(unaccent(trim(archive.person_name)))
where archive.record_type = 'cycle'
  and archive.raw_data->>'Programa' in ('Minis', 'Regular', 'Intensivo')
group by archive.person_name, archive.raw_data->>'Programa'
having count(gymnasts.id) = 1
on conflict (gymnast_id) do update set
  program = excluded.program,
  updated_at = now();
