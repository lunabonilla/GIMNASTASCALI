create table if not exists public.billing_rate_plans (
  id uuid primary key default gen_random_uuid(),
  program text not null,
  days_per_week integer,
  class_duration_minutes integer,
  cycle_weeks integer not null default 4,
  amount_cents bigint not null check (amount_cents > 0),
  effective_year integer not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (program, days_per_week, effective_year)
);

insert into public.billing_rate_plans (
  program, days_per_week, class_duration_minutes, cycle_weeks,
  amount_cents, effective_year
) values
  ('Minis', 1, 60, 4, 17800000, 2026),
  ('Minis', 2, 60, 4, 27500000, 2026),
  ('Regular', 1, 90, 4, 22700000, 2026),
  ('Regular', 2, 90, 4, 37400000, 2026),
  ('Intensivo', null, null, 4, 66000000, 2026)
on conflict (program, days_per_week, effective_year)
do update set
  class_duration_minutes = excluded.class_duration_minutes,
  cycle_weeks = excluded.cycle_weeks,
  amount_cents = excluded.amount_cents,
  active = true;

create table if not exists public.gymnast_billing_profiles (
  gymnast_id uuid primary key references public.gymnasts(id) on delete cascade,
  program text,
  days_per_week integer check (days_per_week is null or days_per_week in (1, 2)),
  updated_at timestamptz not null default now()
);

alter table public.billing_rate_plans enable row level security;
alter table public.gymnast_billing_profiles enable row level security;

create policy "authenticated reads billing rates"
on public.billing_rate_plans for select to authenticated using (true);
create policy "management manages billing rates"
on public.billing_rate_plans for all to authenticated
using (public.is_management()) with check (public.is_management());
create policy "management manages gymnast billing profiles"
on public.gymnast_billing_profiles for all to authenticated
using (public.is_management()) with check (public.is_management());

grant select, insert, update, delete on public.billing_rate_plans to authenticated;
grant select, insert, update, delete on public.gymnast_billing_profiles to authenticated;

create table if not exists public.club_fee_settings (
  fee_key text primary key,
  label text not null,
  amount_cents bigint not null check (amount_cents > 0),
  effective_from date not null,
  notes text,
  updated_at timestamptz not null default now()
);

alter table public.club_fee_settings enable row level security;
create policy "authenticated reads club fee settings"
on public.club_fee_settings for select to authenticated using (true);
create policy "management manages club fee settings"
on public.club_fee_settings for all to authenticated
using (public.is_management()) with check (public.is_management());
grant select, insert, update, delete on public.club_fee_settings to authenticated;

insert into public.club_fee_settings (
  fee_key, label, amount_cents, effective_from, notes
) values
  ('enrollment_2026_current', 'Matrícula 2026 vigente', 14000000, '2026-07-27', 'Valor reducido por avance del año; tarifa inicial: $160.000'),
  ('trial_class_2026', 'Clase de prueba 2026', 6000000, '2026-01-01', 'Tarifa oficial 2026')
on conflict (fee_key) do update set
  label = excluded.label,
  amount_cents = excluded.amount_cents,
  effective_from = excluded.effective_from,
  notes = excluded.notes,
  updated_at = now();

create temporary table official_cycle_stage (
  external_id text primary key,
  gymnast_name text not null,
  program text,
  starts_on date not null,
  ends_on date not null,
  amount_cents bigint not null,
  paid_cents bigint not null,
  concept text not null,
  notes text
) on commit drop;

