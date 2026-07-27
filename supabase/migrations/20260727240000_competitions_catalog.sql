create table public.competitions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  year integer,
  status text not null default 'defining'
    check (status in ('confirmed', 'defining', 'cancelled', 'completed')),
  starts_on date,
  ends_on date,
  registration_deadline_1 date,
  registration_deadline_2 date,
  city text,
  country text,
  venue text,
  estimated_cost_cents bigint check (estimated_cost_cents is null or estimated_cost_cents >= 0),
  notes text,
  source_name text,
  source_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index competitions_name_year_unique
on public.competitions(name, coalesce(year, 0));

create trigger competitions_updated_at
before update on public.competitions
for each row execute function public.set_updated_at();

alter table public.competitions enable row level security;
create policy "management manages competitions"
on public.competitions for all to authenticated
using (public.is_management())
with check (public.is_management());
grant select, insert, update, delete on public.competitions to authenticated;

insert into public.competitions
(name, year, status, starts_on, ends_on, registration_deadline_1, registration_deadline_2, city, country, venue, notes, source_name, source_data)
values
('Competencia Club Élite', 2026, 'confirmed', '2026-02-27', '2026-02-27', '2026-10-15', '2026-11-15', 'Cali', 'Colombia', 'Coliseo del Pueblo', 'Revisar límites de inscripción: en Notion aparecen después de la fecha del evento.', 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"febrero"}'),
('Copa Palmira', 2026, 'confirmed', null, null, null, null, 'Palmira', 'Colombia', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada"}'),
('1er Campeonato Nacional', 2026, 'confirmed', '2026-04-08', '2026-04-12', null, null, 'Armenia', 'Colombia', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"abril"}'),
('2do Campeonato Nacional', 2026, 'confirmed', '2026-06-03', '2026-06-07', null, null, 'Cartagena', 'Colombia', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"junio"}'),
('3er Campeonato Nacional', 2026, 'confirmed', '2026-08-05', '2026-08-09', null, null, 'Ibagué', 'Colombia', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"agosto"}'),
('4to Campeonato Nacional', 2026, 'confirmed', '2026-10-14', '2026-10-18', null, null, null, 'Colombia', 'Sede por definir', null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"octubre"}'),
('Copa Cartago', 2026, 'confirmed', '2026-08-23', '2026-08-24', null, null, 'Cartago', 'Colombia', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"agosto"}'),
('Punta Cana', 2026, 'confirmed', '2026-08-20', '2026-08-24', null, null, 'Punta Cana', 'República Dominicana', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"agosto"}'),
('Guayaquil Classic Gymnastics', 2026, 'confirmed', '2026-10-23', '2026-10-25', null, null, 'Guayaquil', 'Ecuador', null, null, 'Competencias 2026–2027', '{"estado_original":"Confirmada","mes":"octubre"}'),
('Santo Domingo Classic', null, 'defining', null, null, null, null, 'Santo Domingo', 'República Dominicana', null, 'Oct–Nov; año por definir.', 'Competencias 2026–2027', '{"estado_original":"En definición"}'),
('Sun & Surf Spectacular', 2027, 'defining', '2027-01-30', '2027-02-01', null, null, 'Coral Springs', 'Estados Unidos', null, 'usacompetitions.com', 'Competencias 2026–2027', '{"estado_original":"En definición","mes":"enero"}'),
('SuperLiga', 2026, 'defining', '2026-04-18', '2026-04-18', null, null, 'Cali', 'Colombia', 'Colegio International los Cañaverales', null, 'Competencias 2026–2027', '{"mes":"abril"}'),
('Festival departamental', 2026, 'defining', '2026-05-23', '2026-05-24', '2026-05-08', null, 'Cali', 'Colombia', null, null, 'Competencias 2026–2027', '{"mes":"mayo"}'),
('El Salto Team Challenge', 2026, 'defining', '2026-05-28', '2026-05-31', null, null, null, 'El Salvador', null, null, 'Competencias Varias', '{"mes":"Mayo"}'),
('No Limit Internacional', 2026, 'defining', '2026-07-30', '2026-07-30', null, null, 'Ciudad de Panamá', 'Panamá', null, null, 'Competencias Varias', '{"mes":"Agosto"}'),
('Copa Jaime Romero', 2026, 'defining', '2026-04-07', '2026-04-12', null, null, 'Guadalajara', 'México', null, null, 'Competencias Varias', '{"mes":"Abril"}'),
('Copa Estrellas Gimnasticas', 2026, 'defining', '2026-06-25', '2026-06-28', null, null, null, 'Costa Rica', null, 'Gimnásticas', 'Competencias Varias', '{"mes":"Junio"}'),
('Santo Domingo Classic', 2026, 'defining', '2026-10-30', '2026-11-01', null, null, 'Santo Domingo', 'República Dominicana', null, null, 'Competencias Varias', '{"mes":"Octubre"}'),
('Palm Springs Gymnastic Cup', null, 'defining', '2026-01-17', '2026-01-17', null, null, 'Palm Springs', 'Estados Unidos', null, 'http://www.gymnasticscup.com/', 'Competencias Varias', '{"mes":"Enero","fecha_original":"17 de enero de 2026"}'),
('Excalibur Cup', null, 'defining', '2026-02-20', '2026-02-20', null, null, 'Virginia Beach', 'Estados Unidos', null, 'http://www.gymnasticscup.com/', 'Competencias Varias', '{"mes":"Febrero","fecha_original":"20 de febrero de 2026"}'),
('Gymnastics training Camps', null, 'defining', '2026-07-15', '2026-07-15', null, null, null, null, null, 'http://www.gymnasticscup.com/', 'Competencias Varias', '{"mes":"Julio","fecha_original":"15 de julio de 2026"}')
on conflict (name, (coalesce(year, 0))) do update set
  status = excluded.status,
  starts_on = excluded.starts_on,
  ends_on = excluded.ends_on,
  registration_deadline_1 = excluded.registration_deadline_1,
  registration_deadline_2 = excluded.registration_deadline_2,
  city = excluded.city,
  country = excluded.country,
  venue = excluded.venue,
  notes = excluded.notes,
  source_name = excluded.source_name,
  source_data = excluded.source_data;