insert into official_cycle_stage values
(
  'notion-cycle-6f46b0f533c20a1b7f03c3d7', 'Eva Palomino', 'Intensivo',
  '2026-06-25'::date, '2026-07-23'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-25 a 2026-07-23', 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-a5d5948661dfa916016a264b', 'Mariana Zuñiga', 'Intensivo',
  '2026-05-28'::date, '2026-06-25'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-05-28 a 2026-06-25', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-1e705cc506a46a51b6beefb2', 'Gabriela Uribe', 'Intensivo',
  '2026-06-30'::date, '2026-07-28'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-30 a 2026-07-28', 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-67ee21cb96d671bce2d8aa95', 'Carla Sedgemore', 'Intensivo',
  '2026-06-26'::date, '2026-07-24'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-06-26 a 2026-07-24', 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-1cd77f97cbaba805ce0be955', 'Luciana Arenas', 'Intensivo',
  '2026-07-24'::date, '2026-08-21'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-5d16df2c8fbb5fefe1a4f504', 'Gabriela Duque', 'Intensivo',
  '2026-06-26'::date, '2026-07-24'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-06-26 a 2026-07-24', 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-41ba8bce762243f13d36696b', 'Antonia Naranjo', 'Intensivo',
  '2026-07-28'::date, '2026-08-25'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-733243bd210b5212e12ed2a9', 'Antonella Gaez', 'Intensivo',
  '2026-07-24'::date, '2026-08-21'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-0c2f5e79b317d561ca311eeb', 'Emma Galindo', 'Intensivo',
  '2026-07-02'::date, '2026-07-30'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-02 a 2026-07-30', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-b11e9e25a6c3a41f96a56d70', 'Ma Celeste Cruz', 'Intensivo',
  '2026-07-24'::date, '2026-08-21'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-70aaf13a3320799d79ccac71', 'Abigail Giraldo', 'Intensivo',
  '2026-07-28'::date, '2026-08-25'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-ffb1ea08ffbb0685cf40f3c1', 'Salome Escobar', 'Intensivo',
  '2026-08-01'::date, '2026-08-29'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-01 a 2026-08-29', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-3c93a2a41b5a2621ae0f1272', 'Tammy Castellanos', 'Intensivo',
  '2026-07-28'::date, '2026-08-25'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-625bad29319da5528d93e420', 'Ma Mar Betancourth', 'Intensivo',
  '2026-07-28'::date, '2026-08-25'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-2d19925b11673064a66219b9', 'Salome Figueroa', 'Intensivo',
  '2026-07-03'::date, '2026-07-31'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-03 a 2026-07-31', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-877cf053a02e934e8a1c99e6', 'Victoria Estepa', 'Intensivo',
  '2026-07-31'::date, '2026-08-28'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-07-31 a 2026-08-28', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-4f98ad2fcaea3b5768f10282', 'Manuela Arias', 'Intensivo',
  '2026-08-04'::date, '2026-09-01'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-04 a 2026-09-01', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-c641e8b85d652fe4d8ebc333', 'Ariana Paez', 'Intensivo',
  '2026-07-21'::date, '2026-08-18'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-21 a 2026-08-18', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-2942d46905d99a6d91469e1d', 'Giorgia Montaña', 'Intensivo',
  '2026-08-04'::date, '2026-09-01'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-04 a 2026-09-01', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-52ef9902b282a3da4afff974', 'Sofia Montaño', 'Intensivo',
  '2026-07-23'::date, '2026-08-20'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-23 a 2026-08-20', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-ed2f0b72f846521871b0dd29', 'Sophia Londoño', 'Intensivo',
  '2026-07-02'::date, '2026-07-30'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-02 a 2026-07-30', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-768ed6a4f30a109856be7646', 'Paulina Mattey', 'Intensivo',
  '2026-08-19'::date, '2026-09-16'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-19 a 2026-09-16', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-bbfe9e36e8eb8f4e0e215557', 'Gabriela Chaurra', 'Intensivo',
  '2026-01-26'::date, '2026-02-23'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-01-26 a 2026-02-23', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-7a280170b1a592203f366029', 'Martina Rodriguez', 'Intensivo',
  '2026-07-23'::date, '2026-08-20'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-23 a 2026-08-20', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-7a622f236f5209050fbe13d2', 'Ariana Vargas', 'Intensivo',
  '2026-07-28'::date, '2026-08-25'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-e5a76b0d1b412c1ca0a61dc2', 'Mariana Londoño', 'Intensivo',
  '2026-07-10'::date, '2026-08-07'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-10 a 2026-08-07', 'Programa: Intensivo · Nivel: NIVEL 3 · murio tio · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-1af6a42f0f1d32bc28444032', 'Emmanuela Palacios', 'Intensivo',
  '2026-04-30'::date, '2026-05-28'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-04-30 a 2026-05-28', 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-5f04fdb22ac648aacc85d86b', 'Mariana Chaves', 'Intensivo',
  '2026-07-13'::date, '2026-08-10'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-13 a 2026-08-10', 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-8ec86b7ba769f878ef2efc85', 'Ma Jose Valencia', 'Intensivo',
  '2026-08-03'::date, '2026-08-31'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-03 a 2026-08-31', 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-2ad5973f6b8cbf3008bbea35', 'Martina Lopez', 'Intensivo',
  '2026-03-05'::date, '2026-04-02'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-03-05 a 2026-04-02', 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-0da677b947647ebd7a2b02c0', 'Marthina Soto', 'Intensivo',
  '2026-03-05'::date, '2026-04-02'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-03-05 a 2026-04-02', 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-c8da61e8f5fdfaee2b4215b2', 'Hannah Navia', 'Intensivo',
  '2026-08-03'::date, '2026-08-31'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-03 a 2026-08-31', 'Programa: Intensivo · Nivel: NIVEL 5 · pausa ciclo por incapacidad, 3 semanas pendientes de tomar · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-84fb3779422ce2cdeaea90df', 'Ana Emilia Medina', 'Intensivo',
  '2026-07-30'::date, '2026-08-27'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-30 a 2026-08-27', 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-8762a3a3fa32dfe77668d4e9', 'Ma Paula Gomez', 'Intensivo',
  '2026-06-08'::date, '2026-07-06'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-08 a 2026-07-06', 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-398ab73a43cf581f1c0fbcae', 'Valery Cordoba', 'Regular',
  '2026-07-24'::date, '2026-08-21'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Regular · Nivel: NIVEL 4 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-3e721a4eade77b477d454577', 'Mariana Ortiz', 'Minis',
  '2026-05-26'::date, '2026-06-23'::date,
  33300000::bigint, 33300000::bigint,
  'Ciclo 2026-05-26 a 2026-06-23', 'Programa: Minis · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-205e79cc9f149e0f548c219b', 'Paulina Velez', 'Regular',
  '2026-07-29'::date, '2026-08-26'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-07-29 a 2026-08-26', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-c0dff383e4a8e0d9cb6eea76', 'Antonella Endo', 'Intensivo',
  '2026-07-24'::date, '2026-08-21'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-601a67451f16d85e4424436c', 'Rebecca Endo', 'Regular',
  '2026-07-24'::date, '2026-08-21'::date,
  33700000::bigint, 33700000::bigint,
  'Ciclo 2026-07-24 a 2026-08-21', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-5334e90cede66d3b363b5ac0', 'Valentina Rodriguez', 'Regular',
  '2026-07-21'::date, '2026-08-18'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-21 a 2026-08-18', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-4a3202ab8f2fca3f15b4e860', 'Sara Escobar', 'Minis',
  '2026-07-23'::date, '2026-08-20'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-07-23 a 2026-08-20', 'Programa: Minis · Nivel: CIRCUITO · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-ad1de8019b0f55448b12730d', 'Olivia Ceballos', 'Intensivo',
  '2026-07-20'::date, '2026-08-17'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-07-20 a 2026-08-17', 'Programa: Intensivo · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-19ac4aa6f4bdee84833db61b', 'Ma Antonia Arce', 'Regular',
  '2026-06-26'::date, '2026-07-24'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-06-26 a 2026-07-24', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-b3714daeff556b593dca9939', 'Valentina Valencia', 'Regular',
  '2026-07-18'::date, '2026-08-15'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-18 a 2026-08-15', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-d81f34024a11b04825a10d1b', 'Andrea Barreto', 'Regular',
  '2026-08-04'::date, '2026-09-01'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-08-04 a 2026-09-01', 'Programa: Regular · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-c4d02b063078a204899641a6', 'Alanna Segura', 'Regular',
  '2026-07-28'::date, '2026-08-25'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-28 a 2026-08-25', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-8dcf851465b261853ddb5638', 'Ana Sofia Echeverry', 'Regular',
  '2026-07-29'::date, '2026-08-26'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-29 a 2026-08-26', 'Programa: Regular · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-511c573a6697d465bc1d4cf9', 'Emilia Gomez Aristizabal', 'Minis',
  '2026-07-31'::date, '2026-08-28'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-07-31 a 2026-08-28', 'Programa: Minis · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-8e58b9fcac72514718f6203c', 'Juliana Benavides', 'Regular',
  '2026-06-05'::date, '2026-07-03'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-06-05 a 2026-07-03', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-3a2dd55cdcce1298217be467', 'Samara Ochoa', 'Regular',
  '2026-08-01'::date, '2026-08-29'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-08-01 a 2026-08-29', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-aa74922e533f509070e4a43b', 'Valeria Burbano', 'Minis',
  '2026-08-08'::date, '2026-09-05'::date,
  17800000::bigint, 17800000::bigint,
  'Ciclo 2026-08-08 a 2026-09-05', 'Programa: Minis · Nivel: CIRCUITO · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-6dcd23435d664d6f1daf0278', 'Agustina Diaz', 'Regular',
  '2026-06-08'::date, '2026-07-06'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-06-08 a 2026-07-06', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-bb4586b58880d7ab1c8f178a', 'Lucia Valdes', 'Regular',
  '2026-06-10'::date, '2026-07-08'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-06-10 a 2026-07-08', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-bd6b6a36235ef79a1991799b', 'Luciana Vallejo Ossa', 'Regular',
  '2026-08-03'::date, '2026-08-31'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-08-03 a 2026-08-31', 'Programa: Regular · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-2427854ad411b9762c422169', 'Laia Martinez', 'Regular',
  '2026-07-08'::date, '2026-08-05'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-08 a 2026-08-05', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-f8d44e8313bf607c40405eaf', 'Antonella Botero', 'Regular',
  '2026-07-27'::date, '2026-08-24'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-27 a 2026-08-24', 'Programa: Regular · Nivel: PRENIVEL · Mes incapacidad · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-694b135fdce30db307b3fb49', 'Sofia Carmona', 'Regular',
  '2026-08-05'::date, '2026-09-02'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-08-05 a 2026-09-02', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-4f0d12c06ef2d2ea997096cc', 'Miranda Villa', 'Regular',
  '2026-03-18'::date, '2026-04-15'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-03-18 a 2026-04-15', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-d9f68d8692d37d2fffd803ea', 'Ma Clara Quintero', 'Regular',
  '2026-06-16'::date, '2026-07-14'::date,
  40500000::bigint, 40500000::bigint,
  'Ciclo 2026-06-16 a 2026-07-14', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-5f0164e60f1fdaab00afb33b', 'Ana Sofia Gutierrez', 'Regular',
  '2026-07-08'::date, '2026-08-05'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-08 a 2026-08-05', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-06ac92ce4d458f2c0d284d32', 'Mariangel Gomez', 'Intensivo',
  '2026-06-10'::date, '2026-07-08'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-06-10 a 2026-07-08', 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-23b2951418f7ce4d0a45935d', 'Salome Navia', 'Intensivo',
  '2026-06-16'::date, '2026-07-14'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-16 a 2026-07-14', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-156b78cb98e0def8c21a4b80', 'Gabriela Cardona', 'Regular',
  '2026-08-07'::date, '2026-09-04'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-08-07 a 2026-09-04', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-ace0c7d3b9e41aec5051fc4d', 'Ma Alejandra Calle', 'Regular',
  '2026-08-07'::date, '2026-09-04'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-08-07 a 2026-09-04', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-1dcbe96f1f4fd800cdc96444', 'Luciana Hincapie', 'Intensivo',
  '2026-06-03'::date, '2026-07-01'::date,
  66000000::bigint, 66000000::bigint,
  'Ciclo 2026-06-03 a 2026-07-01', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-28014dc1fc42ead16b692369', 'Victoria Ossa', 'Regular',
  '2026-05-18'::date, '2026-06-15'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-05-18 a 2026-06-15', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-138812bc2125fee186a17cb9', 'Anthonella Parra', 'Regular',
  '2026-06-17'::date, '2026-07-15'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-06-17 a 2026-07-15', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-95efec578e4d83ff3fd81773', 'Isabella Valencia', 'Regular',
  '2026-07-22'::date, '2026-08-19'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-22 a 2026-08-19', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-d0ac9eb944bf61d498495e10', 'Danna Farfan', 'Minis',
  '2026-07-16'::date, '2026-08-13'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-07-16 a 2026-08-13', 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-f9885b6393d56f76598b76b4', 'Isabella Nieto', 'Regular',
  '2026-07-23'::date, '2026-08-20'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-23 a 2026-08-20', 'Programa: Regular · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-3b9687b3dd66f346a37f9858', 'Valentina Silva', 'Regular',
  '2026-06-22'::date, '2026-07-20'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-06-22 a 2026-07-20', 'Programa: Regular · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-14da69d0a5d23ea64eb98767', 'Luciana Ortiz', 'Regular',
  '2026-07-20'::date, '2026-08-17'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-07-20 a 2026-08-17', 'Programa: Regular · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-ae18b4f53e1e4d0dfbfe407e', 'Daniela Chacon', 'Regular',
  '2026-04-27'::date, '2026-05-25'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-04-27 a 2026-05-25', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-2ff0ddd0fb128df72645bb6d', 'Violeta Diaz', 'Minis',
  '2026-05-26'::date, '2026-06-23'::date,
  17800000::bigint, 17800000::bigint,
  'Ciclo 2026-05-26 a 2026-06-23', 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-6c5388f4a0dafdbc2048cdb2', 'Martina Garzon', 'Minis',
  '2026-06-23'::date, '2026-07-21'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-06-23 a 2026-07-21', 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-11ce9b23876f3b3fa338f428', 'Sofia Reynoso', 'Regular',
  '2026-06-25'::date, '2026-07-23'::date,
  33800000::bigint, 33800000::bigint,
  'Ciclo 2026-06-25 a 2026-07-23', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-c29b3934f0988d11240e5ea4', 'Fatima Hinestrosa', 'Regular',
  '2026-06-24'::date, '2026-07-22'::date,
  17800000::bigint, 17800000::bigint,
  'Ciclo 2026-06-24 a 2026-07-22', 'Programa: Regular · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-01514db7b8ab2ddc25f57a9d', 'Bella Raigoso', 'Minis',
  '2026-07-22'::date, '2026-08-19'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-07-22 a 2026-08-19', 'Programa: Minis · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-18f848931d401efe50c09bf5', 'Mia Rodriguez', 'Regular',
  '2026-06-29'::date, '2026-07-27'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-06-29 a 2026-07-27', 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-5cece2589c46731dc7d28a90', 'Luciana Contento', 'Regular',
  '2026-07-23'::date, '2026-08-20'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-23 a 2026-08-20', 'Programa: Regular · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-a23ca8f4efa3aa48349df2e0', 'Luciana Campuzano', 'Intensivo',
  '2026-06-23'::date, '2026-07-21'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-23 a 2026-07-21', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-8a37294dc07471e3aa5c9d12', 'Sarah Ospina Velasquez', 'Intensivo',
  '2026-06-24'::date, '2026-07-22'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-24 a 2026-07-22', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-e5d162afcbe039258989f7b6', 'Isabella Ospina Velasquez', 'Intensivo',
  '2026-06-24'::date, '2026-07-22'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-06-24 a 2026-07-22', 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-58114e8245553de3d31a7efe', 'Gabriela Montenegro Borja', 'Regular',
  '2026-07-25'::date, '2026-08-22'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-25 a 2026-08-22', 'Programa: Regular · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
),
(
  'notion-cycle-ff426faa415711b54dcd68da', 'Arianna Trejos', 'Regular',
  '2026-03-25'::date, '2026-04-22'::date,
  37400000::bigint, 37400000::bigint,
  'Ciclo 2026-03-25 a 2026-04-22', 'Programa: Regular · Nivel: NIVEL 4 · cirugia oreja · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-b431c68b70ba491fcaf44efc', 'Antonella Hernandez', 'Regular',
  '2026-07-04'::date, '2026-08-01'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-04 a 2026-08-01', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-de8b8b204fa2f60ce2b7cacf', 'Abigail Perea', 'Minis',
  '2026-06-09'::date, '2026-07-07'::date,
  17800000::bigint, 17800000::bigint,
  'Ciclo 2026-06-09 a 2026-07-07', 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-dd34408df977431e41b54e3d', 'Martina Cortes', 'Regular',
  '2026-07-07'::date, '2026-08-04'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-07-07 a 2026-08-04', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-572c53679183fd01675c7201', 'Victoria Argoty', 'Regular',
  '2026-05-04'::date, '2026-06-01'::date,
  38700000::bigint, 38700000::bigint,
  'Ciclo 2026-05-04 a 2026-06-01', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-f80c2f80611f2803d762a542', 'Montserrat Dranguet', 'Regular',
  '2026-07-02'::date, '2026-07-30'::date,
  27500000::bigint, 27500000::bigint,
  'Ciclo 2026-07-02 a 2026-07-30', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-f4316759747b52862f293e14', 'Luciana Aristizabal', 'Regular',
  '2026-04-02'::date, '2026-04-30'::date,
  22700000::bigint, 22700000::bigint,
  'Ciclo 2026-04-02 a 2026-04-30', 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-c6adc33ab17d13480b4b2583', 'Amy Olano', 'Minis',
  '2026-07-27'::date, '2026-08-24'::date,
  33800000::bigint, 33800000::bigint,
  'Ciclo 2026-07-27 a 2026-08-24', 'Programa: Minis · Nivel: CIRCUITO · Estado original: AL DÍA 🟢'
),
(
  'notion-cycle-3ccfc1966907c2c95f17b4d4', 'Milagros Gil', 'Minis',
  '2026-06-04'::date, '2026-07-02'::date,
  17800000::bigint, 17800000::bigint,
  'Ciclo 2026-06-04 a 2026-07-02', 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
),
(
  'notion-cycle-51d2f3e541834af85536f164', 'Violeta Kiwe', 'Intensivo',
  '2026-08-05'::date, '2026-09-02'::date,
  66000000::bigint, 0::bigint,
  'Ciclo 2026-08-05 a 2026-09-02', 'Programa: Intensivo · Nivel: NIVEL 6 · Estado original: AL DÍA 🟢'
);

insert into public.billing_charges (
  gymnast_id, concept, category, description, issued_on, due_on,
  period_starts_on, period_ends_on, amount_cents, external_source, external_id
)
select
  (array_agg(gymnasts.id))[1],
  stage.concept,
  'monthly_fee',
  stage.notes,
  stage.starts_on,
  stage.ends_on,
  stage.starts_on,
  stage.ends_on,
  stage.amount_cents,
  'notion',
  stage.external_id
from official_cycle_stage stage
join public.gymnasts
  on lower(unaccent(trim(gymnasts.first_name || ' ' || gymnasts.last_name)))
   = lower(unaccent(trim(stage.gymnast_name)))
group by stage.external_id, stage.concept, stage.notes, stage.starts_on,
  stage.ends_on, stage.amount_cents
having count(gymnasts.id) = 1
on conflict (external_source, external_id)
where external_source is not null and external_id is not null
do update set
  amount_cents = excluded.amount_cents,
  description = excluded.description,
  period_starts_on = excluded.period_starts_on,
  period_ends_on = excluded.period_ends_on;

update public.payments payments
set amount_cents = stage.paid_cents
from official_cycle_stage stage
where payments.external_source = 'notion'
  and payments.external_id = stage.external_id
  and stage.paid_cents > 0;

update public.payment_allocations allocations
set amount_cents = stage.paid_cents
from official_cycle_stage stage
join public.payments payments
  on payments.external_source = 'notion'
 and payments.external_id = stage.external_id
join public.billing_charges charges
  on charges.external_source = 'notion'
 and charges.external_id = stage.external_id
where allocations.payment_id = payments.id
  and allocations.charge_id = charges.id
  and stage.paid_cents > 0;

insert into public.payments (
  gymnast_id, paid_on, amount_cents, payment_method, notes,
  external_source, external_id
)
select
  charges.gymnast_id, stage.starts_on, stage.paid_cents, 'other',
  'Pago histórico importado desde Notion', 'notion', stage.external_id
from official_cycle_stage stage
join public.billing_charges charges
  on charges.external_source = 'notion'
 and charges.external_id = stage.external_id
left join public.payments payments
  on payments.external_source = 'notion'
 and payments.external_id = stage.external_id
where stage.paid_cents > 0 and payments.id is null
on conflict (external_source, external_id)
where external_source is not null and external_id is not null
do nothing;

insert into public.payment_allocations (payment_id, charge_id, amount_cents)
select payments.id, charges.id, stage.paid_cents
from official_cycle_stage stage
join public.payments payments
  on payments.external_source = 'notion'
 and payments.external_id = stage.external_id
join public.billing_charges charges
  on charges.external_source = 'notion'
 and charges.external_id = stage.external_id
left join public.payment_allocations allocations
  on allocations.payment_id = payments.id and allocations.charge_id = charges.id
where stage.paid_cents > 0 and allocations.payment_id is null;

insert into public.gymnast_billing_profiles (gymnast_id, program, days_per_week)
select
  (array_agg(gymnasts.id))[1],
  stage.program,
  case
    when stage.program = 'Minis' and stage.amount_cents = 17800000 then 1
    when stage.program = 'Minis' and stage.amount_cents = 27500000 then 2
    when stage.program = 'Regular' and stage.amount_cents = 22700000 then 1
    when stage.program = 'Regular' and stage.amount_cents = 37400000 then 2
    else null
  end
from official_cycle_stage stage
join public.gymnasts
  on lower(unaccent(trim(gymnasts.first_name || ' ' || gymnasts.last_name)))
   = lower(unaccent(trim(stage.gymnast_name)))
where stage.program in ('Minis', 'Regular', 'Intensivo')
group by stage.gymnast_name, stage.program, stage.amount_cents
having count(gymnasts.id) = 1
on conflict (gymnast_id) do update set
  program = excluded.program,
  days_per_week = coalesce(excluded.days_per_week, public.gymnast_billing_profiles.days_per_week),
  updated_at = now();
