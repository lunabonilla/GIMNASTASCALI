create extension if not exists unaccent;

alter table public.billing_charges
  add column if not exists external_source text,
  add column if not exists external_id text;

alter table public.payments
  add column if not exists external_source text,
  add column if not exists external_id text;

create unique index if not exists billing_charges_external_unique
  on public.billing_charges(external_source, external_id)
  where external_source is not null and external_id is not null;

create unique index if not exists payments_external_unique
  on public.payments(external_source, external_id)
  where external_source is not null and external_id is not null;

create table if not exists public.notion_import_exceptions (
  id bigint generated always as identity primary key,
  import_type text not null,
  external_id text not null unique,
  person_name text,
  reason text not null,
  raw_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.notion_import_exceptions enable row level security;
create policy "management reads notion import exceptions"
on public.notion_import_exceptions for select to authenticated
using (public.is_management());

grant select on public.notion_import_exceptions to authenticated;
grant usage, select on sequence public.notion_import_exceptions_id_seq to authenticated;

create table if not exists public.notion_financial_archive (
  id bigint generated always as identity primary key,
  record_type text not null,
  external_id text not null unique,
  person_name text,
  raw_data jsonb not null,
  imported_at timestamptz not null default now()
);

alter table public.notion_financial_archive enable row level security;
create policy "management reads notion financial archive"
on public.notion_financial_archive for select to authenticated
using (public.is_management());

grant select on public.notion_financial_archive to authenticated;
grant usage, select on sequence public.notion_financial_archive_id_seq to authenticated;

insert into public.notion_financial_archive (
  record_type, external_id, person_name, raw_data
) values
(
    'movement', 'notion-movement-archive-9dbfacb98716ad76f48c9063', 'Emmanuela Palacios',
    '{"Movimiento":"personalizado","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5 horas","Valor":"108.000,00 COP","Valor neto":"108000","Abonado a este cargo":"108.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-565525d58d1d3822daebd7a2', 'Emmanuela Palacios',
    '{"Movimiento":"personalizado","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5 horas","Valor":"123.000,00 COP","Valor neto":"123000","Abonado a este cargo":"123.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0ef9997a2ae354788a0cbc29', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a02e401bbfb5f7506aea8c0d', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"31 de marzo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"CHEQUEO","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-427540a568cf5a41dbe52094', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"30 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Kathe","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6873fd6447c9b68a418c4ca8', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"24 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"NO ASISTIO","Valor":"36.000,00 COP","Valor neto":"36000","Abonado a este cargo":"36.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a538948ed247e4019e4b25a7', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6a3a6954ce9d021e96658554', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d61a478ab089d5bde5078661', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"28 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"64.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"18000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-313b409c410c19732e02d3ff', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"82.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e334b2377200835f6a6045b5', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"27 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b49fa6a12d6257cd52cc0c54', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-47b2851fe6bb458505071858', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"14 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"82.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4d6551e757497b5c649d05d7', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"13 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bb6308fad8e57bd07dfe3613', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"7 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"82.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f1fbfdda5c2c8df8c83de095', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"6 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-da4d2bbaca8928b39748839c', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"30 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"82.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-53e73b43d100ea1ae384dc3b', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"3 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"72000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-72a5494b4676cf7cc65eb98c', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"4 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"82000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-17f462522e9c8f72fbecc595', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"10 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"72000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-91e935f13e272eead7a5d49e', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"11 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"82000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c5faa87eba20e02eca033044', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"17 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"72000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b49c7afbc5e7301b7f9b893f', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"no asistio","Valor":"41.000,00 COP","Valor neto":"41000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"41000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d1c14809dc1c8d47f6926f09', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"72000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fa08a9949ed1a8a4d565b168', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"26 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"82.000,00 COP","Valor neto":"82000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"82000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f554c21902773e228cba55d8', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"3 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"2h","Valor":"144.000,00 COP","Valor neto":"144000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"144000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-24d5b0ce37f676b92b25a892', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"8 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"2h","Valor":"144.000,00 COP","Valor neto":"144000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"144000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c4a9bd83a2be0d14c4851751', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"15 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5","Valor":"108.000,00 COP","Valor neto":"108000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"108000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6049eca4ef04cb374687c5e0', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"55000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d208c9bf6537556835294e9f', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"CARTAGENA","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"350000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b1b665badc77bb29614e8685', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"4 clases Emma y Rafa","Valor":"320.000,00 COP","Valor neto":"320000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"320000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8a27adafecf6a0414f766ae0', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"2","Valor":"164.000,00 COP","Valor neto":"164000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"164000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-46af37ee4d5b4412b62e61a5', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"2 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"2","Valor":"164.000,00 COP","Valor neto":"164000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"164000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ec5ab956f2dbbd2b8d79ffa4', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"9 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"123.000,00 COP","Valor neto":"123000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"123000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3d16a4f21b0a1fa938f327b5', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"17 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"123.000,00 COP","Valor neto":"123000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"123000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5589348b0b4f46afde5cdbfb', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"123.000,00 COP","Valor neto":"123000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"123000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-270ab1ce9778fa6cb0062e26', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"30 de abril de 2026 → 28 de mayo de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-77d15b3e89b9af75df2a0c5f', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"28 de mayo de 2026 → 25 de junio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3d518af410fba6286621d4ca', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"25 de junio de 2026 → 23 de julio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d7975c984bdbb14567095559', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"13 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cc41057267f75620002c42ac', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"13 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a3f4561bfa23abad1aff6b3d', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"30 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ec95c6a52a7b8ee6b96b5d6c', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"16 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-00b5e29414685743881532ec', 'Gabriela Uribe',
    '{"Movimiento":"personalizado","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"9 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-980bba7fe8b6e97d2e0467c6', 'Gabriela Uribe',
    '{"Movimiento":"personalizado","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"2 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d3a8e959be1761681c2a7727', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"28 de febrero de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"trusa entreno","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"203.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-293089800f59ca3347c40213', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a5b8f705df99f9173fca9c98', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"Festival","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6aa15c4540ae4d96f1cabd93', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"30 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c1d5a67aa0086ddbcc1b0b66', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"29 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3f1ae5d79de7bccc897cbd2f', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9810cd4f7392845160182d87', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"15 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f0084f222b1ef7f8994022d8', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"8 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-371f94fbb1d8ffb340854978', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f86c626100928efc3409561a', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"5 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-36687e27443289b52ad27506', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"19 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4349ceca52dd1c4b4fef5f62', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"19 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-20e94bbb01da03722d2bf421', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"4 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7c579da466f2caaa272f58b9', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"10 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6f03b52be826e9f68c44389f', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"10 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c7427858c30803df316847f4', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"4 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b21725b06db782e792a88d27', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"17 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4b27b6054bd868084c8294e1', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"17 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f27fa56a3a47989d8671c875', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"12 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9c28a566ff0ecc78486a379e', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"12 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-42fc5d18d38207cf8f2a6be7', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"30 de junio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"574.000,00 COP","Valor neto":"574000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"574000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-65129c61dba77faea0321fd5', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"4 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f3601b460243f1a9b1590014', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8ae1a904847e55437b928bee', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"6 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Kt","Observaciones":"2h","Valor":"154.000,00 COP","Valor neto":"154000","Abonado a este cargo":"154.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8603ad1d5fc3fa2e5a8157fa', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"27 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-25db099f22456626d02c2043', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"26 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7c35504bd8e82b907a82f9a5', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"20 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e09a01381b8f985303dd44ee', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"19 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9183eddc24933a17e8d6a3c8', 'Mariana Zuñiga',
    '{"Movimiento":"personalizado","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"12 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-dc87c569b00d398395b4531a', 'Mariana Zuñiga',
    '{"Movimiento":"personalizado","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"6 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c4f03e11a348541d9cc3e81f', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Armenia","Valor":"395.000,00 COP","Valor neto":"395000","Abonado a este cargo":"395.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ef381a156fe3c5e1e857d19e', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0e02aee1517eff7b884307a2', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-aa0fa9c1c941f82a90fbaa07', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-681613ff74b0831f6f3cc68c', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"5 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2522dbc06b7ada3bff530f1c', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"4 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ccee06202df11780b25125e2', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4615586b869ac1598b68b6f0', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"28 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-38c8cabee7af2198b278967b', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0aa521d6926cf300be60856e', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"2 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-53e3f305b65e5c80841ee4e8', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"8 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ae9a066c3293e614530c8fec', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a0b908d70f5765385a286ed4', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Diana","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fc29f430f900a78c8f768f54', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d56718e20a481e00d319be62', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"30 de abril de 2026 → 28 de mayo de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"660.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4a9aa4ee43a42fa910edc4c1', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"28 de mayo de 2026 → 25 de junio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2dc476784301da5f3e50dd5e', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"25 de junio de 2026 → 23 de julio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4c0f2179695d6e732218511e', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Cartagena","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"350.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9f4479a60ac013687cbe1a3a', 'Mariana Zuñiga',
    '{"Movimiento":"","Deportista":"Mariana Zuñiga (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Zu%C3%B1iga%202efe9302b4118009ac7eeafc2fd37940.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"VERANO","Valor":"581.000,00 COP","Valor neto":"581000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"581000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d3bc71a1bd611c6de11a6c6e', 'Antonia Garzon',
    '{"Movimiento":"","Deportista":"Antonia Garzon  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Garzon%202fbe9302b4118055b5ecf269204b2dd7.csv)","Fecha":"26 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e24c7e69ab0860015d505139', 'Antonia Garzon',
    '{"Movimiento":"","Deportista":"Antonia Garzon  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Garzon%202fbe9302b4118055b5ecf269204b2dd7.csv)","Fecha":"25 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-53327be9484f0b2706004505', 'Antonia Garzon',
    '{"Movimiento":"","Deportista":"Antonia Garzon  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Garzon%202fbe9302b4118055b5ecf269204b2dd7.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"55.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8971bfdb71aa29768bc0fd9a', 'Antonia Garzon',
    '{"Movimiento":"","Deportista":"Antonia Garzon  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Garzon%202fbe9302b4118055b5ecf269204b2dd7.csv)","Fecha":"13 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cadb6fd619f201830539cea4', 'Antonia Naranjo',
    '{"Movimiento":"","Deportista":"Antonia Naranjo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Naranjo%202efe9302b41180078134ef6ab4c3e5a6.csv)","Fecha":"25 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2b8ee9bac7cf240775c82df1', 'Antonia Naranjo',
    '{"Movimiento":"","Deportista":"Antonia Naranjo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Naranjo%202efe9302b41180078134ef6ab4c3e5a6.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-64132f9bd1ba6c6ecbaa4aa9', 'Antonia Naranjo',
    '{"Movimiento":"","Deportista":"Antonia Naranjo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonia%20Naranjo%202efe9302b41180078134ef6ab4c3e5a6.csv)","Fecha":"31 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"CURSO VERANO","Valor":"182.000,00 COP","Valor neto":"182000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"182000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6bcb28a11eadb98ce92755a6', 'Salome Escobar',
    '{"Movimiento":"","Deportista":"Salome Escobar (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Escobar%202efe9302b4118065972efecf1701d5a5.csv)","Fecha":"1 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-efbf7066be61a855a926eb5d', 'Salome Escobar',
    '{"Movimiento":"","Deportista":"Salome Escobar (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Escobar%202efe9302b4118065972efecf1701d5a5.csv)","Fecha":"25 de marzo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-74aa1ac953ce9f63e96c66ca', 'Salome Escobar',
    '{"Movimiento":"","Deportista":"Salome Escobar (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Escobar%202efe9302b4118065972efecf1701d5a5.csv)","Fecha":"8 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7223661b7493c9353a860b12', 'Salome Escobar',
    '{"Movimiento":"","Deportista":"Salome Escobar (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Escobar%202efe9302b4118065972efecf1701d5a5.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"IBAGUE INSCRIPCION","Valor":"534.000,00 COP","Valor neto":"534000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"534000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b743900d4fcb4f496a2adab7', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"15 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f92f1ca6d21c64d72cdd0957', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0689754f56135044a7a817a0', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"6 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d5f5a33f1a13320aa98ca7eb', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"1 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-84c9aa30ade1317fba78ea4a', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"26 de febrero de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"103.000,00 COP","Valor neto":"103000","Abonado a este cargo":"103.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c9aa01ed1d6f702902e446b0', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3e36469661f8417b7020842d', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ceb7badafb24e3953f260597', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7bfe5d2c504f924c5c11bd42', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-903e49b60096ff0e3c6a71f0', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5beccd54b121e12fe8dd81a7', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"295000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-545deb76007c237e3465cebf', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"17 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b0dd2d512cc1aa3f3d52efcc', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bbbee1fa641f9ef8f624904f', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1e2549be36323b813ac27c45', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3131c7d5d94125fca28f0d71', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-22164978895a65aae6d5d04a', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-72b4919b8d7327c96ba3359d', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"25 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e085cd95c8d54675b17d9e03', 'Emma Vega',
    '{"Movimiento":"","Deportista":"Emma Vega (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vega%202f1e9302b411806ea7ade4ed1abcdc7c.csv)","Fecha":"2 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e70d575dd75b337b1817927c', 'Celeste Giraldo',
    '{"Movimiento":"","Deportista":"Celeste Giraldo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Giraldo%202f1e9302b41180628160e282a89f556a.csv)","Fecha":"8 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-97e7bedd8a79d613e70f0be7', 'Celeste Giraldo',
    '{"Movimiento":"","Deportista":"Celeste Giraldo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Giraldo%202f1e9302b41180628160e282a89f556a.csv)","Fecha":"6 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Kt","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-faffb9377e92c7c9dbe2d329', 'Celeste Giraldo',
    '{"Movimiento":"","Deportista":"Celeste Giraldo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Giraldo%202f1e9302b41180628160e282a89f556a.csv)","Fecha":"2 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8f73e21ce3b0da7f4f4c258a', 'Celeste Giraldo',
    '{"Movimiento":"","Deportista":"Celeste Giraldo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Giraldo%202f1e9302b41180628160e282a89f556a.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-40fddc646d124d245e1f4822', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5dec1ee45970d5abde284a46', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f51da7d7c174a497755db56e', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"4 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"32.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"56000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0f7fbfa6c40378e9088bd884', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"excedente Armenia","Valor":"68.000,00 COP","Valor neto":"68000","Abonado a este cargo":"68.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d8d83f6e9d7e7a6c150db87e', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"144.000,00 COP","Valor neto":"144000","Abonado a este cargo":"144.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1136f4a243bd424305ca03a3', 'Hannah Navia',
    '{"Movimiento":"","Deportista":"Hannah Navia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Hannah%20Navia%202efe9302b4118024a742c92b11419037.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cb43026c65a3ae6d025fecbc', 'Hannah Navia',
    '{"Movimiento":"","Deportista":"Hannah Navia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Hannah%20Navia%202efe9302b4118024a742c92b11419037.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ffd329d96d01c0c3a8aa501a', 'Mariana Chaves',
    '{"Movimiento":"","Deportista":"Mariana Chaves (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Chaves%202efe9302b411806296d1c8722174e059.csv)","Fecha":"9 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-da4d0104a21287585bc77eb4', 'Mariana Chaves',
    '{"Movimiento":"","Deportista":"Mariana Chaves (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Chaves%202efe9302b411806296d1c8722174e059.csv)","Fecha":"8 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ce064f67c41271ceeacc9fbb', 'Mariana Chaves',
    '{"Movimiento":"","Deportista":"Mariana Chaves (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Chaves%202efe9302b411806296d1c8722174e059.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"2h","Valor":"154.000,00 COP","Valor neto":"154000","Abonado a este cargo":"154.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b7ff5e4fef9cf2014c918e88', 'Mariana Chaves',
    '{"Movimiento":"","Deportista":"Mariana Chaves (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Chaves%202efe9302b411806296d1c8722174e059.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"180.000,00 COP","Valor neto":"180000","Abonado a este cargo":"180.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-07d212b58495d0dfff88c859', 'Mariana Chaves',
    '{"Movimiento":"","Deportista":"Mariana Chaves (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Chaves%202efe9302b411806296d1c8722174e059.csv)","Fecha":"6 de junio de 2026 → 19 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"CARTAGENA","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"350000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d5d08074d1b0fe03b273218f', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"14 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4171451f46d8ccbcfdd103f2', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-87e1d9158f9ef189387af1e6', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8000a24f9532e429e506a32c', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c64f4a3291cd041483723260', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-639b62a1983d0a1cc50608fc', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8a4610a4a4df26074174e106', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2fe0371b65ad15b9ce994e8f', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"5 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-62659f9dbd1a1c1085c4e311', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"28 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5badf19e05487fd17880e684', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1b34cea66b51e69eb224326e', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"21 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1b111da4c3d6c50463171dc7', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"45.000,00 COP","Valor neto":"45000","Abonado a este cargo":"45.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b15072006d0ae2800d527d4c', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"203.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-25935cecc0864637cc8cfb92', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Cartagena","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"350.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0c9457a0df0cec6614fbcfec', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4192d5c17cef6bbb4113cc1f', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"2 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2f0094e083878e58d3fba1f9', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"9 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bf98f119100bc7120eeb0944', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bfebaa474b04724c0c7443dd', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6b049d561dee87c72b75239e', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b2e36af17df846cbf52dca10', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"30 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"132000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1c0162a31864421cdde02acf', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"6 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7ac1bf9149cc8784321a1861', 'Sofia Montaño',
    '{"Movimiento":"","Deportista":"Sofia Montaño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Monta%C3%B1o%202efe9302b411808c8ceff3331dbce49e.csv)","Fecha":"","Tipo":"","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3184230aefadcb7322597b06', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5cc4c86b16abd45f01c5cffd', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"8 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7ed82236888a5cb89c43d13f', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9317d4a9d429d6929c981402', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-730c66b04c49dab1971540e9', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4ff70a0f62914d27b929f80c', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c84c62f8c9a688e41b04bfa3', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2d2bf741ebde8fd9abedf729', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-35c214120e4e9114c0fab342', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"excedente inscripción ctg","Valor":"105.000,00 COP","Valor neto":"105000","Abonado a este cargo":"105.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-84e78bb6096df7f2f0ffa005', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"19 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"80.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"8000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-436d7db843b68b842677f34a', 'Ma Celeste Cruz',
    '{"Movimiento":"","Deportista":"Ma Celeste Cruz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Celeste%20Cruz%202efe9302b41180c79691ff0c53e5f6ab.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fa5dbbf7e66d7370c681d941', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"8 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5ab92c76391a909a573d8786', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"9 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3e87fa900294d567313cc9f0', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-94498edf6dac8df9d7531d6e', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-12f5d4aea4660d4bbd7d001d', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2c8f2885cdc5616e31db572f', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8f18dd96ecc1d585ad41e77d', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"2 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cecb7e5cd7c9b46de270a857', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"9 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4e200b243423e3016211895d', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-470222be3ec3ce4dfbe1653a', 'Ma Paula Coral',
    '{"Movimiento":"","Deportista":"Ma Paula Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Coral%202fee9302b4118012b221d193d35c6ad0.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cc23089627d1698876f55d04', 'Agustina Diaz',
    '{"Movimiento":"","Deportista":"Agustina Diaz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Agustina%20Diaz%202efe9302b4118006a962fc10d4e5af43.csv)","Fecha":"9 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5c7cc74a5ac2de1c50d2b94e', 'Agustina Diaz',
    '{"Movimiento":"","Deportista":"Agustina Diaz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Agustina%20Diaz%202efe9302b4118006a962fc10d4e5af43.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"216.000,00 COP","Valor neto":"216000","Abonado a este cargo":"216.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9a7a2718e6c8602aa313ac42', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"14 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8e21cad04ac1b5b3ca5e51cc', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"2h","Valor":"154.000,00 COP","Valor neto":"154000","Abonado a este cargo":"154.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-063bafc369e4fbb51e78d6c5', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-685e78e8f137a4ba3b06cd95', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"9 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6de69e3fcc7c339cab19d01d', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"9 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-63a3b55043d7b804fe59f45a', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0dda2f55d8b6b5abae319600', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-700d5dd750f690cc1a8fe939', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"603.500,00 COP","Valor neto":"603500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"603500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-743800f39ce62a9bf3721cdc', 'Luciana Toro',
    '{"Movimiento":"","Deportista":"Luciana Toro (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Toro%202efe9302b411804f99a7c2d2ee3cc374.csv)","Fecha":"14 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fb0e8b7214900fb73d55369e', 'Luciana Toro',
    '{"Movimiento":"","Deportista":"Luciana Toro (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Toro%202efe9302b411804f99a7c2d2ee3cc374.csv)","Fecha":"21 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-88554551c00094c171366943', 'Ana Sofia Gutierrez',
    '{"Movimiento":"","Deportista":"Ana Sofia Gutierrez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Gutierrez%202f1e9302b411806eb030f8ccccbf07af.csv)","Fecha":"14 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4230debbe831602708a8d246', 'Ana Sofia Gutierrez',
    '{"Movimiento":"","Deportista":"Ana Sofia Gutierrez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Gutierrez%202f1e9302b411806eb030f8ccccbf07af.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5aed1572e69a2fa35860ccf7', 'Ana Sofia Gutierrez',
    '{"Movimiento":"","Deportista":"Ana Sofia Gutierrez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Gutierrez%202f1e9302b411806eb030f8ccccbf07af.csv)","Fecha":"15 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-af002d65e5b7698eba649d84', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"15 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-32c2739dedfbb10199db3e17', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"SELECTIVO","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d5b4da151650a162f6ca17fc', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-51f5a951063afe1dc5777711', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9c8b006af53d4f1b352b0b37', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-dc8a72c561cf0744da4dfce6', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cc68497b1afbed2baac51714', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3563c2e4833f419ac6eecff4', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-eb41b5e995f21dcbcba21751', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"1,5h","Valor":"165.000,00 COP","Valor neto":"165000","Abonado a este cargo":"165.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-30cd50cad23bf0ac59d9bd3a', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8fac82d24515fdb918015e1c', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-52984a7195f5a6e2a5994510', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"1 de marzo de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"165.000,00 COP","Valor neto":"165000","Abonado a este cargo":"165.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8328977b1cea61c2bf9bcd66', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"1 de abril de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"325.000,00 COP","Valor neto":"325000","Abonado a este cargo":"325.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fd4eb0f7ef719012fcc7cd28', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"390.000,00 COP","Valor neto":"390000","Abonado a este cargo":"390.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e30e2609536900a44e888ed0', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5480c66d25845dc6bea7d88d', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"13 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ce7d46134d6d60e11ce4025c', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"13 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5df7095102790cb2c2193404', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8d9a79e77d744bcd2ca5f627', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6585087ee38d48c8bd9e8fdd', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b1f3de1888605e5998d42eac', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"30 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-502f4c3ad2de3a696ea63753', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"13 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-98125b0cb31c412f4cd0873c', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"15 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bb964c7813c6f4b270b80c6a', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"19 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e104bb05c413e467cce50887', 'Luciana Campuzano',
    '{"Movimiento":"","Deportista":"Luciana Campuzano (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Campuzano%20302e9302b411802ebe78f36e2d145007.csv)","Fecha":"20 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-835f052d8825922f061da9f4', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"45.000,00 COP","Valor neto":"45000","Abonado a este cargo":"45.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-683aea7a939a459b1b31e74b', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"15 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-debbbfad3c3f44a36c220b79', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"55.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-351e3f3bdc7d5ee5eae286e8', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"27 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d42fcd8c7ba75d0b42bafe4a', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8ffbc6f28e53c13d13147c72', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"13 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c0b785d311d52aa062d73c06', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"6 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-da2dd2951c841527721fd2f6', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"29 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-84f130d1f581adcc32f06f83', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5e6ca7b8391e13137e716e3d', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"22 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d9339919bc59f4fac41ee42b', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f0b8d9a668a7e2f867ef0362', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"3 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-80a5b2b5ea4e7616da995752', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"17 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0c4613b08c86992e29becf98', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-18112340852dcaa4eb288fbb', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"15 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e9e2baf7e4d98cda34605084', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"30 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"CARTAGENA","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"350000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-498eca8b04e545df3dbbb35d', 'Luciana Arenas',
    '{"Movimiento":"","Deportista":"Luciana Arenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Arenas%202efe9302b411802a8aaadf8311a8bf43.csv)","Fecha":"6 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6de4032f44b542bfe396c0fc', 'Andrea Barreto',
    '{"Movimiento":"","Deportista":"Andrea Barreto (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Andrea%20Barreto%202efe9302b4118085bfe6f36558c08fa6.csv)","Fecha":"15 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-416e8b7962848e5a73f66fd9', 'Andrea Barreto',
    '{"Movimiento":"","Deportista":"Andrea Barreto (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Andrea%20Barreto%202efe9302b4118085bfe6f36558c08fa6.csv)","Fecha":"5 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3b16a4afb67fd16e6097640e', 'Gabriela Duque',
    '{"Movimiento":"","Deportista":"Gabriela Duque (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Duque%202efe9302b41180589866cb485f481e89.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-16b0cdd70e268bf05ae7c364', 'Gabriela Duque',
    '{"Movimiento":"","Deportista":"Gabriela Duque (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Duque%202efe9302b41180589866cb485f481e89.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"329.000,00 COP","Valor neto":"329000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"329000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-00536952fa71c5347c9074b2', 'Isabella Nieto',
    '{"Movimiento":"","Deportista":"Isabella Nieto (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Nieto%202fbe9302b41180a6b2b7c1252ff7f88b.csv)","Fecha":"18 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Majo","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1a5372bda997bd06196b3a85', 'Isabella Nieto',
    '{"Movimiento":"","Deportista":"Isabella Nieto (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Nieto%202fbe9302b41180a6b2b7c1252ff7f88b.csv)","Fecha":"21 de febrero de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"103.000,00 COP","Valor neto":"103000","Abonado a este cargo":"103.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-785640fd54b043b4aaf7e17b', 'Mariangel Gomez',
    '{"Movimiento":"","Deportista":"Mariangel Gomez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariangel%20Gomez%202f1e9302b4118097ad05c594a33b7c87.csv)","Fecha":"20 de marzo de 2026","Tipo":"Cargo","Concepto":"Accesorios","Profesor":"","Observaciones":"guantes","Valor":"130.000,00 COP","Valor neto":"130000","Abonado a este cargo":"130.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3f70d94559e198c935dc81ca', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"26 de febrero de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"203.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-18307ffcf6c0f4e5ce3344d7', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"chequeo","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0d95e49ce09b34b5948c6f12', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c0c924f86a6716f1bb203e00', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0fb2a731a005b5b181839cdd', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"Festival","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a44bad888f3fed22d1b1f7c1', 'Mariana Londoño',
    '{"Movimiento":"","Deportista":"Mariana Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Londo%C3%B1o%202efe9302b4118059bc39d2397378c648.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"IBAGUE INSCRIPCION","Valor":"534.000,00 COP","Valor neto":"534000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"534000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2f34d58a2b96266ff66491c7', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"20 de diciembre de 2025","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"185.000,00 COP","Valor neto":"185000","Abonado a este cargo":"185.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-196eb48370b266f72baf1e2b', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"Selectivo","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0b66777c08afe0a4360e8804', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2b1ab401889dfb6306227cf9', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2dae43af7502f303a596efbe', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-271c276cab24e1cd83203334', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-22c038197e97b45d7fd7e1e6', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8e4375c72ee7aa9644548877', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"15 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6801ad6b52ca1f262eed6f46', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"29 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-39cf1da950cf58306468ef1a', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"25 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5 (revisar)","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-17fb0b597a99bcae8f6c7f3a', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"23 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h 24 ABRIL","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-006352abe530916334633c62', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"18 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-02c87a2670e7f13027e0058d', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-752b91df16dae62543e9a8a3', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5a09962bd4c011f6d9d4435a', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"2 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-19fd28c2de38b156158612cb', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"9 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-47c7d1d941aefd161cde60c0', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9ecd0ce3dbf6653fc648b4d6', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"17 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fe05b671c1601a6be5c4d555', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3d5f4f7da4ca5ecd4a5fd1b5', 'Eva Palomino',
    '{"Movimiento":"","Deportista":"Eva Palomino (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Eva%20Palomino%202eee9302b41180668b72de4b7404270c.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e8afd795a5e10eaf86184133', 'Martina Lopez',
    '{"Movimiento":"","Deportista":"Martina Lopez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Lopez%202efe9302b41180b68aa4e5b23af57cf8.csv)","Fecha":"22 de enero de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"203000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9231902f016a607f9689ce6c', 'Martina Lopez',
    '{"Movimiento":"","Deportista":"Martina Lopez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Lopez%202efe9302b41180b68aa4e5b23af57cf8.csv)","Fecha":"5 de noviembre de 2025","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"40.000,00 COP","Valor neto":"40000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"40000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-03ee30e8071b39ddf9ae282b', 'Luciana Contento',
    '{"Movimiento":"","Deportista":"Luciana Contento (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Contento%202ffe9302b411805fb572fa7af702e4b4.csv)","Fecha":"5 de febrero de 2026","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"45.000,00 COP","Valor neto":"45000","Abonado a este cargo":"45.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b882605fdd93dc629f75e34b', 'Valentina Valencia',
    '{"Movimiento":"","Deportista":"Valentina Valencia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Valentina%20Valencia%202efe9302b411801b8c1be82ed293fbbe.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0f4d9024613b65f8eee617b5', 'Valentina Valencia',
    '{"Movimiento":"","Deportista":"Valentina Valencia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Valentina%20Valencia%202efe9302b411801b8c1be82ed293fbbe.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"110.000,00 COP","Valor neto":"110000","Abonado a este cargo":"110.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f221c306debaa59f093dfa53', 'Valentina Valencia',
    '{"Movimiento":"","Deportista":"Valentina Valencia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Valentina%20Valencia%202efe9302b411801b8c1be82ed293fbbe.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"45.000,00 COP","Valor neto":"45000","Abonado a este cargo":"45.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1dff9e1bcff5cdd684634452', 'Itala Ma Orozco',
    '{"Movimiento":"","Deportista":"Itala Ma Orozco (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Itala%20Ma%20Orozco%202efe9302b4118052843ee8fa22080606.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5cd2558ec86b860b40116497', 'Sophia Londoño',
    '{"Movimiento":"","Deportista":"Sophia Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Londo%C3%B1o%202efe9302b411805da524c09a2b24b5dd.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2d7f3a0435a5d2adafa62d3f', 'Sophia Londoño',
    '{"Movimiento":"","Deportista":"Sophia Londoño (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Londo%C3%B1o%202efe9302b411805da524c09a2b24b5dd.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-068d90b54dd15264c8de892c', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-772435d7a2b9b60dbdc9d24f', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"55.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5da4bd4901c5a64e74eeabd6', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7660cd30e3fce0dcc1b01096', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-55eca0077b25203df4f60c7e', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f663a1a7de2a81dc4571395e', 'Martina Rodriguez',
    '{"Movimiento":"","Deportista":"Martina Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Martina%20Rodriguez%202efe9302b4118090af87f75c34cceae4.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"Festival","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6c12176d7c23adfc71b0b1db', 'Ana Sofia Echeverry',
    '{"Movimiento":"","Deportista":"Ana Sofia Echeverry (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Echeverry%202efe9302b411805db0c9d310a25fa8c8.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-472855a2c0c40f044511db3c', 'Ana Sofia Echeverry',
    '{"Movimiento":"","Deportista":"Ana Sofia Echeverry (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Echeverry%202efe9302b411805db0c9d310a25fa8c8.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7f63295a2d14d49083c26fb2', 'Ana Sofia Echeverry',
    '{"Movimiento":"","Deportista":"Ana Sofia Echeverry (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Sofia%20Echeverry%202efe9302b411805db0c9d310a25fa8c8.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"55.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6c1cc256501c12a78b8a6161', 'Violeta Diaz',
    '{"Movimiento":"","Deportista":"Violeta Diaz  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Violeta%20Diaz%202fce9302b41180c29e6cf8ae1e880ae2.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ed8ddce7b0536bae9428a940', 'Emiliana Silva',
    '{"Movimiento":"","Deportista":"Emiliana Silva (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emiliana%20Silva%202efe9302b41180e48e76ce8105897bba.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"197.500,00 COP","Valor neto":"197500","Abonado a este cargo":"197.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7d8f3a9981f1fba2a6cb6786', 'Emiliana Silva',
    '{"Movimiento":"","Deportista":"Emiliana Silva (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emiliana%20Silva%202efe9302b41180e48e76ce8105897bba.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ffa4b16cde7ee201e73ee15c', 'Emiliana Silva',
    '{"Movimiento":"","Deportista":"Emiliana Silva (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emiliana%20Silva%202efe9302b41180e48e76ce8105897bba.csv)","Fecha":"23 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Diana","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bbc40a408f5419eff477c871', 'Emiliana Silva',
    '{"Movimiento":"","Deportista":"Emiliana Silva (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emiliana%20Silva%202efe9302b41180e48e76ce8105897bba.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-26567388e1cd892f5d87feac', 'Luciana Cardenas',
    '{"Movimiento":"","Deportista":"Luciana Cardenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Cardenas%202efe9302b4118011b1ecc71ebc28f625.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"195.000,00 COP","Valor neto":"195000","Abonado a este cargo":"195.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-53ace083d9a1e01ced3b536b', 'Luciana Cardenas',
    '{"Movimiento":"","Deportista":"Luciana Cardenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Cardenas%202efe9302b4118011b1ecc71ebc28f625.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-be548dec30aef35d036fd3f8', 'Luciana Cardenas',
    '{"Movimiento":"","Deportista":"Luciana Cardenas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Cardenas%202efe9302b4118011b1ecc71ebc28f625.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-702acc9d1916383c636e434a', 'Emma Vega',
    '{"Movimiento":"","Deportista":"Emma Vega (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vega%202f1e9302b411806ea7ade4ed1abcdc7c.csv)","Fecha":"21 de marzo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"72.000,00 COP","Valor neto":"72000","Abonado a este cargo":"72.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-039e017e6c722667e191bd1e', 'Ma Antonia Arce',
    '{"Movimiento":"","Deportista":"Ma Antonia Arce (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Antonia%20Arce%202efe9302b41180389a55f96cc000afe4.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"288.000,00 COP","Valor neto":"288000","Abonado a este cargo":"288.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-121a4e7629573545472b2743', 'Ma Jose Valencia',
    '{"Movimiento":"","Deportista":"Ma Jose Valencia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Jose%20Valencia%202efe9302b41180228b2bcb1959118bc6.csv)","Fecha":"20 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"<luna","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-00f795f545c38fc1e081bc46', 'Dulce Ma Aristizabal',
    '{"Movimiento":"","Deportista":"Dulce Ma Aristizabal (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Dulce%20Ma%20Aristizabal%202efe9302b4118010aa90fc962434c9d5.csv)","Fecha":"7 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"","Observaciones":"1/2 hora","Valor":"44.000,00 COP","Valor neto":"44000","Abonado a este cargo":"44.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-36185d959ea677d30f0ad9c1', 'Dulce Ma Aristizabal',
    '{"Movimiento":"","Deportista":"Dulce Ma Aristizabal (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Dulce%20Ma%20Aristizabal%202efe9302b4118010aa90fc962434c9d5.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a7b9a26476c284bb3360f467', 'Dulce Ma Aristizabal',
    '{"Movimiento":"","Deportista":"Dulce Ma Aristizabal (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Dulce%20Ma%20Aristizabal%202efe9302b4118010aa90fc962434c9d5.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4a88ff6bd1480ca5fad692b8', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"28 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0eeb008c4f1572a5be437751', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"23 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-049bec898683f66215cff571', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-25a023d8996b5c3a91be47c2', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-064aa39bedd1779974731330', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"14 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2d16201c367c505a825ef8ee', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"30 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ce3de38cb5ee4901cc29a428', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"23 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-68953ee7cc1f7a514fcd0fb8', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"203.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-85f1ac3243030b2ec220734c', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"4 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-21afbb155e3efbf3b1fb338f', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"11 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-77e9a5bf98a0f1dd805d04f7', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-874fb4eb82ac7a5e3d6aa3c7', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"132000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-381194daf8b867929e34b0f1', 'Emma Vargas',
    '{"Movimiento":"","Deportista":"Emma Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Vargas%202fbe9302b4118006a2d8d975b5f97087.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"IBAGUE INSCRIPCION","Valor":"534.000,00 COP","Valor neto":"534000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"534000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1badaf2bda8edf2aada3fd4b', null,
    '{"Movimiento":"","Deportista":"","Fecha":"","Tipo":"","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-974684d74f002ee4e2aea6fc', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"chequeo selectivo","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a7e913a9c97e8e6f6db23ba8', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3f12278fd80ef19956f9d9c7', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"15 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-105889c309a72590381a56ef', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"8 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8c5b332c8ff720c21d979ee4', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-01271f8cdd7347e56c12d3ea', 'Salome Navia',
    '{"Movimiento":"","Deportista":"Salome Navia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Navia%202f1e9302b411801bbf75d8a85880f6e1.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-158c819e9f764c9363207451', 'Salome Navia',
    '{"Movimiento":"","Deportista":"Salome Navia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Navia%202f1e9302b411801bbf75d8a85880f6e1.csv)","Fecha":"24 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4c4f9efac8006b9dbf3d20c1', 'Salome Navia',
    '{"Movimiento":"","Deportista":"Salome Navia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Navia%202f1e9302b411801bbf75d8a85880f6e1.csv)","Fecha":"1 de julio de 2026","Tipo":"","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"365.500,00 COP","Valor neto":"365500","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9999e83b5a822a1cfef089d0', 'Amanda Ramirez',
    '{"Movimiento":"","Deportista":"Amanda Ramirez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Amanda%20Ramirez%202efe9302b4118004b6ddd0191e5e2a22.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"40.000,00 COP","Valor neto":"40000","Abonado a este cargo":"40.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5ecf88012f03ce9bb5b73fb1', 'Ana Emilia Medina',
    '{"Movimiento":"","Deportista":"Ana Emilia Medina (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Emilia%20Medina%202efe9302b411806abefefd0976f3cfeb.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0ac893dcd580c6b432c29e7b', 'Ana Emilia Medina',
    '{"Movimiento":"","Deportista":"Ana Emilia Medina (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ana%20Emilia%20Medina%202efe9302b411806abefefd0976f3cfeb.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-951148896fe2084be2e33306', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"9 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"3 clases (9, 16, 17)","Valor":"210.000,00 COP","Valor neto":"210000","Abonado a este cargo":"210.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ad82d21fda2172ffec0e6556', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ed3502bff285f98a66310f66', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ab8ffe2e902f0d17c4d34760', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"30 de abril de 2026","Tipo":"Cargo","Concepto":"Guantes","Profesor":"","Observaciones":"","Valor":"130.000,00 COP","Valor neto":"130000","Abonado a este cargo":"130.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3e6a37870827dd174f08b969', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6c1ee9eb4f61c19d058047c1', 'Antonella Endo',
    '{"Movimiento":"","Deportista":"Antonella Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Endo%202efe9302b4118076b6c3eef34fa24cc9.csv)","Fecha":"15 de junio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"PUNTA CANA","Valor":"20,00 COP","Valor neto":"20","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"20"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c8f4fa4f466e65921854a861', 'Rebecca Endo',
    '{"Movimiento":"","Deportista":"Rebecca Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Rebecca%20Endo%202efe9302b41180b497c6ebfa1c5c7f82.csv)","Fecha":"9 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"3 clases (9, 16, 17)","Valor":"210.000,00 COP","Valor neto":"210000","Abonado a este cargo":"210.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-65e30f61f2807c1516a52148', 'Rebecca Endo',
    '{"Movimiento":"","Deportista":"Rebecca Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Rebecca%20Endo%202efe9302b41180b497c6ebfa1c5c7f82.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"Festival","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-045cbb894168468b0a0fe38f', 'Rebecca Endo',
    '{"Movimiento":"","Deportista":"Rebecca Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Rebecca%20Endo%202efe9302b41180b497c6ebfa1c5c7f82.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8e7000fda6cd680c33972d7c', 'Rebecca Endo',
    '{"Movimiento":"","Deportista":"Rebecca Endo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Rebecca%20Endo%202efe9302b41180b497c6ebfa1c5c7f82.csv)","Fecha":"15 de junio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"PUNTA CANA","Valor":"20,00 COP","Valor neto":"20","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"20"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-091fb907753d6a55b10a2459', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9846f130fcd92b9742ce948b', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2d9f87731955405eb57d44b5', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"31 de diciembre de 2025","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"","Valor":"980.000,00 COP","Valor neto":"980000","Abonado a este cargo":"980.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9f7e6d839eb76d8ad87fef61', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"8 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-62d18c972e2c8c29dbe0024b', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"9 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a16c84b8fe53b0f812f2723b', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"15 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ecb1c1d7c9374f2d99b5ba52', 'Celeste Collazos',
    '{"Movimiento":"","Deportista":"Celeste Collazos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Celeste%20Collazos%2030de9302b41180b1ac58e30868d099d0.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d76500694e7665b4203f20db', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-79fe36a3018cd29362990e9a', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4a31b024bda3856c1a910e59', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e55181cee5bd522df53eb66f', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"26 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9e3d534c1fccb952920290ac', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1cd35741cf1959225e9ea953', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"15 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e8a4d06501c7b80a0ac3d5c1', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"5 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7ff89578bd91543c6f2855e2', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"29 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d4c552cc9341e3de72778661', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"28 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bba09d0190eff870c31a5834', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4521e03d470092f45127434a', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"2 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-354dad7f5415601bcf46195a', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"9 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1b6f4fc0122a8ac2bc997c12', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-08a2dc3fe508ef132aef8035', 'Isabella Coral',
    '{"Movimiento":"","Deportista":"Isabella Coral (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Coral%202fee9302b411804fb9a5c15c20a8aaaa.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-74c8258f8e951f7edc657372', 'Laia Martinez',
    '{"Movimiento":"","Deportista":"Laia Martinez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Laia%20Martinez%202efe9302b411800b92e7e62497000589.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-22cbd50c01838ce4dee91d56', 'Laia Martinez',
    '{"Movimiento":"","Deportista":"Laia Martinez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Laia%20Martinez%202efe9302b411800b92e7e62497000589.csv)","Fecha":"23 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Diana","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3c5ad413e180a8ad0bfbf581', 'Laia Martinez',
    '{"Movimiento":"","Deportista":"Laia Martinez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Laia%20Martinez%202efe9302b411800b92e7e62497000589.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5997a4eff2d979ef1a78ee18', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6f26a9e641e947e90df0b7f7', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-39689b9a9feebbf8f329bd0a', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"27 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fb9e5c4b238f394228537278', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Diana","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a3af3154701795aff88e9f92', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"6 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fc69b65893b1b38084d58c3e', 'Lara Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Lara Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lara%20Mu%C3%B1oz%20Ermakova%202efe9302b41180e2ab98d638c20b984c.csv)","Fecha":"29 de abril de 2026","Tipo":"","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-39a89f2947dc404368012a77', 'Lucia Villamil',
    '{"Movimiento":"","Deportista":"Lucia Villamil (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lucia%20Villamil%20327e9302b4118072835ed5c6f95a8b48.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"","Valor":"40.000,00 COP","Valor neto":"40000","Abonado a este cargo":"40.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7444815733b8255b2e67070c', 'Lucia Villamil',
    '{"Movimiento":"","Deportista":"Lucia Villamil (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Lucia%20Villamil%20327e9302b4118072835ed5c6f95a8b48.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a7d3c5358e6252b14b323441', 'Luciana Vallejo Vargas',
    '{"Movimiento":"","Deportista":"Luciana Vallejo Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Vallejo%20Vargas%20300e9302b41180e7bcddcd33ad0345b1.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9d859cc12292b242cedc1136', 'Luciana Vallejo Vargas',
    '{"Movimiento":"","Deportista":"Luciana Vallejo Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Vallejo%20Vargas%20300e9302b41180e7bcddcd33ad0345b1.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6e77111213d59e6083fce597', 'Luciana Vallejo Vargas',
    '{"Movimiento":"","Deportista":"Luciana Vallejo Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Vallejo%20Vargas%20300e9302b41180e7bcddcd33ad0345b1.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-dda592781fcc99bc46801645', 'Luciana Vallejo Vargas',
    '{"Movimiento":"","Deportista":"Luciana Vallejo Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Vallejo%20Vargas%20300e9302b41180e7bcddcd33ad0345b1.csv)","Fecha":"17 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4c4cb2976bcdab63e6a3544d', 'Ma Jose Zabala',
    '{"Movimiento":"","Deportista":"Ma Jose Zabala (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Jose%20Zabala%202f3e9302b4118094bfb8cd4f95e8e149.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3dac6592b153a332dd3046c1', 'Ma Jose Zabala',
    '{"Movimiento":"","Deportista":"Ma Jose Zabala (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Jose%20Zabala%202f3e9302b4118094bfb8cd4f95e8e149.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8e20568f38390d5f2f6f4b8d', 'Ma Mar Betancourth',
    '{"Movimiento":"","Deportista":"Ma Mar Betancourth (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Mar%20Betancourth%202efe9302b411807db465d5ad5e4f5d24.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ccbc390283c0418dbc4cd17b', 'Ma Paula Gomez',
    '{"Movimiento":"","Deportista":"Ma Paula Gomez  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Gomez%202efe9302b41180169173db929cd288b4.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4b0107482d1fb71a4acc2cec', 'Ma Paula Gomez',
    '{"Movimiento":"","Deportista":"Ma Paula Gomez  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Gomez%202efe9302b41180169173db929cd288b4.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9934fed080d1028e5190d67a', 'Ma Paula Gomez',
    '{"Movimiento":"","Deportista":"Ma Paula Gomez  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Paula%20Gomez%202efe9302b41180169173db929cd288b4.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-819d3a4ffb7fa675631c8126', 'Ma Victoria Ruiz',
    '{"Movimiento":"","Deportista":"Ma Victoria Ruiz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ma%20Victoria%20Ruiz%202efe9302b41180129e7ef2b872bbc344.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a9b3502e78c57b826688b68d', 'Mariana Ortiz',
    '{"Movimiento":"","Deportista":"Mariana Ortiz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariana%20Ortiz%202efe9302b4118059bfd7e2e6be8ccda8.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e2f9c75d92b6f906a85c0acf', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"231.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"64000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-45182b568a77518b2336c944', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5175e534f59495d64ea952a1', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c17b407c53cd8c941e97a1f9', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"50.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"27000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4fa6f1892a755e8fb3d8f514', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Cartagena","Valor":"350.000,00 COP","Valor neto":"350000","Abonado a este cargo":"350.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6569e33605ce44eabdc773b7', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d24694c33ee07b9213619556', 'Mia Rodriguez',
    '{"Movimiento":"","Deportista":"Mia Rodriguez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mia%20Rodriguez%202ffe9302b41180ad9482ee33a4b09608.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-baa75f11eb4ff2f9e5ac5052', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-82d86168082590548cb0a688', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"Festival","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9479bfdc0837f94a32aa1341', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"27 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-0965e67a5e71f15c89416d2d', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"20 de mayo de 2026","Tipo":"","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9a538f0c47c3831b0a887ee7', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"6 de mayo de 2026","Tipo":"","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a874069a4eab3805aff1fb70', 'Sofia Muñoz Ermakova',
    '{"Movimiento":"","Deportista":"Sofia Muñoz Ermakova (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sofia%20Mu%C3%B1oz%20Ermakova%202efe9302b411809c94a7d3db8f1fe2c1.csv)","Fecha":"29 de abril de 2026","Tipo":"","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-09613c0ae863d2e6270a970c', 'Sophia Aristizabal',
    '{"Movimiento":"","Deportista":"Sophia Aristizabal (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Aristizabal%20303e9302b41180a992aecd5840228034.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bdad110f5b57bc057245ccdd', 'Sophia Siple',
    '{"Movimiento":"","Deportista":"Sophia Siple (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Siple%2030de9302b41180488901fb98da178f18.csv)","Fecha":"16 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4149d8aab962978bdadb2c7e', 'Sophia Siple',
    '{"Movimiento":"","Deportista":"Sophia Siple (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Siple%2030de9302b41180488901fb98da178f18.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"2h","Valor":"154.000,00 COP","Valor neto":"154000","Abonado a este cargo":"154.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-98819fa4602894ff5c5cf79f', 'Sophia Siple',
    '{"Movimiento":"","Deportista":"Sophia Siple (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Siple%2030de9302b41180488901fb98da178f18.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-79fb277b2cbf2a8666dac14e', 'Sophia Siple',
    '{"Movimiento":"","Deportista":"Sophia Siple (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sophia%20Siple%2030de9302b41180488901fb98da178f18.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa entreno","Profesor":"","Observaciones":"","Valor":"203.000,00 COP","Valor neto":"203000","Abonado a este cargo":"203.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-83ffc42f33ca5f1f26d51892', 'Summer Rain',
    '{"Movimiento":"","Deportista":"Summer Rain (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Summer%20Rain%20329e9302b41180d88865cab39d6ff703.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6210a5737cc76adc00433696', 'Summer Rain',
    '{"Movimiento":"","Deportista":"Summer Rain (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Summer%20Rain%20329e9302b41180d88865cab39d6ff703.csv)","Fecha":"9 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cb51ce1163e477428749a3cb', 'Summer Rain',
    '{"Movimiento":"","Deportista":"Summer Rain (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Summer%20Rain%20329e9302b41180d88865cab39d6ff703.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"70.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7aa9dfec190aa1bf3baab07d', 'Summer Rain',
    '{"Movimiento":"","Deportista":"Summer Rain (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Summer%20Rain%20329e9302b41180d88865cab39d6ff703.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Chequeo","Profesor":"","Observaciones":"Festival","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"75.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2bec45b9656868a326020009', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-deb53a6c8b64417a68df527f', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-03148dca9473ebdee65f0435', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"29 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d747737568404054f58a3e48', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e22f1401c694fd47e7d8dadb', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ac29a2387023eaa3e5f70ac2', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4d5efa0a89b5488044ecb31f', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-00391f4da5b3b0a38894527d', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Liz","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-055658ed62e4ddffb1f3a651', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"15 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b3d45f1ca7032420aeac563f', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"4 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b10c054288e93942effa1d7f', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c54245c47d2881c6b305b3ef', 'Tammy Castellanos',
    '{"Movimiento":"","Deportista":"Tammy Castellanos (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Tammy%20Castellanos%202efe9302b4118016a1d2fa507b64d06b.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"38.500,00 COP","Valor neto":"38500","Abonado a este cargo":"38.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ae9a58477d258acf0b3bccec', 'Valeria Chavez',
    '{"Movimiento":"","Deportista":"Valeria Chavez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Valeria%20Chavez%202f6e9302b411802994c9db45110a8352.csv)","Fecha":"1 de mayo de 2026 → 18 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d9c3a6b8d7fa77d197e1195b', 'Victoria Estepa',
    '{"Movimiento":"","Deportista":"Victoria Estepa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Estepa%202efe9302b411809f8a11c532e66d4cd2.csv)","Fecha":"17 de mayo de 2026","Tipo":"Cargo","Concepto":"Clase extra","Profesor":"","Observaciones":"Festival","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3478993765bf00645884f175', 'Victoria Estepa',
    '{"Movimiento":"","Deportista":"Victoria Estepa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Estepa%202efe9302b411809f8a11c532e66d4cd2.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5aa55fa155e741f774b1702c', 'Victoria Estepa',
    '{"Movimiento":"","Deportista":"Victoria Estepa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Estepa%202efe9302b411809f8a11c532e66d4cd2.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cd02996268e42d133b152ef1', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"29 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-554bcbe84814fe3bf2295571', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-33eb8816d9f2c7f7fcab9dd9', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cc5da6322ccec52335ebd88b', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"0,5","Valor":"38.500,00 COP","Valor neto":"38500","Abonado a este cargo":"38.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d31317a5fc45570b450d5877', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c7ff53d5264421d1d507db25', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"18 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"0,5","Valor":"39.000,00 COP","Valor neto":"39000","Abonado a este cargo":"39.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d5135bdd608ab723d1268211', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"14 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"0,5h","Valor":"38.500,00 COP","Valor neto":"38500","Abonado a este cargo":"38.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-257ad0e14ce4deef40481ece', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"7 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"0,5h","Valor":"38.500,00 COP","Valor neto":"38500","Abonado a este cargo":"38.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-6aaa1592f7334a19cf3d5713', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"4 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-93a9fe545a2d27ca1ffc1ef5', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"17 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8f922819a3fffce3f9b55921', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"0,5h","Valor":"38.500,00 COP","Valor neto":"38500","Abonado a este cargo":"38.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-69d0e274f53f5f3cc2cd2942', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"1 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a146728f8adc3f175d517028', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"132000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-44aa63c08e61c2c6ae9c02de', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"25 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-de571a6e4270fda4efaa8bf8', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"9 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2e43a09fac08eb2878d2854e', 'Carla Sedgemore',
    '{"Movimiento":"","Deportista":"Carla Sedgemore (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Carla%20Sedgemore%202efe9302b41180c78b7adc912ab313a9.csv)","Fecha":"9 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fce390ec3bbfff6268c3dd7e', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"28 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-11b41a860e7d896d0be743c9', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"23 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d597e9bc1e6c4c5feff46264', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c7a17db0bb8e15665358f616', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"20 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1438a30722a798dee2180f2a', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"14 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7745a5d8a69b0df1279d0a3a', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"30 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5c21a54750931e749aefbfa2', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"22 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-cc81d77cd55d8edab1aeb869', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"16 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fd7cc6bffdadf804e3b35096', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"7 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3ab9fbfd9d301f7a20e458ff', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"11 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta","Profesor":"","Observaciones":"","Valor":"45.000,00 COP","Valor neto":"45000","Abonado a este cargo":"45.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1bd60ee71d105c8f22163d48', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"4 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angel","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1c545b0af166c962867d2679', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"11 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8ab3e99a53f0f01ecff6b6fc', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f7ab145151c85d7147b27b4b', 'Isabella Vargas',
    '{"Movimiento":"","Deportista":"Isabella Vargas (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Vargas%202fbe9302b4118090b800f5e08a2eabe1.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Diana","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"115500"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-e4c27a5fead2fc3d046f10e1', 'Isabella Ospina Velasquez',
    '{"Movimiento":"","Deportista":"Isabella Ospina Velasquez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Ospina%20Velasquez%20302e9302b411803db5abc5a97949d2be.csv)","Fecha":"26 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-14cd5fc144fdb1147dd71b0c', 'Isabella Ospina Velasquez',
    '{"Movimiento":"","Deportista":"Isabella Ospina Velasquez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Ospina%20Velasquez%20302e9302b411803db5abc5a97949d2be.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-25cdcf88983c4348bd046881', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-872c8e422ceb0ad9f40fb5e5', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"4 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-126ec2945da1b7835e65a382', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"27 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3d1b4bd5897533f80c4234a2', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"20 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f3bfa1a2df75937ce67b2fb9', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"1 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-3828981a0e13f7e810c32470', 'Salome Figueroa',
    '{"Movimiento":"","Deportista":"Salome Figueroa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Salome%20Figueroa%202efe9302b411804bbf38e80ad02f521d.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-ebed8bbc4f3bc4f37654e4e6', 'Manuela Arias',
    '{"Movimiento":"","Deportista":"Manuela Arias (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Manuela%20Arias%202efe9302b411807da571fb3025763be6.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-352c17f9b6312ec72d63bf6c', 'Daniela Hidalgo',
    '{"Movimiento":"","Deportista":"Daniela Hidalgo  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Daniela%20Hidalgo%202efe9302b41180a28d05ede0e26165a2.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Dani","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f449fabe40f3d6e1fdc3d05f', 'Isabel Sofia Montoya',
    '{"Movimiento":"","Deportista":"Isabel Sofia Montoya  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabel%20Sofia%20Montoya%202fbe9302b411808fa8eff57b1674cbbb.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-991c12d25b4b775e9ed5a61c', 'Isabel Sofia Montoya',
    '{"Movimiento":"","Deportista":"Isabel Sofia Montoya  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabel%20Sofia%20Montoya%202fbe9302b411808fa8eff57b1674cbbb.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-be73a3e6d41784d31f5e90d9', 'Abigail Cuero',
    '{"Movimiento":"","Deportista":"Abigail Cuero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Abigail%20Cuero%202f2e9302b411800ca23bea3525750036.csv)","Fecha":"21 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5h","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9f050eea96240dc10f21b437', 'Abigail Cuero',
    '{"Movimiento":"","Deportista":"Abigail Cuero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Abigail%20Cuero%202f2e9302b411800ca23bea3525750036.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-31e35b95586d3e140128679c', 'Abigail Cuero',
    '{"Movimiento":"","Deportista":"Abigail Cuero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Abigail%20Cuero%202f2e9302b411800ca23bea3525750036.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Chaqueta y legging","Profesor":"","Observaciones":"","Valor":"295.000,00 COP","Valor neto":"295000","Abonado a este cargo":"295.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-b28d8ee5e086dd078555d619', 'Abigail Cuero',
    '{"Movimiento":"","Deportista":"Abigail Cuero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Abigail%20Cuero%202f2e9302b411800ca23bea3525750036.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a4a92344350108a549dec3a1', 'Antonella Castrillon',
    '{"Movimiento":"","Deportista":"Antonella Castrillon (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Castrillon%202efe9302b4118066969cd9d49f746abd.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-2adc8fc46f927658ec67ba6e', 'Emma Galindo',
    '{"Movimiento":"","Deportista":"Emma Galindo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Galindo%202efe9302b4118031ac82ed683d498b68.csv)","Fecha":"19 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"70.000,00 COP","Estado":"🟡 Parcial","Valor pendiente":"7000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a652a6cf18b361eb11ce29a2', 'Aithana Caicedo',
    '{"Movimiento":"","Deportista":"Aithana Caicedo (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Aithana%20Caicedo%20315e9302b41180518aa9ea67e45fb421.csv)","Fecha":"13 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-f60b865715ea2461329c11d3', 'Antonella Gaez',
    '{"Movimiento":"","Deportista":"Antonella Gaez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Gaez%202efe9302b411803ea718e5d64778ab55.csv)","Fecha":"13 de abril de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Gila","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fd8f72bb1a82541d5e9b526b', 'Antonella Florez',
    '{"Movimiento":"","Deportista":"Antonella Florez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Florez%202efe9302b41180c38aeddbaf2702f89c.csv)","Fecha":"10 de abril de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"55.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-720f6c95a4bab231a7d15b6e', 'Giorgia Montaña',
    '{"Movimiento":"","Deportista":"Giorgia Montaña (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Giorgia%20Monta%C3%B1a%202efe9302b41180f481d6ebb6b09df1b9.csv)","Fecha":"22 de mayo de 2026","Tipo":"Cargo","Concepto":"Trusa gala","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"360.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-595d916544467501342d40a0', 'Giorgia Montaña',
    '{"Movimiento":"","Deportista":"Giorgia Montaña (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Giorgia%20Monta%C3%B1a%202efe9302b41180f481d6ebb6b09df1b9.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"88000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7165face3193b0f6abe4275d', 'Giorgia Montaña',
    '{"Movimiento":"","Deportista":"Giorgia Montaña (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Giorgia%20Monta%C3%B1a%202efe9302b41180f481d6ebb6b09df1b9.csv)","Fecha":"15 de junio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"PUNTA CANA","Valor":"230,00 COP","Valor neto":"230","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"230"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-42c4e89cdeb47ffe9aad74f4', 'Ariana Paez',
    '{"Movimiento":"","Deportista":"Ariana Paez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ariana%20Paez%202efe9302b41180a1a12cdbf52df9b676.csv)","Fecha":"","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"Inscripción Ctg","Valor":"567.000,00 COP","Valor neto":"567000","Abonado a este cargo":"567.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9de61e1f48da0434d6124a3d', 'Ariana Paez',
    '{"Movimiento":"","Deportista":"Ariana Paez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ariana%20Paez%202efe9302b41180a1a12cdbf52df9b676.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"2h","Valor":"154.000,00 COP","Valor neto":"154000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"154000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a98d5b0be6b2d99d52bb7fe8', 'Ariana Paez',
    '{"Movimiento":"","Deportista":"Ariana Paez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ariana%20Paez%202efe9302b41180a1a12cdbf52df9b676.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"1,5","Valor":"132.000,00 COP","Valor neto":"132000","Abonado a este cargo":"132.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-48ba8c825ca13cd29e5dca03', 'Ariana Paez',
    '{"Movimiento":"","Deportista":"Ariana Paez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ariana%20Paez%202efe9302b41180a1a12cdbf52df9b676.csv)","Fecha":"25 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5d7caf5011165e2c453bb0a3', 'Ariana Paez',
    '{"Movimiento":"","Deportista":"Ariana Paez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Ariana%20Paez%202efe9302b41180a1a12cdbf52df9b676.csv)","Fecha":"16 de julio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"IBAGUE INSCRIPCION","Valor":"534.000,00 COP","Valor neto":"534000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"534000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-781e6103ea2c64ad80c9e376', 'Sarah Ospina Velasquez',
    '{"Movimiento":"","Deportista":"Sarah Ospina Velasquez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sarah%20Ospina%20Velasquez%20302e9302b41180aa85cdd25a49a8179f.csv)","Fecha":"25 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4a6ae523a8786ab3e455a9ef', 'Sarah Ospina Velasquez',
    '{"Movimiento":"","Deportista":"Sarah Ospina Velasquez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Sarah%20Ospina%20Velasquez%20302e9302b41180aa85cdd25a49a8179f.csv)","Fecha":"26 de mayo de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"1,5h","Valor":"115.500,00 COP","Valor neto":"115500","Abonado a este cargo":"115.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-5dfd1a530d68999f56fa206e', 'Victoria Romero',
    '{"Movimiento":"","Deportista":"Victoria Romero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Romero%202efe9302b41180059bade8029d14d75c.csv)","Fecha":"16 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Dani","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-524b533c9b7be50d698f397b', 'Victoria Romero',
    '{"Movimiento":"","Deportista":"Victoria Romero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Romero%202efe9302b41180059bade8029d14d75c.csv)","Fecha":"2 de julio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Dani","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"77000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-c47af4d51a9d7f01e9b0ddfe', 'Bella Raigoso',
    '{"Movimiento":"","Deportista":"Bella Raigoso (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Bella%20Raigoso%202fde9302b41180a6a2abf0c9563e7f87.csv)","Fecha":"17 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"media hora","Valor":"44.000,00 COP","Valor neto":"44000","Abonado a este cargo":"44.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7106cf56a60d386d5c4c1b2b', 'Bella Raigoso',
    '{"Movimiento":"","Deportista":"Bella Raigoso (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Bella%20Raigoso%202fde9302b41180a6a2abf0c9563e7f87.csv)","Fecha":"18 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"<luna","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8def2a259e455032ff5428b6', 'Bella Raigoso',
    '{"Movimiento":"","Deportista":"Bella Raigoso (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Bella%20Raigoso%202fde9302b41180a6a2abf0c9563e7f87.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Angie","Observaciones":"","Valor":"77.000,00 COP","Valor neto":"77000","Abonado a este cargo":"77.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-76f2cc8f743baa240020e018', 'Violeta Kiwe',
    '{"Movimiento":"","Deportista":"Violeta Kiwe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Violeta%20Kiwe%2034ee9302b41180b8a8cfe1416c399183.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"75000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-970e852136eb251bb9b97b91', 'Violeta Kiwe',
    '{"Movimiento":"","Deportista":"Violeta Kiwe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Violeta%20Kiwe%2034ee9302b41180b8a8cfe1416c399183.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"Fabi","Observaciones":"","Valor":"70.000,00 COP","Valor neto":"70000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"70000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-4ca7c212be2f8eab51e78d27', 'Violeta Kiwe',
    '{"Movimiento":"","Deportista":"Violeta Kiwe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Violeta%20Kiwe%2034ee9302b41180b8a8cfe1416c399183.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"75.000,00 COP","Valor neto":"75000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"75000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a45277988b7c48f1af531491', 'Antonella Botero',
    '{"Movimiento":"","Deportista":"Antonella Botero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Botero%202efe9302b41180949ceafcdbcea2e959.csv)","Fecha":"23 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-898ac2d488bf85b1a5e7b41c', 'Antonella Botero',
    '{"Movimiento":"","Deportista":"Antonella Botero (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Antonella%20Botero%202efe9302b41180949ceafcdbcea2e959.csv)","Fecha":"25 de junio de 2026","Tipo":"Cargo","Concepto":"Personalizado","Profesor":"William","Observaciones":"","Valor":"88.000,00 COP","Valor neto":"88000","Abonado a este cargo":"88.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a3e6674994b664eba3f9d1f9', 'Emiliana Garcia',
    '{"Movimiento":"","Deportista":"Emiliana Garcia (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emiliana%20Garcia%202efe9302b41180b9a0e8c57e861d7f6f.csv)","Fecha":"15 de junio de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"PUNTA CANA","Valor":"230,00 COP","Valor neto":"230","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"230"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-8b09615e29be118ea9932760', 'Manuela Uribe',
    '{"Movimiento":"","Deportista":"Manuela Uribe  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Manuela%20Uribe%202efe9302b4118074a052d66b161c41e0.csv)","Fecha":"30 de junio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"574.000,00 COP","Valor neto":"574000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"574000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-a54b19ae1f5310ac3769e4b6', 'Manuela Uribe',
    '{"Movimiento":"","Deportista":"Manuela Uribe  (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Manuela%20Uribe%202efe9302b4118074a052d66b161c41e0.csv)","Fecha":"30 de junio de 2026 → 28 de julio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-eba61ed245b0ca98b7feb6f8', 'Gabriela Diaz',
    '{"Movimiento":"","Deportista":"Gabriela Diaz (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Diaz%202efe9302b41180a9b269da86bed126f4.csv)","Fecha":"22 de junio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"637.000,00 COP","Valor neto":"637000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"637000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-31c3df170223fc2c66e78596', 'Emma Lopez',
    '{"Movimiento":"","Deportista":"Emma Lopez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emma%20Lopez%203a3e9302b41180d69510ed6bea211d03.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"360.000,00 COP","Valor neto":"360000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"360000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-d1b63f1597fdf670218d9acd', 'Amalia Rocha',
    '{"Movimiento":"","Deportista":"Amalia Rocha (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Amalia%20Rocha%202efe9302b4118075af0acb7d57207b50.csv)","Fecha":"30 de junio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"300.500,00 COP","Valor neto":"300500","Abonado a este cargo":"300.500,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-7ccd3de85c5e21c89a81dd0b', 'Alicia Florez',
    '{"Movimiento":"","Deportista":"Alicia Florez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Alicia%20Florez%202efe9302b41180e3acc9e5342dbfc9d6.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"273.000,00 COP","Valor neto":"273000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"273000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-372b8431fb78611b0a8f631c', 'Mariangel Gomez',
    '{"Movimiento":"","Deportista":"Mariangel Gomez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Mariangel%20Gomez%202f1e9302b4118097ad05c594a33b7c87.csv)","Fecha":"1 de julio de 2026","Tipo":"Cargo","Concepto":"VERANO","Profesor":"","Observaciones":"","Valor":"381.000,00 COP","Valor neto":"381000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"381000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-1cfbf2b0989d1db605108473', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-21041ee94ddd7555318dea1a', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-43b2330542317c9219a336ed', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-fb6528d6acc65948ff3a351f', 'Victoria Ossa',
    '{"Movimiento":"","Deportista":"Victoria Ossa (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Victoria%20Ossa%202f5e9302b411803b92d8e09591e38a01.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9e5e7da88c163ae1e2af7a54', 'Luciana Hincapie',
    '{"Movimiento":"","Deportista":"Luciana Hincapie (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Hincapie%202f3e9302b411801f911ad5c7f9ace2fd.csv)","Fecha":"13 de mayo de 2026","Tipo":"Cargo","Concepto":"Otro","Profesor":"","Observaciones":"CICLO","Valor":"495.000,00 COP","Valor neto":"495000","Abonado a este cargo":"495.000,00 COP","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-acac18539f35c51141497d35', 'Isabella Ospina Velasquez',
    '{"Movimiento":"","Deportista":"Isabella Ospina Velasquez (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Isabella%20Ospina%20Velasquez%20302e9302b411803db5abc5a97949d2be.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-bfe23b07472ebe6e0f95506d', 'Luxiana Santamaria',
    '{"Movimiento":"","Deportista":"Luxiana Santamaria (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luxiana%20Santamaria%202f1e9302b411803d9ff3fc4d96cf414a.csv)","Fecha":"24 de junio de 2026","Tipo":"Cargo","Concepto":"Camiseta polo","Profesor":"","Observaciones":"","Valor":"55.000,00 COP","Valor neto":"55000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"55000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-53278747a92447aa5024b081', 'Emmanuela Palacios',
    '{"Movimiento":"","Deportista":"Emmanuela Palacios (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Emmanuela%20Palacios%202efe9302b41180b1bec4fa584d242a44.csv)","Fecha":"","Tipo":"Cargo","Concepto":"","Profesor":"","Observaciones":"","Valor":"","Valor neto":"","Abonado a este cargo":"","Estado":"🟢 Pagado","Valor pendiente":"0"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-36fd5514c3a0de7625192246', 'Gabriela Uribe',
    '{"Movimiento":"","Deportista":"Gabriela Uribe (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Gabriela%20Uribe%202efe9302b4118042bac1ffc37af70a7c.csv)","Fecha":"30 de junio de 2026 → 28 de julio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"","Valor":"660.000,00 COP","Valor neto":"660000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"660000"}'::jsonb
  ),
(
    'movement', 'notion-movement-archive-9e89ce3569ff2c7d60f46d8e', 'Luciana Orejuela',
    '{"Movimiento":"","Deportista":"Luciana Orejuela (%F0%9F%92%B8%20Control%20ciclos%20deportistas/Luciana%20Orejuela%202f1e9302b41180dab37ce956fcdbe41b.csv)","Fecha":"8 de junio de 2026 → 24 de junio de 2026","Tipo":"Cargo","Concepto":"CICLO","Profesor":"","Observaciones":"9,17,23,24 junio","Valor":"227.000,00 COP","Valor neto":"227000","Abonado a este cargo":"","Estado":"🔴 Pendiente","Valor pendiente":"227000"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6f46b0f533c20a1b7f03c3d7', 'Eva Palomino',
    '{"Nombre de la deportista":"Eva Palomino","Programa":"Intensivo","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"25 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"23 de julio de 2026","Fecha de nacimiento":"07/14/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a5d5948661dfa916016a264b', 'Mariana Zuñiga',
    '{"Nombre de la deportista":"Mariana Zuñiga","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"28 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"25 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"25 de junio de 2026","Fecha de nacimiento":"09/12/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1e705cc506a46a51b6beefb2', 'Gabriela Uribe',
    '{"Nombre de la deportista":"Gabriela Uribe","Programa":"Intensivo","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"30 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"28 de julio de 2026","Fecha de nacimiento":"08/05/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-67ee21cb96d671bce2d8aa95', 'Carla Sedgemore',
    '{"Nombre de la deportista":"Carla Sedgemore","Programa":"Intensivo","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"660000","Observaciones":"","Edad":"5","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":"08/10/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1cd77f97cbaba805ce0be955', 'Luciana Arenas',
    '{"Nombre de la deportista":"Luciana Arenas","Programa":"Intensivo","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"01/22/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5d16df2c8fbb5fefe1a4f504', 'Gabriela Duque',
    '{"Nombre de la deportista":"Gabriela Duque","Programa":"Intensivo","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"660000","Observaciones":"","Edad":"5","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":"08/12/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-41ba8bce762243f13d36696b', 'Antonia Naranjo',
    '{"Nombre de la deportista":"Antonia Naranjo","Programa":"Intensivo","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"660000","Observaciones":"","Edad":"8","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"07/08/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-733243bd210b5212e12ed2a9', 'Antonella Gaez',
    '{"Nombre de la deportista":"Antonella Gaez","Programa":"Intensivo","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"05/02/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0c2f5e79b317d561ca311eeb', 'Emma Galindo',
    '{"Nombre de la deportista":"Emma Galindo","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"11/18/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b11e9e25a6c3a41f96a56d70', 'Ma Celeste Cruz',
    '{"Nombre de la deportista":"Ma Celeste Cruz","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"01/01/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-70aaf13a3320799d79ccac71', 'Abigail Giraldo',
    '{"Nombre de la deportista":"Abigail Giraldo","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"10/03/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ffb1ea08ffbb0685cf40f3c1', 'Salome Escobar',
    '{"Nombre de la deportista":"Salome Escobar","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":"02/18/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3c93a2a41b5a2621ae0f1272', 'Tammy Castellanos',
    '{"Nombre de la deportista":"Tammy Castellanos","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"05/06/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-625bad29319da5528d93e420', 'Ma Mar Betancourth',
    '{"Nombre de la deportista":"Ma Mar Betancourth","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"11/22/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2d19925b11673064a66219b9', 'Salome Figueroa',
    '{"Nombre de la deportista":"Salome Figueroa","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"3 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"31 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"12","Fecha fin del ciclo":"31 de julio de 2026","Fecha de nacimiento":"02/18/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-877cf053a02e934e8a1c99e6', 'Victoria Estepa',
    '{"Nombre de la deportista":"Victoria Estepa","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"31 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"28 de agosto de 2026","Valor pagado":"660","Observaciones":"","Edad":"9","Fecha fin del ciclo":"28 de agosto de 2026","Fecha de nacimiento":"08/09/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4f98ad2fcaea3b5768f10282', 'Manuela Arias',
    '{"Nombre de la deportista":"Manuela Arias","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"4 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"1 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"1 de septiembre de 2026","Fecha de nacimiento":"11/06/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c641e8b85d652fe4d8ebc333', 'Ariana Paez',
    '{"Nombre de la deportista":"Ariana Paez","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"21 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"18 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"18 de agosto de 2026","Fecha de nacimiento":"06/20/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2942d46905d99a6d91469e1d', 'Giorgia Montaña',
    '{"Nombre de la deportista":"Giorgia Montaña","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"4 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"1 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"1 de septiembre de 2026","Fecha de nacimiento":"08/23/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-52ef9902b282a3da4afff974', 'Sofia Montaño',
    '{"Nombre de la deportista":"Sofia Montaño","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":"03/03/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ed2f0b72f846521871b0dd29', 'Sophia Londoño',
    '{"Nombre de la deportista":"Sophia Londoño","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"02/02/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-768ed6a4f30a109856be7646', 'Paulina Mattey',
    '{"Nombre de la deportista":"Paulina Mattey","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"19 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"16 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"16 de septiembre de 2026","Fecha de nacimiento":"11/10/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bbfe9e36e8eb8f4e0e215557', 'Gabriela Chaurra',
    '{"Nombre de la deportista":"Gabriela Chaurra","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"RETIRADO","Inicio ciclo":"26 de enero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de febrero de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"23 de febrero de 2026","Fecha de nacimiento":"10/12/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7a280170b1a592203f366029', 'Martina Rodriguez',
    '{"Nombre de la deportista":"Martina Rodriguez","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":"11/08/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7a622f236f5209050fbe13d2', 'Ariana Vargas',
    '{"Nombre de la deportista":"Ariana Vargas","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"660000","Observaciones":"","Edad":"10","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"10/01/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e5a76b0d1b412c1ca0a61dc2', 'Mariana Londoño',
    '{"Nombre de la deportista":"Mariana Londoño","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"10 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"7 de agosto de 2026","Valor pagado":"","Observaciones":"murio tio","Edad":"11","Fecha fin del ciclo":"7 de agosto de 2026","Fecha de nacimiento":"03/28/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1af6a42f0f1d32bc28444032', 'Emmanuela Palacios',
    '{"Nombre de la deportista":"Emmanuela Palacios","Programa":"Intensivo","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"30 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"12","Fecha fin del ciclo":"28 de mayo de 2026","Fecha de nacimiento":"05/20/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5f04fdb22ac648aacc85d86b', 'Mariana Chaves',
    '{"Nombre de la deportista":"Mariana Chaves","Programa":"Intensivo","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"13 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"10 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"14","Fecha fin del ciclo":"10 de agosto de 2026","Fecha de nacimiento":"09/06/2011"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8ec86b7ba769f878ef2efc85', 'Ma Jose Valencia',
    '{"Nombre de la deportista":"Ma Jose Valencia","Programa":"Intensivo","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"3 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"31 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"13","Fecha fin del ciclo":"31 de agosto de 2026","Fecha de nacimiento":"06/05/2013"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2ad5973f6b8cbf3008bbea35', 'Martina Lopez',
    '{"Nombre de la deportista":"Martina Lopez","Programa":"Intensivo","Nivel":"NIVEL 5","Estado":"RETIRADO","Inicio ciclo":"5 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"2 de abril de 2026","Fecha de nacimiento":"06/27/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0da677b947647ebd7a2b02c0', 'Marthina Soto',
    '{"Nombre de la deportista":"Marthina Soto","Programa":"Intensivo","Nivel":"NIVEL 5","Estado":"RETIRADO","Inicio ciclo":"5 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"14","Fecha fin del ciclo":"2 de abril de 2026","Fecha de nacimiento":"06/29/2012"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c8da61e8f5fdfaee2b4215b2', 'Hannah Navia',
    '{"Nombre de la deportista":"Hannah Navia","Programa":"Intensivo","Nivel":"NIVEL 5","Estado":"ACTIVO","Inicio ciclo":"3 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"31 de agosto de 2026","Valor pagado":"","Observaciones":"pausa ciclo por incapacidad, 3 semanas pendientes de tomar","Edad":"10","Fecha fin del ciclo":"31 de agosto de 2026","Fecha de nacimiento":"07/30/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-84fb3779422ce2cdeaea90df', 'Ana Emilia Medina',
    '{"Nombre de la deportista":"Ana Emilia Medina","Programa":"Intensivo","Nivel":"NIVEL 5","Estado":"ACTIVO","Inicio ciclo":"30 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"27 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"12","Fecha fin del ciclo":"27 de agosto de 2026","Fecha de nacimiento":"10/23/2013"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8762a3a3fa32dfe77668d4e9', 'Ma Paula Gomez',
    '{"Nombre de la deportista":"Ma Paula Gomez ","Programa":"Intensivo","Nivel":"NIVEL 5","Estado":"PAUSADO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":"01/14/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-398ab73a43cf581f1c0fbcae', 'Valery Cordoba',
    '{"Nombre de la deportista":"Valery Cordoba ","Programa":"Regular","Nivel":"NIVEL 4","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"374","Observaciones":"","Edad":"11","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"10/05/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3e721a4eade77b477d454577', 'Mariana Ortiz',
    '{"Nombre de la deportista":"Mariana Ortiz","Programa":"Minis","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"26 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de junio de 2026","Valor pagado":"333000","Observaciones":"","Edad":"7","Fecha fin del ciclo":"23 de junio de 2026","Fecha de nacimiento":"04/06/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-205e79cc9f149e0f548c219b', 'Paulina Velez',
    '{"Nombre de la deportista":"Paulina Velez","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"660000","Observaciones":"","Edad":"7","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":"11/14/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c242826f87bd316588bc168b', 'Emiliana Silva',
    '{"Nombre de la deportista":"Emiliana Silva","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"05/23/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-28112cdb11770792a978e762', 'Antonella Katarain',
    '{"Nombre de la deportista":"Antonella Katarain","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"30 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"28 de mayo de 2026","Fecha de nacimiento":"11/12/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c0dff383e4a8e0d9cb6eea76', 'Antonella Endo',
    '{"Nombre de la deportista":"Antonella Endo","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"660000","Observaciones":"","Edad":"8","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"08/25/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-601a67451f16d85e4424436c', 'Rebecca Endo',
    '{"Nombre de la deportista":"Rebecca Endo","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"337000","Observaciones":"","Edad":"6","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":"04/08/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f7336d568f0c1c17a2e03385', 'Emiliana Garcia',
    '{"Nombre de la deportista":"Emiliana Garcia","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"27 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"25 de julio de 2026","Valor pagado":"","Observaciones":"P/$99.000","Edad":"10","Fecha fin del ciclo":"25 de julio de 2026","Fecha de nacimiento":"12/27/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9693693ee3c5de79770dc0c4', 'Antonella Castrillon',
    '{"Nombre de la deportista":"Antonella Castrillon","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"5 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"2 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"2 de septiembre de 2026","Fecha de nacimiento":"09/18/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9987fc9b17ef99a8b3e73728', 'Alicia Florez',
    '{"Nombre de la deportista":"Alicia Florez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"25 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"23 de julio de 2026","Fecha de nacimiento":"04/17/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5334e90cede66d3b363b5ac0', 'Valentina Rodriguez',
    '{"Nombre de la deportista":"Valentina Rodriguez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"21 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"18 de agosto de 2026","Valor pagado":"227000","Observaciones":"","Edad":"6","Fecha fin del ciclo":"18 de agosto de 2026","Fecha de nacimiento":"12/20/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fed2662aa1f397e09e566ee5', 'Antonella Florez',
    '{"Nombre de la deportista":"Antonella Florez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":"10/20/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bcc0985eeaef00f6b6bdcf16', 'Amanda Ramirez',
    '{"Nombre de la deportista":"Amanda Ramirez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"3","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":"11/25/2022"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4a3202ab8f2fca3f15b4e860', 'Sara Escobar',
    '{"Nombre de la deportista":"Sara Escobar","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"275000","Observaciones":"","Edad":"4","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":"07/16/2022"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ad1de8019b0f55448b12730d', 'Olivia Ceballos',
    '{"Nombre de la deportista":"Olivia Ceballos ","Programa":"Intensivo","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"20 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"17 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"17 de agosto de 2026","Fecha de nacimiento":"10/26/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a3c042b4f98eb6f1fb4338f3', 'Martina Reyes',
    '{"Nombre de la deportista":"Martina Reyes","Programa":"Regular","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"01/25/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-cf530821a55502f95f1885c9', 'Noah Reyes',
    '{"Nombre de la deportista":"Noah Reyes","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"3","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"07/27/2022"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7480145ffafc873e2135187c', 'Julieta Gomez',
    '{"Nombre de la deportista":"Julieta Gomez","Programa":"Minis","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":"07/24/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-19ac4aa6f4bdee84833db61b', 'Ma Antonia Arce',
    '{"Nombre de la deportista":"Ma Antonia Arce","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"374000","Observaciones":"","Edad":"6","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":"09/30/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5b2224c1fadc40a26c814d84', 'Zoe Martinez',
    '{"Nombre de la deportista":"Zoe Martinez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"30 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"27 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"27 de agosto de 2026","Fecha de nacimiento":"01/24/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-48d5bf373faeefd6170ef77e', 'Ma Antonia Rico',
    '{"Nombre de la deportista":"Ma Antonia Rico","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"20 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"17 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"17 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-528d3acbe9ca4f98173dc156', 'Lena Barona',
    '{"Nombre de la deportista":"Lena Barona","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"30 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"27 de junio de 2026","Fecha de nacimiento":"05/26/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b3714daeff556b593dca9939', 'Valentina Valencia',
    '{"Nombre de la deportista":"Valentina Valencia","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"18 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de agosto de 2026","Valor pagado":"227000","Observaciones":"","Edad":"12","Fecha fin del ciclo":"15 de agosto de 2026","Fecha de nacimiento":"06/06/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e9c08df3f7555ec95194b3ba', 'Helena Salazar',
    '{"Nombre de la deportista":"Helena Salazar","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"4 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"2 de mayo de 2026","Fecha de nacimiento":"09/27/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d81f34024a11b04825a10d1b', 'Andrea Barreto',
    '{"Nombre de la deportista":"Andrea Barreto","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"4 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"1 de septiembre de 2026","Valor pagado":"227000","Observaciones":"","Edad":"5","Fecha fin del ciclo":"1 de septiembre de 2026","Fecha de nacimiento":"12/26/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c4d02b063078a204899641a6', 'Alanna Segura',
    '{"Nombre de la deportista":"Alanna Segura","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"374","Observaciones":"","Edad":"6","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"09/05/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-613f44fdc5c98d4896113c19', 'Victoria Romero',
    '{"Nombre de la deportista":"Victoria Romero","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":"12/12/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4e580697268ece745bf9bc7e', 'Manuela Uribe',
    '{"Nombre de la deportista":"Manuela Uribe ","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"30 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"28 de julio de 2026","Fecha de nacimiento":"02/07/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fb7794d0cfdf0fb23bc477bc', 'Amalia Rocha',
    '{"Nombre de la deportista":"Amalia Rocha","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"1 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"4","Fecha fin del ciclo":"29 de julio de 2026","Fecha de nacimiento":"08/13/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a31714ae018f0fe62d6a7a2e', 'Alana Barrera',
    '{"Nombre de la deportista":"Alana Barrera","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"4","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":"09/12/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1de7f24b1a7ad7bce0c5ec0b', 'Luciana Toro',
    '{"Nombre de la deportista":"Luciana Toro","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"1 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"29 de julio de 2026","Fecha de nacimiento":"01/11/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-187f5b21c08d309b56b2a624', 'Luisa Carrillo',
    '{"Nombre de la deportista":"Luisa Carrillo","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"11 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"8 de abril de 2026","Fecha de nacimiento":"11/07/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-51eaec853c34c3cc6caac757', 'Gabriela Diaz',
    '{"Nombre de la deportista":"Gabriela Diaz","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":"02/28/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b551d20d2349f2e22bfe689b', 'Itala Ma Orozco',
    '{"Nombre de la deportista":"Itala Ma Orozco","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":"11/25/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8dcf851465b261853ddb5638', 'Ana Sofia Echeverry',
    '{"Nombre de la deportista":"Ana Sofia Echeverry","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"374000","Observaciones":"","Edad":"11","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":"08/21/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8165105350bbae5b8e301fc5', 'Paulina Ruiz',
    '{"Nombre de la deportista":"Paulina Ruiz","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"3 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"1 de julio de 2026","Fecha de nacimiento":"08/12/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0359e786ddcc0ff56f0d275f', 'Emilia Gomez Gonzalez',
    '{"Nombre de la deportista":"Emilia Gomez Gonzalez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"05/24/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e315b9ffb5cad7e990b581a2', 'Guadalupe Velasquez',
    '{"Nombre de la deportista":"Guadalupe Velasquez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"11/01/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-569f8e6c01502b8f305f1757', 'Ma Jose Gonzalez',
    '{"Nombre de la deportista":"Ma Jose Gonzalez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"07/26/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-581d9afb68ddf9fa5fabe9ca', 'Sofia Ospina Zapata',
    '{"Nombre de la deportista":"Sofia Ospina Zapata","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"14 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"11 de junio de 2026","Fecha de nacimiento":"06/26/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9fd18d4737aa50b36a0464a2', 'Sara Ospina Zapata',
    '{"Nombre de la deportista":"Sara Ospina Zapata","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"14 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"11 de junio de 2026","Fecha de nacimiento":"10/09/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7142ddfebe0182f7aec6ae7f', 'Gabriela Gonzalez',
    '{"Nombre de la deportista":"Gabriela Gonzalez","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"9","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":"06/09/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-47b5f19b68747aa4de507132', 'Sofia Herrera',
    '{"Nombre de la deportista":"Sofia Herrera","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"4 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-511c573a6697d465bc1d4cf9', 'Emilia Gomez Aristizabal',
    '{"Nombre de la deportista":"Emilia Gomez Aristizabal","Programa":"Minis","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"31 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"28 de agosto de 2026","Valor pagado":"275000","Observaciones":"","Edad":"5","Fecha fin del ciclo":"28 de agosto de 2026","Fecha de nacimiento":"11/11/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ce844c199674330461579765', 'Antonella Serrano',
    '{"Nombre de la deportista":"Antonella Serrano","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"5 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"3 de julio de 2026","Fecha de nacimiento":"06/03/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8e58b9fcac72514718f6203c', 'Juliana Benavides',
    '{"Nombre de la deportista":"Juliana Benavides","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"5 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de julio de 2026","Valor pagado":"227000","Observaciones":"","Edad":"9","Fecha fin del ciclo":"3 de julio de 2026","Fecha de nacimiento":"10/07/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-77f965b28573f641df702734', 'Maite Luna',
    '{"Nombre de la deportista":"Maite Luna","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"27 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"24 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"24 de agosto de 2026","Fecha de nacimiento":"09/06/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3a2dd55cdcce1298217be467', 'Samara Ochoa',
    '{"Nombre de la deportista":"Samara Ochoa","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"374000","Observaciones":"","Edad":"6","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":"01/23/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fa76295bd7f8f2c131b551c8', 'Violetta Alarcon',
    '{"Nombre de la deportista":"Violetta Alarcon","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":"03/15/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d71e14186fc22c7584f7bd81', 'Emma Rodriguez',
    '{"Nombre de la deportista":"Emma Rodriguez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"9 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"6 de junio de 2026","Fecha de nacimiento":"09/27/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c3eac82006604e6be0300b1f', 'Ma del Mar Guerrero',
    '{"Nombre de la deportista":"Ma del Mar Guerrero","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"14 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de abril de 2026","Valor pagado":"","Observaciones":"posible lesion cervical","Edad":"6","Fecha fin del ciclo":"11 de abril de 2026","Fecha de nacimiento":"05/26/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3bfbb6f56ab3a3653a79288a', 'Luciana Moreno',
    '{"Nombre de la deportista":"Luciana Moreno","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"18 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"16 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"16 de mayo de 2026","Fecha de nacimiento":"05/10/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-aa74922e533f509070e4a43b', 'Valeria Burbano',
    '{"Nombre de la deportista":"Valeria Burbano","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"178","Observaciones":"","Edad":"5","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":"05/02/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-59ae8dd738932510aa44c554', 'Sofia Muñoz Ermakova',
    '{"Nombre de la deportista":"Sofia Muñoz Ermakova","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"6 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"4 de julio de 2026","Fecha de nacimiento":"06/21/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a628653000f2407a24fc34f6', 'Lara Muñoz Ermakova',
    '{"Nombre de la deportista":"Lara Muñoz Ermakova","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"6 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"4 de julio de 2026","Fecha de nacimiento":"06/14/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3b6dc1d206e49e08bc05800b', 'Elena Montoya',
    '{"Nombre de la deportista":"Elena Montoya","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"11 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de agosto de 2026","Valor pagado":"","Observaciones":"ortopedista","Edad":"12","Fecha fin del ciclo":"8 de agosto de 2026","Fecha de nacimiento":"04/11/2014"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7fa43c76725c647679f624d4', 'Guadalupe Rivera',
    '{"Nombre de la deportista":"Guadalupe Rivera","Programa":"Regular","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"6 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"5","Fecha fin del ciclo":"3 de agosto de 2026","Fecha de nacimiento":"07/21/2021"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2190bc5522a5a44b6c4e1829', 'Celeste Arias',
    '{"Nombre de la deportista":"Celeste Arias","Programa":"Regular","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b3ca68bac079029a530ddc09', 'Martina Arias',
    '{"Nombre de la deportista":"Martina Arias","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"11 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"8 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-28c8cc05c570d41e49297b36', 'Ma Victoria Ruiz',
    '{"Nombre de la deportista":"Ma Victoria Ruiz","Programa":"Regular","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"10 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"8 de julio de 2026","Fecha de nacimiento":"05/27/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f224ede761fea59c47a668e6', 'Ma Antonia Ruiz',
    '{"Nombre de la deportista":"Ma Antonia Ruiz","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"10 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"8 de julio de 2026","Fecha de nacimiento":"04/24/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-73ee4d52e527b23d5440af9f', 'Sara Bravo',
    '{"Nombre de la deportista":"Sara Bravo","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"15 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"13 de julio de 2026","Fecha de nacimiento":"11/10/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6dcd23435d664d6f1daf0278', 'Agustina Diaz',
    '{"Nombre de la deportista":"Agustina Diaz","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"374","Observaciones":"","Edad":"7","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":"11/09/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8e933bf8db35fb70439e37bf', 'Lucciana Botero',
    '{"Nombre de la deportista":"Lucciana Botero","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"29 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d4616950578f8ba12525b266', 'Dulce Ma Aristizabal',
    '{"Nombre de la deportista":"Dulce Ma Aristizabal","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-21a94f2bcd93e4aa3cf920e4', 'Daniela Hidalgo',
    '{"Nombre de la deportista":"Daniela Hidalgo ","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"6 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6a6d161223d22e2cce9faef1', 'Manuela Perdomo',
    '{"Nombre de la deportista":"Manuela Perdomo","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"16 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"11","Fecha fin del ciclo":"13 de agosto de 2026","Fecha de nacimiento":"01/25/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-81e04009bbf9e946648a804a', 'Luciana Cardenas',
    '{"Nombre de la deportista":"Luciana Cardenas","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"6 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"3 de septiembre de 2026","Valor pagado":"","Observaciones":"muevo ciclo 1 semana","Edad":"","Fecha fin del ciclo":"3 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bb4586b58880d7ab1c8f178a', 'Lucia Valdes',
    '{"Nombre de la deportista":"Lucia Valdes","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"10 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de julio de 2026","Valor pagado":"227","Observaciones":"","Edad":"10","Fecha fin del ciclo":"8 de julio de 2026","Fecha de nacimiento":"10/14/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1dd93648981421e8db128509', 'Guadalupe Riascos',
    '{"Nombre de la deportista":"Guadalupe Riascos","Programa":"Regular","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"18 de febrero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"18 de marzo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"18 de marzo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bd6b6a36235ef79a1991799b', 'Luciana Vallejo Ossa',
    '{"Nombre de la deportista":"Luciana Vallejo Ossa","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"3 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"31 de agosto de 2026","Valor pagado":"374","Observaciones":"","Edad":"8","Fecha fin del ciclo":"31 de agosto de 2026","Fecha de nacimiento":"11/27/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2427854ad411b9762c422169', 'Laia Martinez',
    '{"Nombre de la deportista":"Laia Martinez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"8 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"5 de agosto de 2026","Valor pagado":"374","Observaciones":"","Edad":"8","Fecha fin del ciclo":"5 de agosto de 2026","Fecha de nacimiento":"04/21/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f8d44e8313bf607c40405eaf', 'Antonella Botero',
    '{"Nombre de la deportista":"Antonella Botero","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"27 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"24 de agosto de 2026","Valor pagado":"374","Observaciones":"Mes incapacidad","Edad":"7","Fecha fin del ciclo":"24 de agosto de 2026","Fecha de nacimiento":"09/18/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ebf40369b7593835bb26c253', 'Emilia Hernandez',
    '{"Nombre de la deportista":"Emilia Hernandez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"25 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"23 de julio de 2026","Fecha de nacimiento":"06/06/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b96bdd65d7cef60cacea36f2', 'Carlota Llanos',
    '{"Nombre de la deportista":"Carlota Llanos ","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"30 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"28 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-909ecc1a9528027e487fc7e1', 'Emma Vega',
    '{"Nombre de la deportista":"Emma Vega","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"16 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"14 de mayo de 2026","Valor pagado":"","Observaciones":"fractura tobillo","Edad":"6","Fecha fin del ciclo":"14 de mayo de 2026","Fecha de nacimiento":"05/14/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-114c38e12d854a91c932a864', 'Martina Villegas',
    '{"Nombre de la deportista":"Martina Villegas","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"14 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"11 de junio de 2026","Fecha de nacimiento":"06/01/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-694b135fdce30db307b3fb49', 'Sofia Carmona',
    '{"Nombre de la deportista":"Sofia Carmona","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"5 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"2 de septiembre de 2026","Valor pagado":"227","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-00b80fe9759a84017602d0e0', 'Mia Alejandra Castro',
    '{"Nombre de la deportista":"Mia Alejandra Castro","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"15 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4f0d12c06ef2d2ea997096cc', 'Miranda Villa',
    '{"Nombre de la deportista":"Miranda Villa","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"18 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de abril de 2026","Valor pagado":"374","Observaciones":"","Edad":"8","Fecha fin del ciclo":"15 de abril de 2026","Fecha de nacimiento":"09/28/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d9f68d8692d37d2fffd803ea', 'Ma Clara Quintero',
    '{"Nombre de la deportista":"Ma Clara Quintero","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"16 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"14 de julio de 2026","Valor pagado":"405000","Observaciones":"","Edad":"8","Fecha fin del ciclo":"14 de julio de 2026","Fecha de nacimiento":"03/18/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a2e86dac59fe82851b596e71', 'Luxiana Santamaria',
    '{"Nombre de la deportista":"Luxiana Santamaria","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"7 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de agosto de 2026","Valor pagado":"","Observaciones":"Vacaciones semana santa","Edad":"","Fecha fin del ciclo":"4 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5f0164e60f1fdaab00afb33b', 'Ana Sofia Gutierrez',
    '{"Nombre de la deportista":"Ana Sofia Gutierrez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"8 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"5 de agosto de 2026","Valor pagado":"374","Observaciones":"","Edad":"8","Fecha fin del ciclo":"5 de agosto de 2026","Fecha de nacimiento":"05/04/2018"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6a1de650758dbf725d41246f', 'Ma Jose Ospina',
    '{"Nombre de la deportista":"Ma Jose Ospina","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"11 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"9 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"9 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-578fccf06cef50b1a32dd293', 'Shaira Valentina Ruiz',
    '{"Nombre de la deportista":"Shaira Valentina Ruiz","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0d46c5d280670270e9e5404f', 'Samantha Manrique',
    '{"Nombre de la deportista":"Samantha Manrique","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9d99502349141f6855959f22', 'Ana Sofia Ortiz',
    '{"Nombre de la deportista":"Ana Sofia Ortiz","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"13 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"10 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"10 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-06ac92ce4d458f2c0d284d32', 'Mariangel Gomez',
    '{"Nombre de la deportista":"Mariangel Gomez","Programa":"Intensivo","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"10 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de julio de 2026","Valor pagado":"660000","Observaciones":"","Edad":"9","Fecha fin del ciclo":"8 de julio de 2026","Fecha de nacimiento":"06/16/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-40f33099f5d4b831fc2deae4', 'Luciana Orejuela',
    '{"Nombre de la deportista":"Luciana Orejuela","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"7","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":"06/05/2019"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1d5b7f37a8c149f717a313dc', 'Ma Belen Quintero',
    '{"Nombre de la deportista":"Ma Belen Quintero","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"24 de febrero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de marzo de 2026","Valor pagado":"","Observaciones":"","Edad":"3","Fecha fin del ciclo":"24 de marzo de 2026","Fecha de nacimiento":"03/13/2023"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8cca328fb87fd9117c4a57a3', 'Celeste Giraldo',
    '{"Nombre de la deportista":"Celeste Giraldo","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"3 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"8","Fecha fin del ciclo":"1 de julio de 2026","Fecha de nacimiento":"10/23/2017"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-23b2951418f7ce4d0a45935d', 'Salome Navia',
    '{"Nombre de la deportista":"Salome Navia","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"16 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"14 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"14 de julio de 2026","Fecha de nacimiento":"10/11/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-156b78cb98e0def8c21a4b80', 'Gabriela Cardona',
    '{"Nombre de la deportista":"Gabriela Cardona","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"7 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"4 de septiembre de 2026","Valor pagado":"227","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e865653010518399b02824db', 'Abigail Cuero',
    '{"Nombre de la deportista":"Abigail Cuero","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"7 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"4 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ace0c7d3b9e41aec5051fc4d', 'Ma Alejandra Calle',
    '{"Nombre de la deportista":"Ma Alejandra Calle","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"7 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"4 de septiembre de 2026","Valor pagado":"227","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e2012b78206c7169a00a8cf6', 'Anny Rebolledo',
    '{"Nombre de la deportista":"Anny Rebolledo","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-732f71387395a33a334b621a', 'Sally Neenan',
    '{"Nombre de la deportista":"Sally Neenan","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"13 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6314885c4d39f35ea8d7f60b', 'Shirley Neenan',
    '{"Nombre de la deportista":"Shirley Neenan","Programa":"Minis","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"13 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8863e597bd1bedfeff3af603', 'Ma Jose Osorio',
    '{"Nombre de la deportista":"Ma Jose Osorio","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"16 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"13","Fecha fin del ciclo":"13 de junio de 2026","Fecha de nacimiento":"07/21/2013"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-69ca7fe27e0251195978cfe4', 'Dulce Ma Soto',
    '{"Nombre de la deportista":"Dulce Ma Soto","Programa":"Regular","Nivel":"NIVEL 2","Estado":"RETIRADO","Inicio ciclo":"18 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"16 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"16 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5cf25ac099caae72d2bc941e', 'Ma Jose Zabala',
    '{"Nombre de la deportista":"Ma Jose Zabala","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"13 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1dcbe96f1f4fd800cdc96444', 'Luciana Hincapie',
    '{"Nombre de la deportista":"Luciana Hincapie","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"3 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de julio de 2026","Valor pagado":"660","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-be02a817daddee92970d1d19', 'Macarena Farfan',
    '{"Nombre de la deportista":"Macarena Farfan","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8368086a9ea3af79059277b1', 'Helena Agudelo',
    '{"Nombre de la deportista":"Helena Agudelo ","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"16 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"14 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"14 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4cb87f199f58907a2bc21a5c', 'Eugenia Sandoval',
    '{"Nombre de la deportista":"Eugenia Sandoval ","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"24 de febrero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de marzo de 2026","Valor pagado":"","Observaciones":"Incapacitada tobillo","Edad":"","Fecha fin del ciclo":"24 de marzo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-28014dc1fc42ead16b692369', 'Victoria Ossa',
    '{"Nombre de la deportista":"Victoria Ossa","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"18 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de junio de 2026","Valor pagado":"374","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0324028c1929ef6189571d16', 'Violetta Hoyos',
    '{"Nombre de la deportista":"Violetta Hoyos","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"18 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-be7f9e33f66ca6a6a693d1b3', 'Valeria Chavez',
    '{"Nombre de la deportista":"Valeria Chavez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"18 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"13","Fecha fin del ciclo":"15 de junio de 2026","Fecha de nacimiento":"11/16/2012"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0689cff5b6beabefa93b4433', 'Ma Alejandra Diaz',
    '{"Nombre de la deportista":"Ma Alejandra Diaz","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"13 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"10 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"10","Fecha fin del ciclo":"10 de agosto de 2026","Fecha de nacimiento":"11/27/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-138812bc2125fee186a17cb9', 'Anthonella Parra',
    '{"Nombre de la deportista":"Anthonella Parra","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"17 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de julio de 2026","Valor pagado":"227000","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-95efec578e4d83ff3fd81773', 'Isabella Valencia',
    '{"Nombre de la deportista":"Isabella Valencia","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"22 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"19 de agosto de 2026","Valor pagado":"374000","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0bf41a9b78b5c15f9ce43bab', 'Natalia Barrera',
    '{"Nombre de la deportista":"Natalia Barrera","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"6 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"3 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-dc46338fd319028e791736da', 'Samantha Salazar',
    '{"Nombre de la deportista":"Samantha Salazar","Programa":"Regular","Nivel":"NIVEL 1","Estado":"RETIRADO","Inicio ciclo":"25 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-060613f23f982c975fd96a03', 'Antonia Esguerra',
    '{"Nombre de la deportista":"Antonia Esguerra","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d0ac9eb944bf61d498495e10', 'Danna Farfan',
    '{"Nombre de la deportista":"Danna Farfan","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"16 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de agosto de 2026","Valor pagado":"275000","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ab50c615a775fb95d6c2428f', 'Paulina Gomez',
    '{"Nombre de la deportista":"Paulina Gomez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"29 de enero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"26 de febrero de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"26 de febrero de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e91e622efb8d14d030532602', 'Genesis Escamilla',
    '{"Nombre de la deportista":"Genesis Escamilla","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"12 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"10 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"10 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fccd804bc34d2ef1bba7fd08', 'Alexa Ibargüen',
    '{"Nombre de la deportista":"Alexa Ibargüen","Programa":"Minis","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"31 de enero de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de febrero de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"28 de febrero de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3d27683f65b16f6cd04205c0', 'Isabel Sofia Montoya',
    '{"Nombre de la deportista":"Isabel Sofia Montoya ","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"18 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f9885b6393d56f76598b76b4', 'Isabella Nieto',
    '{"Nombre de la deportista":"Isabella Nieto","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"227000","Observaciones":"","Edad":"9","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":"11/15/2016"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-584e2053b11dd94df51cd05b', 'Isabella Vargas',
    '{"Nombre de la deportista":"Isabella Vargas","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3193dba0e6cfabc3781d264d', 'Emma Vargas',
    '{"Nombre de la deportista":"Emma Vargas","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"24 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"21 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4fe2ba3030ab523f7d876b1a', 'Antonia Garzon',
    '{"Nombre de la deportista":"Antonia Garzon ","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"23 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"21 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8dba15e3c48cba45a7b11a51', 'Salome Enriquez',
    '{"Nombre de la deportista":"Salome Enriquez","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3b9687b3dd66f346a37f9858', 'Valentina Silva',
    '{"Nombre de la deportista":"Valentina Silva","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"374000","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-42ac88eda17f554c32284fa6', 'Emma Seba',
    '{"Nombre de la deportista":"Emma Seba","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-14da69d0a5d23ea64eb98767', 'Luciana Ortiz',
    '{"Nombre de la deportista":"Luciana Ortiz","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"20 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"17 de agosto de 2026","Valor pagado":"374000","Observaciones":"","Edad":"","Fecha fin del ciclo":"17 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5b8a1afbb9b4d14a3e544aba', 'Yara Sofia Hernandez',
    '{"Nombre de la deportista":"Yara Sofia Hernandez","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"2 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de marzo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"30 de marzo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ae18b4f53e1e4d0dfbfe407e', 'Daniela Chacon',
    '{"Nombre de la deportista":"Daniela Chacon ","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"27 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"25 de mayo de 2026","Valor pagado":"374000","Observaciones":"","Edad":"","Fecha fin del ciclo":"25 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2ff0ddd0fb128df72645bb6d', 'Violeta Diaz',
    '{"Nombre de la deportista":"Violeta Diaz ","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"26 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de junio de 2026","Valor pagado":"178000","Observaciones":"","Edad":"","Fecha fin del ciclo":"23 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6c5388f4a0dafdbc2048cdb2', 'Martina Garzon',
    '{"Nombre de la deportista":"Martina Garzon","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"23 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"21 de julio de 2026","Valor pagado":"275000","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c972e1cae2967ef763a11649', 'Renata Loaiza',
    '{"Nombre de la deportista":"Renata Loaiza","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"24 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-11ce9b23876f3b3fa338f428', 'Sofia Reynoso',
    '{"Nombre de la deportista":"Sofia Reynoso","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"25 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"23 de julio de 2026","Valor pagado":"338000","Observaciones":"","Edad":"","Fecha fin del ciclo":"23 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c29b3934f0988d11240e5ea4', 'Fatima Hinestrosa',
    '{"Nombre de la deportista":"Fatima Hinestrosa","Programa":"Regular","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"24 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de julio de 2026","Valor pagado":"178000","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-01514db7b8ab2ddc25f57a9d', 'Bella Raigoso',
    '{"Nombre de la deportista":"Bella Raigoso","Programa":"Minis","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"22 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"19 de agosto de 2026","Valor pagado":"275000","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3dbf51b9774af0233f3baa2c', 'Renata Ricaurte',
    '{"Nombre de la deportista":"Renata Ricaurte","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"24 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-53b48e1fac195c5b41a21a14', 'Gabriela Valencia',
    '{"Nombre de la deportista":"Gabriela Valencia","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"4 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-28c51ad0cfd787544ca1d94c', 'Alicia Arango',
    '{"Nombre de la deportista":"Alicia Arango","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"22 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"20 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-68b0ad3addf5805c3b525ba6', 'Ma Paula Coral',
    '{"Nombre de la deportista":"Ma Paula Coral","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2adf5f0de69c280a57f830e5', 'Isabella Coral',
    '{"Nombre de la deportista":"Isabella Coral","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-18f848931d401efe50c09bf5', 'Mia Rodriguez',
    '{"Nombre de la deportista":"Mia Rodriguez","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"29 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de julio de 2026","Valor pagado":"374000","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5cece2589c46731dc7d28a90', 'Luciana Contento',
    '{"Nombre de la deportista":"Luciana Contento","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"23 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"20 de agosto de 2026","Valor pagado":"227","Observaciones":"","Edad":"","Fecha fin del ciclo":"20 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3bfe68427cc1cdaa8fff4bc9', 'Oriana Sandoval',
    '{"Nombre de la deportista":"Oriana Sandoval","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bdba3a64f42b87382a5f1ac5', 'Mia Velosa',
    '{"Nombre de la deportista":"Mia Velosa","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"1 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b5db86f1c9a639d013abf049', 'Sara Diaz',
    '{"Nombre de la deportista":"Sara Diaz","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"30 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de junio de 2026","Valor pagado":"","Observaciones":"incapacitada","Edad":"","Fecha fin del ciclo":"27 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-16b31db833a2cd0e581464f7', 'Ma Antonia Tobon',
    '{"Nombre de la deportista":"Ma Antonia Tobon","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"27 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"24 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e9dc59bbe613f488d9c94d5c', 'Luciana Vallejo Vargas',
    '{"Nombre de la deportista":"Luciana Vallejo Vargas","Programa":"Regular","Nivel":"NIVEL 3","Estado":"PAUSADO","Inicio ciclo":"4 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a23ca8f4efa3aa48349df2e0', 'Luciana Campuzano',
    '{"Nombre de la deportista":"Luciana Campuzano","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"23 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"21 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8a37294dc07471e3aa5c9d12', 'Sarah Ospina Velasquez',
    '{"Nombre de la deportista":"Sarah Ospina Velasquez","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"24 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e5d162afcbe039258989f7b6', 'Isabella Ospina Velasquez',
    '{"Nombre de la deportista":"Isabella Ospina Velasquez","Programa":"Intensivo","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"24 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-58114e8245553de3d31a7efe', 'Gabriela Montenegro Borja',
    '{"Nombre de la deportista":"Gabriela Montenegro Borja","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"227000","Observaciones":"","Edad":"11","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":"06/19/2015"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a87382a4fe4d0e294b7ccecb', 'Camila Velasquez',
    '{"Nombre de la deportista":"Camila Velasquez","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-561f79c6ebf9e10f6e185aee', 'Sophia Aristizabal',
    '{"Nombre de la deportista":"Sophia Aristizabal","Programa":"Minis","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"6","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":"07/23/2020"}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a0b451e2e14af4b9a13914f4', 'Thiana Pineda',
    '{"Nombre de la deportista":"Thiana Pineda","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"11 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"8 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-739509b4df3fc7f67f105a97', 'Julieta Naranjo',
    '{"Nombre de la deportista":"Julieta Naranjo","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"enferma ","Edad":"","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-06c494a974e0a8c66be63aae', 'Belen Cardona',
    '{"Nombre de la deportista":"Belen Cardona","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5df2b86bd03191aa4d2d3d19', 'Antonella Montoya',
    '{"Nombre de la deportista":"Antonella Montoya","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"15 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fa6280a3ff87d93490123301', 'Vaiolett Trujillo',
    '{"Nombre de la deportista":"Vaiolett Trujillo","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"6 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-016520e32c9440e0885cc0f7', 'Francesca Fillette',
    '{"Nombre de la deportista":"Francesca Fillette","Programa":"Regular","Nivel":"PRENIVEL","Estado":"RETIRADO","Inicio ciclo":"4 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6aca2378c9a737763c62b697', 'Martina Botero',
    '{"Nombre de la deportista":"Martina Botero","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"9 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7c168beeca7ea0f8482d1996', 'Colette Botero',
    '{"Nombre de la deportista":"Colette Botero","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"9 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-cb302d46b6d739b4ee514efb', 'Luciana Llanos',
    '{"Nombre de la deportista":"Luciana Llanos","Programa":"Regular","Nivel":"NIVEL 1","Estado":"PAUSADO","Inicio ciclo":"6 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4bc77c39d2ff936fb4f80398', 'Isabella Toro',
    '{"Nombre de la deportista":"Isabella Toro","Programa":"Minis","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"8 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-494ba769da8aa7085485ae9c', 'Maia Toro',
    '{"Nombre de la deportista":"Maia Toro","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"8 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de mayo de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de mayo de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-71e7ffea5bb60dd9304b7131', 'Celeste Argoty',
    '{"Nombre de la deportista":"Celeste Argoty","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"4 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ff426faa415711b54dcd68da', 'Arianna Trejos',
    '{"Nombre de la deportista":"Arianna Trejos","Programa":"Regular","Nivel":"NIVEL 4","Estado":"PAUSADO","Inicio ciclo":"25 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de abril de 2026","Valor pagado":"374","Observaciones":"cirugia oreja","Edad":"","Fecha fin del ciclo":"22 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8a01b895e13f1feb0e3e727b', 'Renata Gutierrez',
    '{"Nombre de la deportista":"Renata Gutierrez","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"9 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c7c969c86cdf9adc39b37a2b', 'Emilia Medina',
    '{"Nombre de la deportista":"Emilia Medina","Programa":"Regular","Nivel":"NIVEL 1","Estado":"RETIRADO","Inicio ciclo":"9 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b431c68b70ba491fcaf44efc', 'Antonella Hernandez',
    '{"Nombre de la deportista":"Antonella Hernandez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"4 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de agosto de 2026","Valor pagado":"227000","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-13bd7cb9a7c66564e9adbc65', 'Julieta Villota',
    '{"Nombre de la deportista":"Julieta Villota","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"16 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-34f3b0c10bba858ac4ffa7f4', 'Luciana Andrade',
    '{"Nombre de la deportista":"Luciana Andrade","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"8 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-de8b8b204fa2f60ce2b7cacf', 'Abigail Perea',
    '{"Nombre de la deportista":"Abigail Perea","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"9 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"7 de julio de 2026","Valor pagado":"178","Observaciones":"","Edad":"","Fecha fin del ciclo":"7 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-dd34408df977431e41b54e3d', 'Martina Cortes',
    '{"Nombre de la deportista":"Martina Cortes","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"7 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"4 de agosto de 2026","Valor pagado":"227","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8b3c316bf3519fc673bb1b7a', 'Antonella Trujillo',
    '{"Nombre de la deportista":"Antonella Trujillo","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"8 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"5 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3f8a137095b3d1197627edfe', 'Celeste Collazos',
    '{"Nombre de la deportista":"Celeste Collazos","Programa":"Minis","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"8 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"5 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-450747693bdc9004b3553979', 'Sophia Siple',
    '{"Nombre de la deportista":"Sophia Siple","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"6 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"3 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a55249ab10d4d60bf30b8c98', 'Sofia Moscoso',
    '{"Nombre de la deportista":"Sofia Moscoso","Programa":"Minis","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"12 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"9 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"9 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-2d194702e00197c1d6d831c6', 'Isabella Vanegas',
    '{"Nombre de la deportista":"Isabella Vanegas","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"12 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"10 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"10 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-03e535a2b35100e8c5e01e8e', 'Antonia Ortiz',
    '{"Nombre de la deportista":"Antonia Ortiz","Programa":"Ocasional","Nivel":"TELAS","Estado":"RETIRADO","Inicio ciclo":"15 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"12 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"12 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d8b3873793bb97e3311860cd', 'Luciana Londoño',
    '{"Nombre de la deportista":"Luciana Londoño","Programa":"Minis","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"16 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-211a192c61f0fe03177851ef', 'Salma Londoño',
    '{"Nombre de la deportista":"Salma Londoño","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"16 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-bc43ee0c97558508424f38a1', 'Isabella Llamas',
    '{"Nombre de la deportista":"Isabella Llamas","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"11 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"8 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-572c53679183fd01675c7201', 'Victoria Argoty',
    '{"Nombre de la deportista":"Victoria Argoty","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"4 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de junio de 2026","Valor pagado":"387000","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9b913e3425445d7c64852758', 'Renata Montilla',
    '{"Nombre de la deportista":"Renata Montilla","Programa":"Regular","Nivel":"NIVEL 2","Estado":"PAUSADO","Inicio ciclo":"25 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de abril de 2026","Valor pagado":"","Observaciones":"LESION PIE","Edad":"","Fecha fin del ciclo":"22 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f80c2f80611f2803d762a542', 'Montserrat Dranguet',
    '{"Nombre de la deportista":"Montserrat Dranguet","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"275000","Observaciones":"","Edad":"","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e853db8d2b0864f20757c2c4', 'Martina Serra',
    '{"Nombre de la deportista":"Martina Serra","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"17 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6cf22cba18cd4bb591463b7a', 'Aithana Caicedo',
    '{"Nombre de la deportista":"Aithana Caicedo","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"18 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"16 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"16 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c63d5529e88099f28998843f', 'Milagros Gomez',
    '{"Nombre de la deportista":"Milagros Gomez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"RETIRADO","Inicio ciclo":"27 de marzo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de abril de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"24 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4b15649dc3943d424faa688d', 'Ebba Mosquera',
    '{"Nombre de la deportista":"Ebba Mosquera","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"22 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"19 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f4316759747b52862f293e14', 'Luciana Aristizabal',
    '{"Nombre de la deportista":"Luciana Aristizabal","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"2 de abril de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de abril de 2026","Valor pagado":"227000","Observaciones":"","Edad":"","Fecha fin del ciclo":"30 de abril de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b1a7b15e088f8bdfbe67d03d', 'Luciana Villamarin',
    '{"Nombre de la deportista":"Luciana Villamarin","Programa":"Regular","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-28fb324f3258bf4d3a37f4a5', 'Ariana Velasco',
    '{"Nombre de la deportista":"Ariana Velasco","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"4 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-184eed1d9388d6b8daa52d20', 'Luciana Pantoja',
    '{"Nombre de la deportista":"Luciana Pantoja","Programa":"Ocasional","Nivel":"NIVEL 1","Estado":"ACTIVO","Inicio ciclo":"29 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c6adc33ab17d13480b4b2583', 'Amy Olano',
    '{"Nombre de la deportista":"Amy Olano","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"27 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"24 de agosto de 2026","Valor pagado":"338000","Observaciones":"","Edad":"","Fecha fin del ciclo":"24 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-82a028209436569c96428942', 'Martina Serna',
    '{"Nombre de la deportista":"Martina Serna","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"29 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"26 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"26 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-3ccfc1966907c2c95f17b4d4', 'Milagros Gil',
    '{"Nombre de la deportista":"Milagros Gil","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"4 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de julio de 2026","Valor pagado":"178000","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4c3d5ce3165476cc91c7816d', 'Juana Otero',
    '{"Nombre de la deportista":"Juana Otero","Programa":"Regular","Nivel":"TELAS","Estado":"RETIRADO","Inicio ciclo":"15 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"12 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"12 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6e795912f3e0a705ce51642d', 'Martina Vergara',
    '{"Nombre de la deportista":"Martina Vergara","Programa":"Regular","Nivel":"TELAS","Estado":"RETIRADO","Inicio ciclo":"5 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-892060be4ce5dfb7bfc239cd', 'Ma Antonia Vergara',
    '{"Nombre de la deportista":"Ma Antonia Vergara","Programa":"Regular","Nivel":"TELAS","Estado":"RETIRADO","Inicio ciclo":"5 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f1bd808f8a6c3ed82dc53b33', 'Montserrat Gonzalez',
    '{"Nombre de la deportista":"Montserrat Gonzalez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"PAUSADO","Inicio ciclo":"4 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"2 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a587fe1af7bef13105ec6295', 'Lucia Villamil',
    '{"Nombre de la deportista":"Lucia Villamil","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"31 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"28 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"28 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c9bff6f973637fcd9478eaa3', 'Summer Rain',
    '{"Nombre de la deportista":"Summer Rain","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"5 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"2 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a5731ac8aa537e7c45d9c735', 'Samantha Santacruz',
    '{"Nombre de la deportista":"Samantha Santacruz","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"7 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"4 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9bf9ae641f5e8e3e0846741d', 'Ma Antonia Hernandez',
    '{"Nombre de la deportista":"Ma Antonia Hernandez","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"13 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"11 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-23786f64021f5a6e60454439', 'Alice Torres',
    '{"Nombre de la deportista":"Alice Torres","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d65f9172290479457b9c8a70', 'Joe De La Pava',
    '{"Nombre de la deportista":"Joe De La Pava","Programa":"Regular","Nivel":"TELAS","Estado":"RETIRADO","Inicio ciclo":"22 de mayo de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"19 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f13161a19ce68d0ad440bb36', 'Luciana Palacios',
    '{"Nombre de la deportista":"Luciana Palacios","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"21 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"18 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"18 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7db3301779395589eb08ad7f', 'Manuela Jordan',
    '{"Nombre de la deportista":"Manuela Jordan","Programa":"Regular","Nivel":"PRENIVEL","Estado":"PAUSADO","Inicio ciclo":"1 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de junio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de junio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7c9488a35e2de87d071c5faf', 'Sara Linares',
    '{"Nombre de la deportista":"Sara Linares","Programa":"Regular","Nivel":"NIVEL 3","Estado":"ACTIVO","Inicio ciclo":"6 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-68093cf759f59158364f6848', 'Alejandra Cardona',
    '{"Nombre de la deportista":"Alejandra Cardona","Programa":"Regular","Nivel":"NIVEL 2","Estado":"ACTIVO","Inicio ciclo":"30 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"27 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c6a6b53854446c4f3eb2a62e', 'Helena Sanchez',
    '{"Nombre de la deportista":"Helena Sanchez","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8369cc3f8998ec3ab98c3a5a', 'Valeria Triana',
    '{"Nombre de la deportista":"Valeria Triana","Programa":"Regular","Nivel":"PRENIVEL","Estado":"ACTIVO","Inicio ciclo":"12 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"9 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"9 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-51d2f3e541834af85536f164', 'Violeta Kiwe',
    '{"Nombre de la deportista":"Violeta Kiwe","Programa":"Intensivo","Nivel":"NIVEL 6","Estado":"ACTIVO","Inicio ciclo":"5 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"2 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-55e643b7be630e56bd535049', 'Alma Russi',
    '{"Nombre de la deportista":"Alma Russi","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"22 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"19 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a5cb17c6ff4b328a2f7e861b', 'Ma Antonia Nieto',
    '{"Nombre de la deportista":"Ma Antonia Nieto","Programa":"Minis","Nivel":"CIRCUITO","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-05dd012325daf420c219c3fb', 'Jhia Martinez',
    '{"Nombre de la deportista":"Jhia Martinez","Programa":"Regular","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"18 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"16 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"16 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1dfb799e73fae9ec32b0d7b3', 'Luciana Amaya',
    '{"Nombre de la deportista":"Luciana Amaya","Programa":"Regular","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"1 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f8d253ed74f0312fb41582ef', 'Esmeralda Barrera',
    '{"Nombre de la deportista":"Esmeralda Barrera","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"29 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"27 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c22e97aefafcb7a774da7996', 'Zoe Ocampo',
    '{"Nombre de la deportista":"Zoe Ocampo","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"4 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-8961b02539da4899efa02de4', 'Aleyna Rosa',
    '{"Nombre de la deportista":"Aleyna Rosa","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"4 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1fbbee7c02a25a9b971a3256', 'Ma Alejandra Raffo',
    '{"Nombre de la deportista":"Ma Alejandra Raffo","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"9 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"6 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"6 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f2af5d9f1dbe5c49b7cbd35b', 'Julieta Velasco',
    '{"Nombre de la deportista":"Julieta Velasco","Programa":"","Nivel":"","Estado":"PAUSADO","Inicio ciclo":"11 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"9 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"9 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a96bb2f2e3618f41f7e6dd72', 'Ma Paulina Noreña',
    '{"Nombre de la deportista":"Ma Paulina Noreña","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"18 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-730eb57fefb00b17626ca10e', 'Ashley Valderrama',
    '{"Nombre de la deportista":"Ashley Valderrama","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"6 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"3 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-b922ed1e622d80358e26d36b', 'Violeta Garcia',
    '{"Nombre de la deportista":"Violeta Garcia","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a7366e9b5bd8683616247c7c', 'Victoria Duque',
    '{"Nombre de la deportista":"Victoria Duque","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"1 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"29 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-09e40e6e3f90f71938cd90a1', 'Daviana Caicedo',
    '{"Nombre de la deportista":"Daviana Caicedo","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"23 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"21 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"21 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6b931ab3132d6011a366b34c', 'Mariana Franco',
    '{"Nombre de la deportista":"Mariana Franco","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"11 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"8 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"8 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6b25a4a98b2dec4c2e8b531e', 'Sara Hernandez',
    '{"Nombre de la deportista":"Sara Hernandez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"28 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"25 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"25 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1774799ed05f5a8eb5e989cd', 'Martina Laguna',
    '{"Nombre de la deportista":"Martina Laguna","Programa":"","Nivel":"","Estado":"PAUSADO","Inicio ciclo":"26 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"24 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"24 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-00e88404a1f2dbcc1ed49c77', 'Amaia Montaño',
    '{"Nombre de la deportista":"Amaia Montaño","Programa":"","Nivel":"","Estado":"PAUSADO","Inicio ciclo":"24 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"22 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f5c86ec72dc1c7b3644a5507', 'Elena Gamboa',
    '{"Nombre de la deportista":"Elena Gamboa","Programa":"","Nivel":"","Estado":"PAUSADO","Inicio ciclo":"30 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"28 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c03f93ec3372cc77fa52b31e', 'Hillary Núñez',
    '{"Nombre de la deportista":"Hillary Núñez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9a7d9f4aa6916a0922b3826a', 'Mariana Jaramillo',
    '{"Nombre de la deportista":"Mariana Jaramillo","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"4 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5e297949c9a677d69e0f97af', 'Karla Velez',
    '{"Nombre de la deportista":"Karla Velez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"6 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"3 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-6c7057cc9d4a829d80c1a38d', 'Montserrat Salamanca',
    '{"Nombre de la deportista":"Montserrat Salamanca","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fbd4a1f514520ef2e9e2e76f', 'Mariana Palacios',
    '{"Nombre de la deportista":"Mariana Palacios","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"14 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"11 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-a921bf4daa6dff48bfc81f9e', 'Alena Arboleda',
    '{"Nombre de la deportista":"Alena Arboleda","Programa":"","Nivel":"","Estado":"PAUSADO","Inicio ciclo":"30 de junio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"28 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"28 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-9b4a13ad8c3755407d5e9282', 'Mia Coral',
    '{"Nombre de la deportista":"Mia Coral","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-d165b224edeb4c8badb1df7b', 'Fatima Gomez',
    '{"Nombre de la deportista":"Fatima Gomez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"2 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"30 de julio de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"30 de julio de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-e19ae993eaa73de7ab5f8384', 'Salome Gustin',
    '{"Nombre de la deportista":"Salome Gustin","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-5967b293e84784a3538a2f55', 'Alma Ayomide',
    '{"Nombre de la deportista":"Alma Ayomide","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"16 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"13 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"13 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4d6553e0542f75205011b111', 'Camila Davila',
    '{"Nombre de la deportista":"Camila Davila","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"4 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"1 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"1 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-42819dd3cd97438413d46f6a', 'Julieta Hernandez',
    '{"Nombre de la deportista":"Julieta Hernandez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"20 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"17 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"17 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-1222767774264ddb8e90ff1b', 'Salome Rios',
    '{"Nombre de la deportista":"Salome Rios","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"20 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"17 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"17 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-c72da0eed2884702247abf45', 'Renata Casas',
    '{"Nombre de la deportista":"Renata Casas","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"25 de julio de 2026","Estado del ciclo":"PENDIENTE 🟡","Fecha de pago":"","Próximo ciclo":"22 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"22 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f059a77aec3a12a13369ed14', 'Alicia Lopez',
    '{"Nombre de la deportista":"Alicia Lopez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"18 de julio de 2026","Estado del ciclo":"VENCIDO 🔴","Fecha de pago":"","Próximo ciclo":"15 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"15 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-0568f94a758f5c2874d318b2', 'Sofia Diaz',
    '{"Nombre de la deportista":"Sofia Diaz","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"30 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"27 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-83c76d660f7108bedf8281d5', 'Luisa Ma Velasco',
    '{"Nombre de la deportista":"Luisa Ma Velasco","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"1 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"29 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"29 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ba0f733ff2fb0c246a434cbc', 'Victoria de La Cruz',
    '{"Nombre de la deportista":"Victoria de La Cruz","Programa":"Ocasional","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"30 de julio de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"27 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"27 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-932be566b490c985b70fdec1', 'Ma Antonella Arciniegas',
    '{"Nombre de la deportista":"Ma Antonella Arciniegas","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"3 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"31 de agosto de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"31 de agosto de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-88ed6ff809da027635ab19c4', 'Emma Salazar',
    '{"Nombre de la deportista":"Emma Salazar","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"5 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"2 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"2 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-634b230fc3fa44658ad9dbce', 'Ma Isabel Serna',
    '{"Nombre de la deportista":"Ma Isabel Serna","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-f0b08607645c7d59c1c1d76b', 'Eva Molano',
    '{"Nombre de la deportista":"Eva Molano","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"7 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"4 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"4 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-67d505dab11ea4f2a95ee5e8', 'Sophia Torres',
    '{"Nombre de la deportista":"Sophia Torres","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"8 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"5 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"5 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-53731ca0b28f6c28180e7bbf', 'Emma Lopez',
    '{"Nombre de la deportista":"Emma Lopez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"","Estado del ciclo":"","Fecha de pago":"","Próximo ciclo":"","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-95eeaf9c6db47b45f1453bac', 'Aura Victoria Aristizabal',
    '{"Nombre de la deportista":"Aura Victoria Aristizabal","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"13 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"10 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"10 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-fbce91d85b039320521abfec', 'Cristopher Valderrama',
    '{"Nombre de la deportista":"Cristopher Valderrama","Programa":"Ocasional","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"6 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"3 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"3 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-981e0ad48345bdd5605a1c2a', 'Violeta Sarria',
    '{"Nombre de la deportista":"Violeta Sarria ","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"11 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"8 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"8 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-4d31f89c4b7d04adf9a0f32b', 'Emilia Florez',
    '{"Nombre de la deportista":"Emilia Florez","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"14 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"11 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"11 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-06d84e85f0f7dc6a435a3ea4', 'Gabriela Valencia',
    '{"Nombre de la deportista":"Gabriela Valencia","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"15 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"12 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"12 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-ce312ca856d1040ec6a0c2ad', 'Valentina Orozco',
    '{"Nombre de la deportista":"Valentina Orozco","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"22 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"19 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"19 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  ),
(
    'cycle', 'notion-cycle-archive-7870e5262fbeec4f3f18da2e', 'Lucia Grisales',
    '{"Nombre de la deportista":"Lucia Grisales","Programa":"","Nivel":"","Estado":"ACTIVO","Inicio ciclo":"20 de agosto de 2026","Estado del ciclo":"AL DÍA 🟢","Fecha de pago":"","Próximo ciclo":"17 de septiembre de 2026","Valor pagado":"","Observaciones":"","Edad":"","Fecha fin del ciclo":"17 de septiembre de 2026","Fecha de nacimiento":""}'::jsonb
  )
on conflict (external_id) do nothing;

create temporary table notion_financial_stage (
  external_id text primary key,
  gymnast_name text not null,
  concept text not null,
  category text not null,
  issued_on date not null,
  due_on date not null,
  amount_cents bigint not null,
  paid_cents bigint not null,
  notes text
) on commit drop;

insert into notion_financial_stage (
  external_id, gymnast_name, concept, category, issued_on, due_on,
  amount_cents, paid_cents, notes
) values
(
    'notion-movement-9dbfacb98716ad76f48c9063', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-04-17'::date, '2026-04-17'::date,
    10800000::bigint, 10800000::bigint, 'Profesora: Fabi · 1,5 horas · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-565525d58d1d3822daebd7a2', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-04-16'::date, '2026-04-16'::date,
    12300000::bigint, 12300000::bigint, 'Profesora: William · 1,5 horas · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0ef9997a2ae354788a0cbc29', 'Emmanuela Palacios', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a02e401bbfb5f7506aea8c0d', 'Emmanuela Palacios', 'Clase extra', 'extra_class',
    '2026-03-31'::date, '2026-03-31'::date,
    7500000::bigint, 7500000::bigint, 'CHEQUEO · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-427540a568cf5a41dbe52094', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-03-30'::date, '2026-03-30'::date,
    7200000::bigint, 7200000::bigint, 'Profesora: Kathe · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6873fd6447c9b68a418c4ca8', 'Emmanuela Palacios', 'Clase extra', 'extra_class',
    '2026-04-24'::date, '2026-04-24'::date,
    3600000::bigint, 3600000::bigint, 'NO ASISTIO · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a538948ed247e4019e4b25a7', 'Emmanuela Palacios', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6a3a6954ce9d021e96658554', 'Emmanuela Palacios', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d61a478ab089d5bde5078661', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-28'::date, '2026-05-28'::date,
    8200000::bigint, 6400000::bigint, 'Profesora: William · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-313b409c410c19732e02d3ff', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    8200000::bigint, 8200000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e334b2377200835f6a6045b5', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-27'::date, '2026-05-27'::date,
    7200000::bigint, 7200000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b49fa6a12d6257cd52cc0c54', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7200000::bigint, 7200000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-47b2851fe6bb458505071858', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-14'::date, '2026-05-14'::date,
    8200000::bigint, 8200000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4d6551e757497b5c649d05d7', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-13'::date, '2026-05-13'::date,
    7200000::bigint, 7200000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bb6308fad8e57bd07dfe3613', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-07'::date, '2026-05-07'::date,
    8200000::bigint, 8200000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f1fbfdda5c2c8df8c83de095', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-05-06'::date, '2026-05-06'::date,
    7200000::bigint, 7200000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-da4d2bbaca8928b39748839c', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-04-30'::date, '2026-04-30'::date,
    8200000::bigint, 8200000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-53e73b43d100ea1ae384dc3b', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-03'::date, '2026-06-03'::date,
    7200000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-72a5494b4676cf7cc65eb98c', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-04'::date, '2026-06-04'::date,
    8200000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-17f462522e9c8f72fbecc595', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-10'::date, '2026-06-10'::date,
    7200000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-91e935f13e272eead7a5d49e', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-11'::date, '2026-06-11'::date,
    8200000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c5faa87eba20e02eca033044', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-17'::date, '2026-06-17'::date,
    7200000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-b49c7afbc5e7301b7f9b893f', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-18'::date, '2026-06-18'::date,
    4100000::bigint, 0::bigint, 'Profesora: William · no asistio · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d1c14809dc1c8d47f6926f09', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    7200000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-fa08a9949ed1a8a4d565b168', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-06-26'::date, '2026-06-26'::date,
    8200000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f554c21902773e228cba55d8', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-03'::date, '2026-07-03'::date,
    14400000::bigint, 0::bigint, 'Profesora: Fabi · 2h · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-24d5b0ce37f676b92b25a892', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-08'::date, '2026-07-08'::date,
    14400000::bigint, 0::bigint, 'Profesora: Fabi · 2h · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c4a9bd83a2be0d14c4851751', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-15'::date, '2026-07-15'::date,
    10800000::bigint, 0::bigint, 'Profesora: Fabi · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-6049eca4ef04cb374687c5e0', 'Emmanuela Palacios', 'Camiseta polo', 'product',
    '2026-06-24'::date, '2026-06-24'::date,
    5500000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d208c9bf6537556835294e9f', 'Emmanuela Palacios', 'Clase extra', 'extra_class',
    '2026-06-01'::date, '2026-06-01'::date,
    35000000::bigint, 0::bigint, 'CARTAGENA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-b1b665badc77bb29614e8685', 'Emmanuela Palacios', 'VERANO', 'competition',
    '2026-06-22'::date, '2026-06-22'::date,
    32000000::bigint, 0::bigint, '4 clases Emma y Rafa · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-8a27adafecf6a0414f766ae0', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-01'::date, '2026-07-01'::date,
    16400000::bigint, 0::bigint, 'Profesora: William · 2 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-46af37ee4d5b4412b62e61a5', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-02'::date, '2026-07-02'::date,
    16400000::bigint, 0::bigint, 'Profesora: William · 2 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-ec5ab956f2dbbd2b8d79ffa4', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-09'::date, '2026-07-09'::date,
    12300000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-3d16a4f21b0a1fa938f327b5', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-17'::date, '2026-07-17'::date,
    12300000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-5589348b0b4f46afde5cdbfb', 'Emmanuela Palacios', 'Personalizado', 'private_class',
    '2026-07-16'::date, '2026-07-16'::date,
    12300000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-270ab1ce9778fa6cb0062e26', 'Emmanuela Palacios', 'CICLO', 'monthly_fee',
    '2026-04-30'::date, '2026-04-30'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-77d15b3e89b9af75df2a0c5f', 'Emmanuela Palacios', 'CICLO', 'monthly_fee',
    '2026-05-28'::date, '2026-05-28'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-3d518af410fba6286621d4ca', 'Emmanuela Palacios', 'CICLO', 'monthly_fee',
    '2026-06-25'::date, '2026-06-25'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d7975c984bdbb14567095559', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-04-13'::date, '2026-04-13'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Liz · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cc41057267f75620002c42ac', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-04-13'::date, '2026-04-13'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a3f4561bfa23abad1aff6b3d', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-03-30'::date, '2026-03-30'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ec95c6a52a7b8ee6b96b5d6c', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-03-16'::date, '2026-03-16'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-00b5e29414685743881532ec', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-03-09'::date, '2026-03-09'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-980bba7fe8b6e97d2e0467c6', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-03-02'::date, '2026-03-02'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d3a8e959be1761681c2a7727', 'Gabriela Uribe', 'Trusa entreno', 'product',
    '2026-02-28'::date, '2026-02-28'::date,
    20300000::bigint, 20300000::bigint, 'Profesora: trusa entreno · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-293089800f59ca3347c40213', 'Gabriela Uribe', 'Trusa gala', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a5b8f705df99f9173fca9c98', 'Gabriela Uribe', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Profesora: Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6aa15c4540ae4d96f1cabd93', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-05-30'::date, '2026-05-30'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Majo · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c1d5a67aa0086ddbcc1b0b66', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-05-29'::date, '2026-05-29'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3f1ae5d79de7bccc897cbd2f', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9810cd4f7392845160182d87', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-05-15'::date, '2026-05-15'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f0084f222b1ef7f8994022d8', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-05-08'::date, '2026-05-08'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-371f94fbb1d8ffb340854978', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f86c626100928efc3409561a', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-06-05'::date, '2026-06-05'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-36687e27443289b52ad27506', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-06-19'::date, '2026-06-19'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4349ceca52dd1c4b4fef5f62', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-06-19'::date, '2026-06-19'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-20e94bbb01da03722d2bf421', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-04'::date, '2026-07-04'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-7c579da466f2caaa272f58b9', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-10'::date, '2026-07-10'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-6f03b52be826e9f68c44389f', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-10'::date, '2026-07-10'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c7427858c30803df316847f4', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-04'::date, '2026-07-04'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-b21725b06db782e792a88d27', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-17'::date, '2026-07-17'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4b27b6054bd868084c8294e1', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-17'::date, '2026-07-17'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f27fa56a3a47989d8671c875', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-06-12'::date, '2026-06-12'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-9c28a566ff0ecc78486a379e', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-06-12'::date, '2026-06-12'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-42fc5d18d38207cf8f2a6be7', 'Gabriela Uribe', 'VERANO', 'competition',
    '2026-06-30'::date, '2026-06-30'::date,
    57400000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-65129c61dba77faea0321fd5', 'Gabriela Uribe', 'Personalizado', 'private_class',
    '2026-07-04'::date, '2026-07-04'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f3601b460243f1a9b1590014', 'Mariana Zuñiga', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8ae1a904847e55437b928bee', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-04-06'::date, '2026-04-06'::date,
    15400000::bigint, 15400000::bigint, 'Profesora: Kt · 2h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8603ad1d5fc3fa2e5a8157fa', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-27'::date, '2026-03-27'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-25db099f22456626d02c2043', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-26'::date, '2026-03-26'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7c35504bd8e82b907a82f9a5', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-20'::date, '2026-03-20'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e09a01381b8f985303dd44ee', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-19'::date, '2026-03-19'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9183eddc24933a17e8d6a3c8', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-12'::date, '2026-03-12'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-dc87c569b00d398395b4531a', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-03-06'::date, '2026-03-06'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c4f03e11a348541d9cc3e81f', 'Mariana Zuñiga', 'Clase extra', 'extra_class',
    '2026-04-10'::date, '2026-04-10'::date,
    39500000::bigint, 39500000::bigint, 'Armenia · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ef381a156fe3c5e1e857d19e', 'Mariana Zuñiga', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0e02aee1517eff7b884307a2', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-aa0fa9c1c941f82a90fbaa07', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-681613ff74b0831f6f3cc68c', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-05-05'::date, '2026-05-05'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2522dbc06b7ada3bff530f1c', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-05-04'::date, '2026-05-04'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ccee06202df11780b25125e2', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-05-01'::date, '2026-05-01'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4615586b869ac1598b68b6f0', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-04-28'::date, '2026-04-28'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-38c8cabee7af2198b278967b', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0aa521d6926cf300be60856e', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-06-02'::date, '2026-06-02'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-53e3f305b65e5c80841ee4e8', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-06-08'::date, '2026-06-08'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ae9a066c3293e614530c8fec', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a0b908d70f5765385a286ed4', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Diana · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fc29f430f900a78c8f768f54', 'Mariana Zuñiga', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d56718e20a481e00d319be62', 'Mariana Zuñiga', 'CICLO', 'monthly_fee',
    '2026-04-30'::date, '2026-04-30'::date,
    66000000::bigint, 66000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4a9aa4ee43a42fa910edc4c1', 'Mariana Zuñiga', 'CICLO', 'monthly_fee',
    '2026-05-28'::date, '2026-05-28'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-2dc476784301da5f3e50dd5e', 'Mariana Zuñiga', 'CICLO', 'monthly_fee',
    '2026-06-25'::date, '2026-06-25'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4c0f2179695d6e732218511e', 'Mariana Zuñiga', 'Clase extra', 'extra_class',
    '2026-06-01'::date, '2026-06-01'::date,
    35000000::bigint, 35000000::bigint, 'Cartagena · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9f4479a60ac013687cbe1a3a', 'Mariana Zuñiga', 'Otro', 'other',
    '2026-07-01'::date, '2026-07-01'::date,
    58100000::bigint, 0::bigint, 'VERANO · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d3bc71a1bd611c6de11a6c6e', 'Antonia Garzon', 'Personalizado', 'private_class',
    '2026-03-26'::date, '2026-03-26'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e24c7e69ab0860015d505139', 'Antonia Garzon', 'Personalizado', 'private_class',
    '2026-03-25'::date, '2026-03-25'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-53327be9484f0b2706004505', 'Antonia Garzon', 'Camiseta polo', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    5500000::bigint, 5500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8971bfdb71aa29768bc0fd9a', 'Antonia Garzon', 'Personalizado', 'private_class',
    '2026-06-13'::date, '2026-06-13'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cadb6fd619f201830539cea4', 'Antonia Naranjo', 'Personalizado', 'private_class',
    '2026-03-25'::date, '2026-03-25'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2b8ee9bac7cf240775c82df1', 'Antonia Naranjo', 'Chaqueta y legging', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-64132f9bd1ba6c6ecbaa4aa9', 'Antonia Naranjo', 'VERANO', 'competition',
    '2026-07-31'::date, '2026-07-31'::date,
    18200000::bigint, 0::bigint, 'CURSO VERANO · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-6bcb28a11eadb98ce92755a6', 'Salome Escobar', 'Personalizado', 'private_class',
    '2026-04-01'::date, '2026-04-01'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-efbf7066be61a855a926eb5d', 'Salome Escobar', 'Personalizado', 'private_class',
    '2026-03-25'::date, '2026-03-25'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-74aa1ac953ce9f63e96c66ca', 'Salome Escobar', 'Personalizado', 'private_class',
    '2026-04-08'::date, '2026-04-08'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7223661b7493c9353a860b12', 'Salome Escobar', 'Otro', 'other',
    '2026-07-16'::date, '2026-07-16'::date,
    53400000::bigint, 0::bigint, 'IBAGUE INSCRIPCION · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-b743900d4fcb4f496a2adab7', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-04-15'::date, '2026-04-15'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f92f1ca6d21c64d72cdd0957', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0689754f56135044a7a817a0', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-04-06'::date, '2026-04-06'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d5f5a33f1a13320aa98ca7eb', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-04-01'::date, '2026-04-01'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-84c9aa30ade1317fba78ea4a', 'Luxiana Santamaria', 'Trusa entreno', 'product',
    '2026-02-26'::date, '2026-02-26'::date,
    10300000::bigint, 10300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c9aa01ed1d6f702902e446b0', 'Luxiana Santamaria', 'Trusa gala', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3e36469661f8417b7020842d', 'Luxiana Santamaria', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ceb7badafb24e3953f260597', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7bfe5d2c504f924c5c11bd42', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-903e49b60096ff0e3c6a71f0', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5beccd54b121e12fe8dd81a7', 'Luxiana Santamaria', 'Chaqueta y legging', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    29500000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-545deb76007c237e3465cebf', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-17'::date, '2026-06-17'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b0dd2d512cc1aa3f3d52efcc', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-18'::date, '2026-06-18'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bbbee1fa641f9ef8f624904f', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1e2549be36323b813ac27c45', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3131c7d5d94125fca28f0d71', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-22164978895a65aae6d5d04a', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-72b4919b8d7327c96ba3359d', 'Luxiana Santamaria', 'Personalizado', 'private_class',
    '2026-06-25'::date, '2026-06-25'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e085cd95c8d54675b17d9e03', 'Emma Vega', 'Personalizado', 'private_class',
    '2026-04-02'::date, '2026-04-02'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e70d575dd75b337b1817927c', 'Celeste Giraldo', 'Personalizado', 'private_class',
    '2026-04-08'::date, '2026-04-08'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-97e7bedd8a79d613e70f0be7', 'Celeste Giraldo', 'Personalizado', 'private_class',
    '2026-04-06'::date, '2026-04-06'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Kt · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-faffb9377e92c7c9dbe2d329', 'Celeste Giraldo', 'Personalizado', 'private_class',
    '2026-04-02'::date, '2026-04-02'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8f73e21ce3b0da7f4f4c258a', 'Celeste Giraldo', 'Chaqueta y legging', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-40fddc646d124d245e1f4822', 'Victoria Ossa', 'Chaqueta y legging', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5dec1ee45970d5abde284a46', 'Victoria Ossa', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    11550000::bigint, 0::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f51da7d7c174a497755db56e', 'Victoria Ossa', 'Personalizado', 'private_class',
    '2026-04-04'::date, '2026-04-04'::date,
    8800000::bigint, 3200000::bigint, 'Profesora: William · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-0f7fbfa6c40378e9088bd884', 'Victoria Ossa', 'Otro', 'other',
    '2026-01-01'::date, '2026-01-01'::date,
    6800000::bigint, 6800000::bigint, 'excedente Armenia · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d8d83f6e9d7e7a6c150db87e', 'Victoria Ossa', 'Clase extra', 'extra_class',
    '2026-04-10'::date, '2026-04-10'::date,
    14400000::bigint, 14400000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1136f4a243bd424305ca03a3', 'Hannah Navia', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cb43026c65a3ae6d025fecbc', 'Hannah Navia', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ffd329d96d01c0c3a8aa501a', 'Mariana Chaves', 'Personalizado', 'private_class',
    '2026-04-09'::date, '2026-04-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-da4d0104a21287585bc77eb4', 'Mariana Chaves', 'Personalizado', 'private_class',
    '2026-04-08'::date, '2026-04-08'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ce064f67c41271ceeacc9fbb', 'Mariana Chaves', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    15400000::bigint, 15400000::bigint, 'Profesora: Fabi · 2h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b7ff5e4fef9cf2014c918e88', 'Mariana Chaves', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    18000000::bigint, 18000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-07d212b58495d0dfff88c859', 'Mariana Chaves', 'Clase extra', 'extra_class',
    '2026-06-06'::date, '2026-06-06'::date,
    35000000::bigint, 0::bigint, 'CARTAGENA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d5d08074d1b0fe03b273218f', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-04-14'::date, '2026-04-14'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4171451f46d8ccbcfdd103f2', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-87e1d9158f9ef189387af1e6', 'Sofia Montaño', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8000a24f9532e429e506a32c', 'Sofia Montaño', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c64f4a3291cd041483723260', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-639b62a1983d0a1cc50608fc', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8a4610a4a4df26074174e106', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2fe0371b65ad15b9ce994e8f', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-05-05'::date, '2026-05-05'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-62659f9dbd1a1c1085c4e311', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-04-28'::date, '2026-04-28'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5badf19e05487fd17880e684', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1b34cea66b51e69eb224326e', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-04-21'::date, '2026-04-21'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1b111da4c3d6c50463171dc7', 'Sofia Montaño', 'Camiseta', 'product',
    '2026-05-19'::date, '2026-05-19'::date,
    4500000::bigint, 4500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b15072006d0ae2800d527d4c', 'Sofia Montaño', 'Trusa entreno', 'product',
    '2026-01-01'::date, '2026-01-01'::date,
    20300000::bigint, 20300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-25935cecc0864637cc8cfb92', 'Sofia Montaño', 'Clase extra', 'extra_class',
    '2026-01-01'::date, '2026-01-01'::date,
    35000000::bigint, 35000000::bigint, 'Cartagena · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0c9457a0df0cec6614fbcfec', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-01'::date, '2026-06-01'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4192d5c17cef6bbb4113cc1f', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-02'::date, '2026-06-02'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2f0094e083878e58d3fba1f9', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-09'::date, '2026-06-09'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bf98f119100bc7120eeb0944', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bfebaa474b04724c0c7443dd', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6b049d561dee87c72b75239e', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b2e36af17df846cbf52dca10', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-06-30'::date, '2026-06-30'::date,
    13200000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-1c0162a31864421cdde02acf', 'Sofia Montaño', 'Personalizado', 'private_class',
    '2026-07-06'::date, '2026-07-06'::date,
    7700000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-3184230aefadcb7322597b06', 'Ma Celeste Cruz', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5cc4c86b16abd45f01c5cffd', 'Ma Celeste Cruz', 'Personalizado', 'private_class',
    '2026-04-08'::date, '2026-04-08'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-7ed82236888a5cb89c43d13f', 'Ma Celeste Cruz', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9317d4a9d429d6929c981402', 'Ma Celeste Cruz', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-730c66b04c49dab1971540e9', 'Ma Celeste Cruz', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4ff70a0f62914d27b929f80c', 'Ma Celeste Cruz', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c84c62f8c9a688e41b04bfa3', 'Ma Celeste Cruz', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Liz · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2d2bf741ebde8fd9abedf729', 'Ma Celeste Cruz', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-35c214120e4e9114c0fab342', 'Ma Celeste Cruz', 'Otro', 'other',
    '2026-01-01'::date, '2026-01-01'::date,
    10500000::bigint, 10500000::bigint, 'excedente inscripción ctg · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-84e78bb6096df7f2f0ffa005', 'Ma Celeste Cruz', 'Personalizado', 'private_class',
    '2026-06-19'::date, '2026-06-19'::date,
    8800000::bigint, 8000000::bigint, 'Profesora: William · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-436d7db843b68b842677f34a', 'Ma Celeste Cruz', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-fa5dbbf7e66d7370c681d941', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-04-08'::date, '2026-04-08'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5ab92c76391a909a573d8786', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-04-09'::date, '2026-04-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3e87fa900294d567313cc9f0', 'Ma Paula Coral', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-94498edf6dac8df9d7531d6e', 'Ma Paula Coral', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-12f5d4aea4660d4bbd7d001d', 'Ma Paula Coral', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2c8f2885cdc5616e31db572f', 'Ma Paula Coral', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8f18dd96ecc1d585ad41e77d', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-06-02'::date, '2026-06-02'::date,
    7700000::bigint, 0::bigint, 'Profesora: Gila · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-cecb7e5cd7c9b46de270a857', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-06-09'::date, '2026-06-09'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4e200b243423e3016211895d', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-470222be3ec3ce4dfbe1653a', 'Ma Paula Coral', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7700000::bigint, 0::bigint, 'Profesora: Majo · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-cc23089627d1698876f55d04', 'Agustina Diaz', 'Personalizado', 'private_class',
    '2026-04-09'::date, '2026-04-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Liz · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5c7cc74a5ac2de1c50d2b94e', 'Agustina Diaz', 'Clase extra', 'extra_class',
    '2026-04-10'::date, '2026-04-10'::date,
    21600000::bigint, 21600000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9a7a2718e6c8602aa313ac42', 'Luciana Orejuela', 'Personalizado', 'private_class',
    '2026-04-14'::date, '2026-04-14'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8e21cad04ac1b5b3ca5e51cc', 'Luciana Orejuela', 'Personalizado', 'private_class',
    '2026-04-10'::date, '2026-04-10'::date,
    15400000::bigint, 15400000::bigint, 'Profesora: Angie · 2h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-063bafc369e4fbb51e78d6c5', 'Luciana Orejuela', 'Chaqueta y legging', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-685e78e8f137a4ba3b06cd95', 'Luciana Orejuela', 'Personalizado', 'private_class',
    '2026-04-09'::date, '2026-04-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6de69e3fcc7c339cab19d01d', 'Luciana Orejuela', 'Personalizado', 'private_class',
    '2026-04-09'::date, '2026-04-09'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-63a3b55043d7b804fe59f45a', 'Luciana Orejuela', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0dda2f55d8b6b5abae319600', 'Luciana Orejuela', 'Personalizado', 'private_class',
    '2026-04-17'::date, '2026-04-17'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-700d5dd750f690cc1a8fe939', 'Luciana Orejuela', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    60350000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-743800f39ce62a9bf3721cdc', 'Luciana Toro', 'Personalizado', 'private_class',
    '2026-04-14'::date, '2026-04-14'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fb0e8b7214900fb73d55369e', 'Luciana Toro', 'Personalizado', 'private_class',
    '2026-04-21'::date, '2026-04-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-88554551c00094c171366943', 'Ana Sofia Gutierrez', 'Personalizado', 'private_class',
    '2026-04-14'::date, '2026-04-14'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4230debbe831602708a8d246', 'Ana Sofia Gutierrez', 'Personalizado', 'private_class',
    '2026-04-16'::date, '2026-04-16'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5aed1572e69a2fa35860ccf7', 'Ana Sofia Gutierrez', 'Personalizado', 'private_class',
    '2026-04-15'::date, '2026-04-15'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-af002d65e5b7698eba649d84', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-04-15'::date, '2026-04-15'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-32c2739dedfbb10199db3e17', 'Luciana Campuzano', 'Chequeo', 'extra_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7000000::bigint, 7000000::bigint, 'SELECTIVO · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d5b4da151650a162f6ca17fc', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-51f5a951063afe1dc5777711', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9c8b006af53d4f1b352b0b37', 'Luciana Campuzano', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-dc8a72c561cf0744da4dfce6', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cc68497b1afbed2baac51714', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3563c2e4833f419ac6eecff4', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-eb41b5e995f21dcbcba21751', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-05-18'::date, '2026-05-18'::date,
    16500000::bigint, 16500000::bigint, 'Profesora: Majo · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-30cd50cad23bf0ac59d9bd3a', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8fac82d24515fdb918015e1c', 'Luciana Campuzano', 'Trusa gala', 'product',
    '2026-04-16'::date, '2026-04-16'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-52984a7195f5a6e2a5994510', 'Luciana Campuzano', 'CICLO', 'monthly_fee',
    '2026-03-01'::date, '2026-03-01'::date,
    16500000::bigint, 16500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8328977b1cea61c2bf9bcd66', 'Luciana Campuzano', 'CICLO', 'monthly_fee',
    '2026-04-01'::date, '2026-04-01'::date,
    32500000::bigint, 32500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fd4eb0f7ef719012fcc7cd28', 'Luciana Campuzano', 'CICLO', 'monthly_fee',
    '2026-05-01'::date, '2026-05-01'::date,
    39000000::bigint, 39000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e30e2609536900a44e888ed0', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-18'::date, '2026-06-18'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5480c66d25845dc6bea7d88d', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-13'::date, '2026-06-13'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ce7d46134d6d60e11ce4025c', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-13'::date, '2026-06-13'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5df7095102790cb2c2193404', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8d9a79e77d744bcd2ca5f627', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6585087ee38d48c8bd9e8fdd', 'Luciana Campuzano', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b1f3de1888605e5998d42eac', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-05-30'::date, '2026-05-30'::date,
    7000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-502f4c3ad2de3a696ea63753', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-06-13'::date, '2026-06-13'::date,
    7000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-98125b0cb31c412f4cd0873c', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-06-15'::date, '2026-06-15'::date,
    7000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-bb964c7813c6f4b270b80c6a', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-06-19'::date, '2026-06-19'::date,
    7000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-e104bb05c413e467cce50887', 'Luciana Campuzano', 'Clase extra', 'extra_class',
    '2026-06-20'::date, '2026-06-20'::date,
    7000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-835f052d8825922f061da9f4', 'Luciana Arenas', 'Camiseta', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    4500000::bigint, 4500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-683aea7a939a459b1b31e74b', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-04-15'::date, '2026-04-15'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-debbbfad3c3f44a36c220b79', 'Luciana Arenas', 'Camiseta polo', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    5500000::bigint, 5500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-351e3f3bdc7d5ee5eae286e8', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-05-27'::date, '2026-05-27'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d42fcd8c7ba75d0b42bafe4a', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8ffbc6f28e53c13d13147c72', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-05-13'::date, '2026-05-13'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c0b785d311d52aa062d73c06', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-05-06'::date, '2026-05-06'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-da2dd2951c841527721fd2f6', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-04-29'::date, '2026-04-29'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-84f130d1f581adcc32f06f83', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5e6ca7b8391e13137e716e3d', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-04-22'::date, '2026-04-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d9339919bc59f4fac41ee42b', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-06-01'::date, '2026-06-01'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f0b8d9a668a7e2f867ef0362', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-06-03'::date, '2026-06-03'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-80a5b2b5ea4e7616da995752', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-06-17'::date, '2026-06-17'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angie · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-0c4613b08c86992e29becf98', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    11550000::bigint, 0::bigint, 'Profesora: Angie · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-18112340852dcaa4eb288fbb', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-07-15'::date, '2026-07-15'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angie · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-e9e2baf7e4d98cda34605084', 'Luciana Arenas', 'Clase extra', 'extra_class',
    '2026-05-30'::date, '2026-05-30'::date,
    35000000::bigint, 0::bigint, 'CARTAGENA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-498eca8b04e545df3dbbb35d', 'Luciana Arenas', 'Personalizado', 'private_class',
    '2026-07-06'::date, '2026-07-06'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-6de4032f44b542bfe396c0fc', 'Andrea Barreto', 'Personalizado', 'private_class',
    '2026-04-15'::date, '2026-04-15'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-416e8b7962848e5a73f66fd9', 'Andrea Barreto', 'Clase extra', 'extra_class',
    '2026-04-05'::date, '2026-04-05'::date,
    7200000::bigint, 7200000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3b16a4afb67fd16e6097640e', 'Gabriela Duque', 'Personalizado', 'private_class',
    '2026-04-16'::date, '2026-04-16'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-16b0cdd70e268bf05ae7c364', 'Gabriela Duque', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    32900000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-00536952fa71c5347c9074b2', 'Isabella Nieto', 'Personalizado', 'private_class',
    '2026-04-18'::date, '2026-04-18'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Majo · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1a5372bda997bd06196b3a85', 'Isabella Nieto', 'Trusa entreno', 'product',
    '2026-02-21'::date, '2026-02-21'::date,
    10300000::bigint, 10300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-785640fd54b043b4aaf7e17b', 'Mariangel Gomez', 'Accesorios', 'product',
    '2026-03-20'::date, '2026-03-20'::date,
    13000000::bigint, 13000000::bigint, 'guantes · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3f70d94559e198c935dc81ca', 'Mariana Londoño', 'Trusa entreno', 'product',
    '2026-02-26'::date, '2026-02-26'::date,
    20300000::bigint, 20300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-18307ffcf6c0f4e5ce3344d7', 'Mariana Londoño', 'Chequeo', 'extra_class',
    '2026-01-01'::date, '2026-01-01'::date,
    7000000::bigint, 7000000::bigint, 'chequeo · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0d95e49ce09b34b5948c6f12', 'Mariana Londoño', 'Trusa gala', 'product',
    '2026-01-01'::date, '2026-01-01'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c0c924f86a6716f1bb203e00', 'Mariana Londoño', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0fb2a731a005b5b181839cdd', 'Mariana Londoño', 'Clase extra', 'extra_class',
    '2026-01-01'::date, '2026-01-01'::date,
    29500000::bigint, 29500000::bigint, 'Profesora: Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a44bad888f3fed22d1b1f7c1', 'Mariana Londoño', 'Otro', 'other',
    '2026-07-16'::date, '2026-07-16'::date,
    53400000::bigint, 0::bigint, 'IBAGUE INSCRIPCION · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-2f34d58a2b96266ff66491c7', 'Eva Palomino', 'Trusa entreno', 'product',
    '2025-12-20'::date, '2025-12-20'::date,
    18500000::bigint, 18500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-196eb48370b266f72baf1e2b', 'Eva Palomino', 'Chequeo', 'extra_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7000000::bigint, 7000000::bigint, 'Selectivo · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0b66777c08afe0a4360e8804', 'Eva Palomino', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2b1ab401889dfb6306227cf9', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2dae43af7502f303a596efbe', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-271c276cab24e1cd83203334', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-22c038197e97b45d7fd7e1e6', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8e4375c72ee7aa9644548877', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-05-15'::date, '2026-05-15'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6801ad6b52ca1f262eed6f46', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-04-29'::date, '2026-04-29'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-39cf1da950cf58306468ef1a', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-04-25'::date, '2026-04-25'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5 (revisar) · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-17fb0b597a99bcae8f6c7f3a', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-04-23'::date, '2026-04-23'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h 24 ABRIL · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-006352abe530916334633c62', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-04-18'::date, '2026-04-18'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-02c87a2670e7f13027e0058d', 'Eva Palomino', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-752b91df16dae62543e9a8a3', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-01'::date, '2026-06-01'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5a09962bd4c011f6d9d4435a', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-02'::date, '2026-06-02'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-19fd28c2de38b156158612cb', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-09'::date, '2026-06-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-47c7d1d941aefd161cde60c0', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9ecd0ce3dbf6653fc648b4d6', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-17'::date, '2026-06-17'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fe05b671c1601a6be5c4d555', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3d5f4f7da4ca5ecd4a5fd1b5', 'Eva Palomino', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e8afd795a5e10eaf86184133', 'Martina Lopez', 'Trusa entreno', 'product',
    '2026-01-22'::date, '2026-01-22'::date,
    20300000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-9231902f016a607f9689ce6c', 'Martina Lopez', 'Camiseta', 'product',
    '2025-11-05'::date, '2025-11-05'::date,
    4000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-03ee30e8071b39ddf9ae282b', 'Luciana Contento', 'Camiseta', 'product',
    '2026-02-05'::date, '2026-02-05'::date,
    4500000::bigint, 4500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b882605fdd93dc629f75e34b', 'Valentina Valencia', 'Trusa gala', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0f4d9024613b65f8eee617b5', 'Valentina Valencia', 'Camiseta polo', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    11000000::bigint, 11000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f221c306debaa59f093dfa53', 'Valentina Valencia', 'Camiseta', 'product',
    '2026-04-17'::date, '2026-04-17'::date,
    4500000::bigint, 4500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1dff9e1bcff5cdd684634452', 'Itala Ma Orozco', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5cd2558ec86b860b40116497', 'Sophia Londoño', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2d7f3a0435a5d2adafa62d3f', 'Sophia Londoño', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-068d90b54dd15264c8de892c', 'Martina Rodriguez', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-772435d7a2b9b60dbdc9d24f', 'Martina Rodriguez', 'Camiseta polo', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    5500000::bigint, 5500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5da4bd4901c5a64e74eeabd6', 'Martina Rodriguez', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7660cd30e3fce0dcc1b01096', 'Martina Rodriguez', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-55eca0077b25203df4f60c7e', 'Martina Rodriguez', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f663a1a7de2a81dc4571395e', 'Martina Rodriguez', 'Chequeo', 'extra_class',
    '2026-06-18'::date, '2026-06-18'::date,
    7500000::bigint, 7500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6c12176d7c23adfc71b0b1db', 'Ana Sofia Echeverry', 'Trusa gala', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-472855a2c0c40f044511db3c', 'Ana Sofia Echeverry', 'Chaqueta y legging', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7f63295a2d14d49083c26fb2', 'Ana Sofia Echeverry', 'Camiseta polo', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    5500000::bigint, 5500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ed8ddce7b0536bae9428a940', 'Emiliana Silva', 'Clase extra', 'extra_class',
    '2026-04-10'::date, '2026-04-10'::date,
    19750000::bigint, 19750000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7d8f3a9981f1fba2a6cb6786', 'Emiliana Silva', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ffa4b16cde7ee201e73ee15c', 'Emiliana Silva', 'Personalizado', 'private_class',
    '2026-05-23'::date, '2026-05-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Diana · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bbc40a408f5419eff477c871', 'Emiliana Silva', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-26567388e1cd892f5d87feac', 'Luciana Cardenas', 'Clase extra', 'extra_class',
    '2026-04-10'::date, '2026-04-10'::date,
    19500000::bigint, 19500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-53ace083d9a1e01ced3b536b', 'Luciana Cardenas', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-be548dec30aef35d036fd3f8', 'Luciana Cardenas', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-702acc9d1916383c636e434a', 'Emma Vega', 'Clase extra', 'extra_class',
    '2026-03-21'::date, '2026-03-21'::date,
    7200000::bigint, 7200000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-039e017e6c722667e191bd1e', 'Ma Antonia Arce', 'Clase extra', 'extra_class',
    '2026-04-17'::date, '2026-04-17'::date,
    28800000::bigint, 28800000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-121a4e7629573545472b2743', 'Ma Jose Valencia', 'Personalizado', 'private_class',
    '2026-04-20'::date, '2026-04-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: <luna · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-00f795f545c38fc1e081bc46', 'Dulce Ma Aristizabal', 'Personalizado', 'private_class',
    '2026-04-07'::date, '2026-04-07'::date,
    4400000::bigint, 4400000::bigint, '1/2 hora · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-36185d959ea677d30f0ad9c1', 'Dulce Ma Aristizabal', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a7b9a26476c284bb3360f467', 'Dulce Ma Aristizabal', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4a88ff6bd1480ca5fad692b8', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-05-28'::date, '2026-05-28'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0eeb008c4f1572a5be437751', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-05-23'::date, '2026-05-23'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-049bec898683f66215cff571', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-25a023d8996b5c3a91be47c2', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-064aa39bedd1779974731330', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-05-14'::date, '2026-05-14'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2d16201c367c505a825ef8ee', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-04-30'::date, '2026-04-30'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ce3de38cb5ee4901cc29a428', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-04-23'::date, '2026-04-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-68953ee7cc1f7a514fcd0fb8', 'Emma Vargas', 'Trusa entreno', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    20300000::bigint, 20300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-85f1ac3243030b2ec220734c', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-06-04'::date, '2026-06-04'::date,
    7700000::bigint, 0::bigint, 'Profesora: Liz · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-21afbb155e3efbf3b1fb338f', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-06-11'::date, '2026-06-11'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angel · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-77e9a5bf98a0f1dd805d04f7', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    11550000::bigint, 0::bigint, 'Profesora: Liz · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-874fb4eb82ac7a5e3d6aa3c7', 'Emma Vargas', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    13200000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-381194daf8b867929e34b0f1', 'Emma Vargas', 'Otro', 'other',
    '2026-07-16'::date, '2026-07-16'::date,
    53400000::bigint, 0::bigint, 'IBAGUE INSCRIPCION · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-974684d74f002ee4e2aea6fc', 'Luciana Hincapie', 'Chequeo', 'extra_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7000000::bigint, 7000000::bigint, 'chequeo selectivo · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a7e913a9c97e8e6f6db23ba8', 'Luciana Hincapie', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3f12278fd80ef19956f9d9c7', 'Luciana Hincapie', 'Personalizado', 'private_class',
    '2026-05-15'::date, '2026-05-15'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-105889c309a72590381a56ef', 'Luciana Hincapie', 'Personalizado', 'private_class',
    '2026-05-08'::date, '2026-05-08'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8c5b332c8ff720c21d979ee4', 'Luciana Hincapie', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-01271f8cdd7347e56c12d3ea', 'Salome Navia', 'Chequeo', 'extra_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-158c819e9f764c9363207451', 'Salome Navia', 'Personalizado', 'private_class',
    '2026-04-24'::date, '2026-04-24'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4c4f9efac8006b9dbf3d20c1', 'Salome Navia', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    36550000::bigint, 36550000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9999e83b5a822a1cfef089d0', 'Amanda Ramirez', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    4000000::bigint, 4000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5ecf88012f03ce9bb5b73fb1', 'Ana Emilia Medina', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0ac893dcd580c6b432c29e7b', 'Ana Emilia Medina', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-951148896fe2084be2e33306', 'Antonella Endo', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    21000000::bigint, 21000000::bigint, '3 clases (9, 16, 17) · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ad82d21fda2172ffec0e6556', 'Antonella Endo', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ed3502bff285f98a66310f66', 'Antonella Endo', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ab8ffe2e902f0d17c4d34760', 'Antonella Endo', 'Guantes', 'product',
    '2026-04-30'::date, '2026-04-30'::date,
    13000000::bigint, 13000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3e6a37870827dd174f08b969', 'Antonella Endo', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6c1ee9eb4f61c19d058047c1', 'Antonella Endo', 'Otro', 'other',
    '2026-06-15'::date, '2026-06-15'::date,
    2000::bigint, 0::bigint, 'PUNTA CANA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c8f4fa4f466e65921854a861', 'Rebecca Endo', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    21000000::bigint, 21000000::bigint, '3 clases (9, 16, 17) · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-65e30f61f2807c1516a52148', 'Rebecca Endo', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-045cbb894168468b0a0fe38f', 'Rebecca Endo', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8e7000fda6cd680c33972d7c', 'Rebecca Endo', 'Otro', 'other',
    '2026-06-15'::date, '2026-06-15'::date,
    2000::bigint, 0::bigint, 'PUNTA CANA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-091fb907753d6a55b10a2459', 'Celeste Collazos', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9846f130fcd92b9742ce948b', 'Celeste Collazos', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2d9f87731955405eb57d44b5', 'Celeste Collazos', 'Otro', 'other',
    '2025-12-31'::date, '2025-12-31'::date,
    98000000::bigint, 98000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9f7e6d839eb76d8ad87fef61', 'Celeste Collazos', 'Personalizado', 'private_class',
    '2026-07-08'::date, '2026-07-08'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angie · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-62d18c972e2c8c29dbe0024b', 'Celeste Collazos', 'Personalizado', 'private_class',
    '2026-07-09'::date, '2026-07-09'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angie · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-a16c84b8fe53b0f812f2723b', 'Celeste Collazos', 'Personalizado', 'private_class',
    '2026-07-15'::date, '2026-07-15'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-ecb1c1d7c9374f2d99b5ba52', 'Celeste Collazos', 'Personalizado', 'private_class',
    '2026-07-16'::date, '2026-07-16'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d76500694e7665b4203f20db', 'Isabella Coral', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-79fe36a3018cd29362990e9a', 'Isabella Coral', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4a31b024bda3856c1a910e59', 'Isabella Coral', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e55181cee5bd522df53eb66f', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-05-26'::date, '2026-05-26'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9e3d534c1fccb952920290ac', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1cd35741cf1959225e9ea953', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-05-15'::date, '2026-05-15'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e8a4d06501c7b80a0ac3d5c1', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-05-05'::date, '2026-05-05'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7ff89578bd91543c6f2855e2', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-04-29'::date, '2026-04-29'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d4c552cc9341e3de72778661', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-04-28'::date, '2026-04-28'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bba09d0190eff870c31a5834', 'Isabella Coral', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4521e03d470092f45127434a', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-06-02'::date, '2026-06-02'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angel · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-354dad7f5415601bcf46195a', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-06-09'::date, '2026-06-09'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angel · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-1b6f4fc0122a8ac2bc997c12', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    7700000::bigint, 0::bigint, 'Profesora: Gila · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-08a2dc3fe508ef132aef8035', 'Isabella Coral', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7700000::bigint, 0::bigint, 'Profesora: Gila · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-74c8258f8e951f7edc657372', 'Laia Martinez', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-22cbd50c01838ce4dee91d56', 'Laia Martinez', 'Personalizado', 'private_class',
    '2026-05-23'::date, '2026-05-23'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Diana · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3c5ad413e180a8ad0bfbf581', 'Laia Martinez', 'Chaqueta y legging', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5997a4eff2d979ef1a78ee18', 'Lara Muñoz Ermakova', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6f26a9e641e947e90df0b7f7', 'Lara Muñoz Ermakova', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-39689b9a9feebbf8f329bd0a', 'Lara Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-27'::date, '2026-05-27'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fb9e5c4b238f394228537278', 'Lara Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Diana · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a3af3154701795aff88e9f92', 'Lara Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-06'::date, '2026-05-06'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-39a89f2947dc404368012a77', 'Lucia Villamil', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    4000000::bigint, 4000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7444815733b8255b2e67070c', 'Lucia Villamil', 'Chaqueta y legging', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a7d3c5358e6252b14b323441', 'Luciana Vallejo Vargas', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9d859cc12292b242cedc1136', 'Luciana Vallejo Vargas', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6e77111213d59e6083fce597', 'Luciana Vallejo Vargas', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-dda592781fcc99bc46801645', 'Luciana Vallejo Vargas', 'Clase extra', 'extra_class',
    '2026-05-17'::date, '2026-05-17'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4c4cb2976bcdab63e6a3544d', 'Ma Jose Zabala', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3dac6592b153a332dd3046c1', 'Ma Jose Zabala', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8e20568f38390d5f2f6f4b8d', 'Ma Mar Betancourth', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ccbc390283c0418dbc4cd17b', 'Ma Paula Gomez', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4b0107482d1fb71a4acc2cec', 'Ma Paula Gomez', 'Clase extra', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9934fed080d1028e5190d67a', 'Ma Paula Gomez', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-819d3a4ffb7fa675631c8126', 'Ma Victoria Ruiz', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-a9b3502e78c57b826688b68d', 'Mariana Ortiz', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-e2f9c75d92b6f906a85c0acf', 'Mia Rodriguez', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 23100000::bigint, 'Festival · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-45182b568a77518b2336c944', 'Mia Rodriguez', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 0::bigint, 'Profesora: Angie · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-5175e534f59495d64ea952a1', 'Mia Rodriguez', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c17b407c53cd8c941e97a1f9', 'Mia Rodriguez', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 5000000::bigint, 'Profesora: Fabi · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-4fa6f1892a755e8fb3d8f514', 'Mia Rodriguez', 'Clase extra', 'extra_class',
    '2026-06-01'::date, '2026-06-01'::date,
    35000000::bigint, 35000000::bigint, 'Cartagena · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6569e33605ce44eabdc773b7', 'Mia Rodriguez', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d24694c33ee07b9213619556', 'Mia Rodriguez', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    7700000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-baa75f11eb4ff2f9e5ac5052', 'Sofia Muñoz Ermakova', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-82d86168082590548cb0a688', 'Sofia Muñoz Ermakova', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9479bfdc0837f94a32aa1341', 'Sofia Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-27'::date, '2026-05-27'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-0965e67a5e71f15c89416d2d', 'Sofia Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9a538f0c47c3831b0a887ee7', 'Sofia Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-05-06'::date, '2026-05-06'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a874069a4eab3805aff1fb70', 'Sofia Muñoz Ermakova', 'Personalizado', 'private_class',
    '2026-04-29'::date, '2026-04-29'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-09613c0ae863d2e6270a970c', 'Sophia Aristizabal', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bdad110f5b57bc057245ccdd', 'Sophia Siple', 'Clase extra', 'extra_class',
    '2026-05-16'::date, '2026-05-16'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4149d8aab962978bdadb2c7e', 'Sophia Siple', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    15400000::bigint, 15400000::bigint, 'Profesora: Gila · 2h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-98819fa4602894ff5c5cf79f', 'Sophia Siple', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Gila · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-79fb277b2cbf2a8666dac14e', 'Sophia Siple', 'Trusa entreno', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    20300000::bigint, 20300000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-83ffc42f33ca5f1f26d51892', 'Summer Rain', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6210a5737cc76adc00433696', 'Summer Rain', 'Clase extra', 'extra_class',
    '2026-05-09'::date, '2026-05-09'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cb51ce1163e477428749a3cb', 'Summer Rain', 'Clase extra', 'extra_class',
    '2026-06-18'::date, '2026-06-18'::date,
    7000000::bigint, 7000000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7aa9dfec190aa1bf3baab07d', 'Summer Rain', 'Chequeo', 'extra_class',
    '2026-05-18'::date, '2026-05-18'::date,
    7500000::bigint, 7500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2bec45b9656868a326020009', 'Tammy Castellanos', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-deb53a6c8b64417a68df527f', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-06-01'::date, '2026-06-01'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-03148dca9473ebdee65f0435', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-29'::date, '2026-05-29'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d747737568404054f58a3e48', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-e22f1401c694fd47e7d8dadb', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ac29a2387023eaa3e5f70ac2', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4d5efa0a89b5488044ecb31f', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-00391f4da5b3b0a38894527d', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Liz · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-055658ed62e4ddffb1f3a651', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-15'::date, '2026-05-15'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b3d45f1ca7032420aeac563f', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-04'::date, '2026-05-04'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-b10c054288e93942effa1d7f', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c54245c47d2881c6b305b3ef', 'Tammy Castellanos', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    3850000::bigint, 3850000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-ae9a58477d258acf0b3bccec', 'Valeria Chavez', 'Clase extra', 'extra_class',
    '2026-05-01'::date, '2026-05-01'::date,
    29500000::bigint, 29500000::bigint, 'Festival · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d9c3a6b8d7fa77d197e1195b', 'Victoria Estepa', 'Clase extra', 'extra_class',
    '2026-05-17'::date, '2026-05-17'::date,
    7000000::bigint, 0::bigint, 'Festival · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-3478993765bf00645884f175', 'Victoria Estepa', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    11550000::bigint, 0::bigint, 'Profesora: Fabi · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-5aa55fa155e741f774b1702c', 'Victoria Estepa', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    7700000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-cd02996268e42d133b152ef1', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-29'::date, '2026-05-29'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-554bcbe84814fe3bf2295571', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-33eb8816d9f2c7f7fcab9dd9', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cc5da6322ccec52335ebd88b', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    3850000::bigint, 3850000::bigint, 'Profesora: Gila · 0,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d31317a5fc45570b450d5877', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c7ff53d5264421d1d507db25', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-18'::date, '2026-05-18'::date,
    3900000::bigint, 3900000::bigint, 'Profesora: Gila · 0,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d5135bdd608ab723d1268211', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-14'::date, '2026-05-14'::date,
    3850000::bigint, 3850000::bigint, 'Profesora: Gila · 0,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-257ad0e14ce4deef40481ece', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-07'::date, '2026-05-07'::date,
    3850000::bigint, 3850000::bigint, 'Profesora: Gila · 0,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-6aaa1592f7334a19cf3d5713', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-04'::date, '2026-05-04'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-93a9fe545a2d27ca1ffc1ef5', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-04-17'::date, '2026-04-17'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8f922819a3fffce3f9b55921', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-04-16'::date, '2026-04-16'::date,
    3850000::bigint, 3850000::bigint, 'Profesora: Gila · 0,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-69d0e274f53f5f3cc2cd2942', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-05-01'::date, '2026-05-01'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a146728f8adc3f175d517028', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    13200000::bigint, 0::bigint, 'Profesora: William · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-44aa63c08e61c2c6ae9c02de', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-06-25'::date, '2026-06-25'::date,
    11550000::bigint, 0::bigint, 'Profesora: Angie · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-de571a6e4270fda4efaa8bf8', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-07-09'::date, '2026-07-09'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Fabi · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2e43a09fac08eb2878d2854e', 'Carla Sedgemore', 'Personalizado', 'private_class',
    '2026-07-09'::date, '2026-07-09'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fce390ec3bbfff6268c3dd7e', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-28'::date, '2026-05-28'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-11b41a860e7d896d0be743c9', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-23'::date, '2026-05-23'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-d597e9bc1e6c4c5feff46264', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-c7a17db0bb8e15665358f616', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-20'::date, '2026-05-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angel · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1438a30722a798dee2180f2a', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-14'::date, '2026-05-14'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7745a5d8a69b0df1279d0a3a', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-04-30'::date, '2026-04-30'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5c21a54750931e749aefbfa2', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-04-22'::date, '2026-04-22'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-cc81d77cd55d8edab1aeb869', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-04-16'::date, '2026-04-16'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angel · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fd7cc6bffdadf804e3b35096', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-05-07'::date, '2026-05-07'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3ab9fbfd9d301f7a20e458ff', 'Isabella Vargas', 'Camiseta', 'product',
    '2026-04-11'::date, '2026-04-11'::date,
    4500000::bigint, 4500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-1bd60ee71d105c8f22163d48', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-06-04'::date, '2026-06-04'::date,
    11550000::bigint, 0::bigint, 'Profesora: Angel · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-1c545b0af166c962867d2679', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-06-11'::date, '2026-06-11'::date,
    11550000::bigint, 0::bigint, 'Profesora: Angie · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-8ab3e99a53f0f01ecff6b6fc', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    11550000::bigint, 0::bigint, 'Profesora: Gila · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-f7ab145151c85d7147b27b4b', 'Isabella Vargas', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    11550000::bigint, 0::bigint, 'Profesora: Diana · 1,5 · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-e4c27a5fead2fc3d046f10e1', 'Isabella Ospina Velasquez', 'Personalizado', 'private_class',
    '2026-05-26'::date, '2026-05-26'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-14cd5fc144fdb1147dd71b0c', 'Isabella Ospina Velasquez', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-25cdcf88983c4348bd046881', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-872c8e422ceb0ad9f40fb5e5', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-05-04'::date, '2026-05-04'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-126ec2945da1b7835e65a382', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-04-27'::date, '2026-04-27'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-3d1b4bd5897533f80c4234a2', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-04-20'::date, '2026-04-20'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f3bfa1a2df75937ce67b2fb9', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-06-01'::date, '2026-06-01'::date,
    7700000::bigint, 0::bigint, 'Profesora: Gila · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-3828981a0e13f7e810c32470', 'Salome Figueroa', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 0::bigint, 'Profesora: Gila · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-ebed8bbc4f3bc4f37654e4e6', 'Manuela Arias', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-352c17f9b6312ec72d63bf6c', 'Daniela Hidalgo', 'Personalizado', 'private_class',
    '2026-05-22'::date, '2026-05-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Dani · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f449fabe40f3d6e1fdc3d05f', 'Isabel Sofia Montoya', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-991c12d25b4b775e9ed5a61c', 'Isabel Sofia Montoya', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-be73a3e6d41784d31f5e90d9', 'Abigail Cuero', 'Personalizado', 'private_class',
    '2026-05-21'::date, '2026-05-21'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9f050eea96240dc10f21b437', 'Abigail Cuero', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-31e35b95586d3e140128679c', 'Abigail Cuero', 'Chaqueta y legging', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    29500000::bigint, 29500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a4a92344350108a549dec3a1', 'Antonella Castrillon', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-2adc8fc46f927658ec67ba6e', 'Emma Galindo', 'Personalizado', 'private_class',
    '2026-05-19'::date, '2026-05-19'::date,
    7700000::bigint, 7000000::bigint, 'Profesora: Angie · Estado original: 🟡 Parcial'
  ),
(
    'notion-movement-a652a6cf18b361eb11ce29a2', 'Aithana Caicedo', 'Personalizado', 'private_class',
    '2026-04-13'::date, '2026-04-13'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Gila · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-f60b865715ea2461329c11d3', 'Antonella Gaez', 'Personalizado', 'private_class',
    '2026-04-13'::date, '2026-04-13'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Gila · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-fd8f72bb1a82541d5e9b526b', 'Antonella Florez', 'Camiseta polo', 'product',
    '2026-04-10'::date, '2026-04-10'::date,
    5500000::bigint, 5500000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-720f6c95a4bab231a7d15b6e', 'Giorgia Montaña', 'Trusa gala', 'product',
    '2026-05-22'::date, '2026-05-22'::date,
    36000000::bigint, 36000000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-595d916544467501342d40a0', 'Giorgia Montaña', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    8800000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-7165face3193b0f6abe4275d', 'Giorgia Montaña', 'Otro', 'other',
    '2026-06-15'::date, '2026-06-15'::date,
    23000::bigint, 0::bigint, 'PUNTA CANA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-42c4e89cdeb47ffe9aad74f4', 'Ariana Paez', 'Otro', 'other',
    '2026-01-01'::date, '2026-01-01'::date,
    56700000::bigint, 56700000::bigint, 'Inscripción Ctg · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-9de61e1f48da0434d6124a3d', 'Ariana Paez', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    15400000::bigint, 0::bigint, 'Profesora: Angie · 2h · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-a98d5b0be6b2d99d52bb7fe8', 'Ariana Paez', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    13200000::bigint, 13200000::bigint, 'Profesora: William · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-48ba8c825ca13cd29e5dca03', 'Ariana Paez', 'Personalizado', 'private_class',
    '2026-06-25'::date, '2026-06-25'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5 · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5d7caf5011165e2c453bb0a3', 'Ariana Paez', 'Otro', 'other',
    '2026-07-16'::date, '2026-07-16'::date,
    53400000::bigint, 0::bigint, 'IBAGUE INSCRIPCION · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-781e6103ea2c64ad80c9e376', 'Sarah Ospina Velasquez', 'Personalizado', 'private_class',
    '2026-05-25'::date, '2026-05-25'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Angie · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-4a6ae523a8786ab3e455a9ef', 'Sarah Ospina Velasquez', 'Personalizado', 'private_class',
    '2026-05-26'::date, '2026-05-26'::date,
    11550000::bigint, 11550000::bigint, 'Profesora: Fabi · 1,5h · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-5dfd1a530d68999f56fa206e', 'Victoria Romero', 'Personalizado', 'private_class',
    '2026-06-16'::date, '2026-06-16'::date,
    7700000::bigint, 0::bigint, 'Profesora: Dani · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-524b533c9b7be50d698f397b', 'Victoria Romero', 'Personalizado', 'private_class',
    '2026-07-02'::date, '2026-07-02'::date,
    7700000::bigint, 0::bigint, 'Profesora: Dani · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-c47af4d51a9d7f01e9b0ddfe', 'Bella Raigoso', 'Personalizado', 'private_class',
    '2026-06-17'::date, '2026-06-17'::date,
    4400000::bigint, 4400000::bigint, 'Profesora: William · media hora · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7106cf56a60d386d5c4c1b2b', 'Bella Raigoso', 'Personalizado', 'private_class',
    '2026-06-18'::date, '2026-06-18'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: <luna · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-8def2a259e455032ff5428b6', 'Bella Raigoso', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7700000::bigint, 7700000::bigint, 'Profesora: Angie · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-76f2cc8f743baa240020e018', 'Violeta Kiwe', 'Personalizado', 'private_class',
    '2026-06-22'::date, '2026-06-22'::date,
    7500000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-970e852136eb251bb9b97b91', 'Violeta Kiwe', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    7000000::bigint, 0::bigint, 'Profesora: Fabi · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-4ca7c212be2f8eab51e78d27', 'Violeta Kiwe', 'Personalizado', 'private_class',
    '2026-06-24'::date, '2026-06-24'::date,
    7500000::bigint, 0::bigint, 'Profesora: William · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-a45277988b7c48f1af531491', 'Antonella Botero', 'Personalizado', 'private_class',
    '2026-06-23'::date, '2026-06-23'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-898ac2d488bf85b1a5e7b41c', 'Antonella Botero', 'Personalizado', 'private_class',
    '2026-06-25'::date, '2026-06-25'::date,
    8800000::bigint, 8800000::bigint, 'Profesora: William · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-a3e6674994b664eba3f9d1f9', 'Emiliana Garcia', 'Otro', 'other',
    '2026-06-15'::date, '2026-06-15'::date,
    23000::bigint, 0::bigint, 'PUNTA CANA · Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-8b09615e29be118ea9932760', 'Manuela Uribe', 'VERANO', 'competition',
    '2026-06-30'::date, '2026-06-30'::date,
    57400000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-a54b19ae1f5310ac3769e4b6', 'Manuela Uribe', 'CICLO', 'monthly_fee',
    '2026-06-30'::date, '2026-06-30'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-eba61ed245b0ca98b7feb6f8', 'Gabriela Diaz', 'VERANO', 'competition',
    '2026-06-22'::date, '2026-06-22'::date,
    63700000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-31c3df170223fc2c66e78596', 'Emma Lopez', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    36000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-d1b63f1597fdf670218d9acd', 'Amalia Rocha', 'VERANO', 'competition',
    '2026-06-30'::date, '2026-06-30'::date,
    30050000::bigint, 30050000::bigint, 'Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-7ccd3de85c5e21c89a81dd0b', 'Alicia Florez', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    27300000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-372b8431fb78611b0a8f631c', 'Mariangel Gomez', 'VERANO', 'competition',
    '2026-07-01'::date, '2026-07-01'::date,
    38100000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-9e5e7da88c163ae1e2af7a54', 'Luciana Hincapie', 'Otro', 'other',
    '2026-05-13'::date, '2026-05-13'::date,
    49500000::bigint, 49500000::bigint, 'CICLO · Estado original: 🟢 Pagado'
  ),
(
    'notion-movement-bfe23b07472ebe6e0f95506d', 'Luxiana Santamaria', 'Camiseta polo', 'product',
    '2026-06-24'::date, '2026-06-24'::date,
    5500000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-36fd5514c3a0de7625192246', 'Gabriela Uribe', 'CICLO', 'monthly_fee',
    '2026-06-30'::date, '2026-06-30'::date,
    66000000::bigint, 0::bigint, 'Estado original: 🔴 Pendiente'
  ),
(
    'notion-movement-9e89ce3569ff2c7d60f46d8e', 'Luciana Orejuela', 'CICLO', 'monthly_fee',
    '2026-06-08'::date, '2026-06-08'::date,
    22700000::bigint, 0::bigint, '9,17,23,24 junio · Estado original: 🔴 Pendiente'
  ),
(
    'notion-cycle-6f46b0f533c20a1b7f03c3d7', 'Eva Palomino', 'Ciclo 2026-06-25 a 2026-07-23', 'monthly_fee',
    '2026-06-25'::date, '2026-07-23'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-a5d5948661dfa916016a264b', 'Mariana Zuñiga', 'Ciclo 2026-05-28 a 2026-06-25', 'monthly_fee',
    '2026-05-28'::date, '2026-06-25'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-1e705cc506a46a51b6beefb2', 'Gabriela Uribe', 'Ciclo 2026-06-30 a 2026-07-28', 'monthly_fee',
    '2026-06-30'::date, '2026-07-28'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-67ee21cb96d671bce2d8aa95', 'Carla Sedgemore', 'Ciclo 2026-06-26 a 2026-07-24', 'monthly_fee',
    '2026-06-26'::date, '2026-07-24'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-1cd77f97cbaba805ce0be955', 'Luciana Arenas', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-5d16df2c8fbb5fefe1a4f504', 'Gabriela Duque', 'Ciclo 2026-06-26 a 2026-07-24', 'monthly_fee',
    '2026-06-26'::date, '2026-07-24'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-41ba8bce762243f13d36696b', 'Antonia Naranjo', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-733243bd210b5212e12ed2a9', 'Antonella Gaez', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-0c2f5e79b317d561ca311eeb', 'Emma Galindo', 'Ciclo 2026-07-02 a 2026-07-30', 'monthly_fee',
    '2026-07-02'::date, '2026-07-30'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-b11e9e25a6c3a41f96a56d70', 'Ma Celeste Cruz', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-70aaf13a3320799d79ccac71', 'Abigail Giraldo', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-ffb1ea08ffbb0685cf40f3c1', 'Salome Escobar', 'Ciclo 2026-08-01 a 2026-08-29', 'monthly_fee',
    '2026-08-01'::date, '2026-08-29'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-3c93a2a41b5a2621ae0f1272', 'Tammy Castellanos', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-625bad29319da5528d93e420', 'Ma Mar Betancourth', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-2d19925b11673064a66219b9', 'Salome Figueroa', 'Ciclo 2026-07-03 a 2026-07-31', 'monthly_fee',
    '2026-07-03'::date, '2026-07-31'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-877cf053a02e934e8a1c99e6', 'Victoria Estepa', 'Ciclo 2026-07-31 a 2026-08-28', 'monthly_fee',
    '2026-07-31'::date, '2026-08-28'::date,
    66000000::bigint, 66000::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-4f98ad2fcaea3b5768f10282', 'Manuela Arias', 'Ciclo 2026-08-04 a 2026-09-01', 'monthly_fee',
    '2026-08-04'::date, '2026-09-01'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-c641e8b85d652fe4d8ebc333', 'Ariana Paez', 'Ciclo 2026-07-21 a 2026-08-18', 'monthly_fee',
    '2026-07-21'::date, '2026-08-18'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-2942d46905d99a6d91469e1d', 'Giorgia Montaña', 'Ciclo 2026-08-04 a 2026-09-01', 'monthly_fee',
    '2026-08-04'::date, '2026-09-01'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-52ef9902b282a3da4afff974', 'Sofia Montaño', 'Ciclo 2026-07-23 a 2026-08-20', 'monthly_fee',
    '2026-07-23'::date, '2026-08-20'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-ed2f0b72f846521871b0dd29', 'Sophia Londoño', 'Ciclo 2026-07-02 a 2026-07-30', 'monthly_fee',
    '2026-07-02'::date, '2026-07-30'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-768ed6a4f30a109856be7646', 'Paulina Mattey', 'Ciclo 2026-08-19 a 2026-09-16', 'monthly_fee',
    '2026-08-19'::date, '2026-09-16'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-bbfe9e36e8eb8f4e0e215557', 'Gabriela Chaurra', 'Ciclo 2026-01-26 a 2026-02-23', 'monthly_fee',
    '2026-01-26'::date, '2026-02-23'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-7a280170b1a592203f366029', 'Martina Rodriguez', 'Ciclo 2026-07-23 a 2026-08-20', 'monthly_fee',
    '2026-07-23'::date, '2026-08-20'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-7a622f236f5209050fbe13d2', 'Ariana Vargas', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-e5a76b0d1b412c1ca0a61dc2', 'Mariana Londoño', 'Ciclo 2026-07-10 a 2026-08-07', 'monthly_fee',
    '2026-07-10'::date, '2026-08-07'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · murio tio · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-1af6a42f0f1d32bc28444032', 'Emmanuela Palacios', 'Ciclo 2026-04-30 a 2026-05-28', 'monthly_fee',
    '2026-04-30'::date, '2026-05-28'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-5f04fdb22ac648aacc85d86b', 'Mariana Chaves', 'Ciclo 2026-07-13 a 2026-08-10', 'monthly_fee',
    '2026-07-13'::date, '2026-08-10'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-8ec86b7ba769f878ef2efc85', 'Ma Jose Valencia', 'Ciclo 2026-08-03 a 2026-08-31', 'monthly_fee',
    '2026-08-03'::date, '2026-08-31'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 4 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-2ad5973f6b8cbf3008bbea35', 'Martina Lopez', 'Ciclo 2026-03-05 a 2026-04-02', 'monthly_fee',
    '2026-03-05'::date, '2026-04-02'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-0da677b947647ebd7a2b02c0', 'Marthina Soto', 'Ciclo 2026-03-05 a 2026-04-02', 'monthly_fee',
    '2026-03-05'::date, '2026-04-02'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-c8da61e8f5fdfaee2b4215b2', 'Hannah Navia', 'Ciclo 2026-08-03 a 2026-08-31', 'monthly_fee',
    '2026-08-03'::date, '2026-08-31'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 5 · pausa ciclo por incapacidad, 3 semanas pendientes de tomar · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-84fb3779422ce2cdeaea90df', 'Ana Emilia Medina', 'Ciclo 2026-07-30 a 2026-08-27', 'monthly_fee',
    '2026-07-30'::date, '2026-08-27'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-8762a3a3fa32dfe77668d4e9', 'Ma Paula Gomez', 'Ciclo 2026-06-08 a 2026-07-06', 'monthly_fee',
    '2026-06-08'::date, '2026-07-06'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 5 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-398ab73a43cf581f1c0fbcae', 'Valery Cordoba', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 4 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-3e721a4eade77b477d454577', 'Mariana Ortiz', 'Ciclo 2026-05-26 a 2026-06-23', 'monthly_fee',
    '2026-05-26'::date, '2026-06-23'::date,
    33300000::bigint, 33300000::bigint, 'Programa: Minis · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-205e79cc9f149e0f548c219b', 'Paulina Velez', 'Ciclo 2026-07-29 a 2026-08-26', 'monthly_fee',
    '2026-07-29'::date, '2026-08-26'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-c0dff383e4a8e0d9cb6eea76', 'Antonella Endo', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-601a67451f16d85e4424436c', 'Rebecca Endo', 'Ciclo 2026-07-24 a 2026-08-21', 'monthly_fee',
    '2026-07-24'::date, '2026-08-21'::date,
    33700000::bigint, 33700000::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-5334e90cede66d3b363b5ac0', 'Valentina Rodriguez', 'Ciclo 2026-07-21 a 2026-08-18', 'monthly_fee',
    '2026-07-21'::date, '2026-08-18'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-4a3202ab8f2fca3f15b4e860', 'Sara Escobar', 'Ciclo 2026-07-23 a 2026-08-20', 'monthly_fee',
    '2026-07-23'::date, '2026-08-20'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-ad1de8019b0f55448b12730d', 'Olivia Ceballos', 'Ciclo 2026-07-20 a 2026-08-17', 'monthly_fee',
    '2026-07-20'::date, '2026-08-17'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-19ac4aa6f4bdee84833db61b', 'Ma Antonia Arce', 'Ciclo 2026-06-26 a 2026-07-24', 'monthly_fee',
    '2026-06-26'::date, '2026-07-24'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-b3714daeff556b593dca9939', 'Valentina Valencia', 'Ciclo 2026-07-18 a 2026-08-15', 'monthly_fee',
    '2026-07-18'::date, '2026-08-15'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-d81f34024a11b04825a10d1b', 'Andrea Barreto', 'Ciclo 2026-08-04 a 2026-09-01', 'monthly_fee',
    '2026-08-04'::date, '2026-09-01'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-c4d02b063078a204899641a6', 'Alanna Segura', 'Ciclo 2026-07-28 a 2026-08-25', 'monthly_fee',
    '2026-07-28'::date, '2026-08-25'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-8dcf851465b261853ddb5638', 'Ana Sofia Echeverry', 'Ciclo 2026-07-29 a 2026-08-26', 'monthly_fee',
    '2026-07-29'::date, '2026-08-26'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 3 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-511c573a6697d465bc1d4cf9', 'Emilia Gomez Aristizabal', 'Ciclo 2026-07-31 a 2026-08-28', 'monthly_fee',
    '2026-07-31'::date, '2026-08-28'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Minis · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-8e58b9fcac72514718f6203c', 'Juliana Benavides', 'Ciclo 2026-06-05 a 2026-07-03', 'monthly_fee',
    '2026-06-05'::date, '2026-07-03'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-3a2dd55cdcce1298217be467', 'Samara Ochoa', 'Ciclo 2026-08-01 a 2026-08-29', 'monthly_fee',
    '2026-08-01'::date, '2026-08-29'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-aa74922e533f509070e4a43b', 'Valeria Burbano', 'Ciclo 2026-08-08 a 2026-09-05', 'monthly_fee',
    '2026-08-08'::date, '2026-09-05'::date,
    17800::bigint, 17800::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-6dcd23435d664d6f1daf0278', 'Agustina Diaz', 'Ciclo 2026-06-08 a 2026-07-06', 'monthly_fee',
    '2026-06-08'::date, '2026-07-06'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-bb4586b58880d7ab1c8f178a', 'Lucia Valdes', 'Ciclo 2026-06-10 a 2026-07-08', 'monthly_fee',
    '2026-06-10'::date, '2026-07-08'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-bd6b6a36235ef79a1991799b', 'Luciana Vallejo Ossa', 'Ciclo 2026-08-03 a 2026-08-31', 'monthly_fee',
    '2026-08-03'::date, '2026-08-31'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-2427854ad411b9762c422169', 'Laia Martinez', 'Ciclo 2026-07-08 a 2026-08-05', 'monthly_fee',
    '2026-07-08'::date, '2026-08-05'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-f8d44e8313bf607c40405eaf', 'Antonella Botero', 'Ciclo 2026-07-27 a 2026-08-24', 'monthly_fee',
    '2026-07-27'::date, '2026-08-24'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: PRENIVEL · Mes incapacidad · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-694b135fdce30db307b3fb49', 'Sofia Carmona', 'Ciclo 2026-08-05 a 2026-09-02', 'monthly_fee',
    '2026-08-05'::date, '2026-09-02'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-4f0d12c06ef2d2ea997096cc', 'Miranda Villa', 'Ciclo 2026-03-18 a 2026-04-15', 'monthly_fee',
    '2026-03-18'::date, '2026-04-15'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-d9f68d8692d37d2fffd803ea', 'Ma Clara Quintero', 'Ciclo 2026-06-16 a 2026-07-14', 'monthly_fee',
    '2026-06-16'::date, '2026-07-14'::date,
    40500000::bigint, 40500000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-5f0164e60f1fdaab00afb33b', 'Ana Sofia Gutierrez', 'Ciclo 2026-07-08 a 2026-08-05', 'monthly_fee',
    '2026-07-08'::date, '2026-08-05'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-06ac92ce4d458f2c0d284d32', 'Mariangel Gomez', 'Ciclo 2026-06-10 a 2026-07-08', 'monthly_fee',
    '2026-06-10'::date, '2026-07-08'::date,
    66000000::bigint, 66000000::bigint, 'Programa: Intensivo · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-23b2951418f7ce4d0a45935d', 'Salome Navia', 'Ciclo 2026-06-16 a 2026-07-14', 'monthly_fee',
    '2026-06-16'::date, '2026-07-14'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-156b78cb98e0def8c21a4b80', 'Gabriela Cardona', 'Ciclo 2026-08-07 a 2026-09-04', 'monthly_fee',
    '2026-08-07'::date, '2026-09-04'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-ace0c7d3b9e41aec5051fc4d', 'Ma Alejandra Calle', 'Ciclo 2026-08-07 a 2026-09-04', 'monthly_fee',
    '2026-08-07'::date, '2026-09-04'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-1dcbe96f1f4fd800cdc96444', 'Luciana Hincapie', 'Ciclo 2026-06-03 a 2026-07-01', 'monthly_fee',
    '2026-06-03'::date, '2026-07-01'::date,
    66000000::bigint, 66000::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-28014dc1fc42ead16b692369', 'Victoria Ossa', 'Ciclo 2026-05-18 a 2026-06-15', 'monthly_fee',
    '2026-05-18'::date, '2026-06-15'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-138812bc2125fee186a17cb9', 'Anthonella Parra', 'Ciclo 2026-06-17 a 2026-07-15', 'monthly_fee',
    '2026-06-17'::date, '2026-07-15'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-95efec578e4d83ff3fd81773', 'Isabella Valencia', 'Ciclo 2026-07-22 a 2026-08-19', 'monthly_fee',
    '2026-07-22'::date, '2026-08-19'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-d0ac9eb944bf61d498495e10', 'Danna Farfan', 'Ciclo 2026-07-16 a 2026-08-13', 'monthly_fee',
    '2026-07-16'::date, '2026-08-13'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-f9885b6393d56f76598b76b4', 'Isabella Nieto', 'Ciclo 2026-07-23 a 2026-08-20', 'monthly_fee',
    '2026-07-23'::date, '2026-08-20'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-3b9687b3dd66f346a37f9858', 'Valentina Silva', 'Ciclo 2026-06-22 a 2026-07-20', 'monthly_fee',
    '2026-06-22'::date, '2026-07-20'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-14da69d0a5d23ea64eb98767', 'Luciana Ortiz', 'Ciclo 2026-07-20 a 2026-08-17', 'monthly_fee',
    '2026-07-20'::date, '2026-08-17'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-ae18b4f53e1e4d0dfbfe407e', 'Daniela Chacon', 'Ciclo 2026-04-27 a 2026-05-25', 'monthly_fee',
    '2026-04-27'::date, '2026-05-25'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-2ff0ddd0fb128df72645bb6d', 'Violeta Diaz', 'Ciclo 2026-05-26 a 2026-06-23', 'monthly_fee',
    '2026-05-26'::date, '2026-06-23'::date,
    17800000::bigint, 17800000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-6c5388f4a0dafdbc2048cdb2', 'Martina Garzon', 'Ciclo 2026-06-23 a 2026-07-21', 'monthly_fee',
    '2026-06-23'::date, '2026-07-21'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-11ce9b23876f3b3fa338f428', 'Sofia Reynoso', 'Ciclo 2026-06-25 a 2026-07-23', 'monthly_fee',
    '2026-06-25'::date, '2026-07-23'::date,
    33800000::bigint, 33800000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-c29b3934f0988d11240e5ea4', 'Fatima Hinestrosa', 'Ciclo 2026-06-24 a 2026-07-22', 'monthly_fee',
    '2026-06-24'::date, '2026-07-22'::date,
    17800000::bigint, 17800000::bigint, 'Programa: Regular · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-01514db7b8ab2ddc25f57a9d', 'Bella Raigoso', 'Ciclo 2026-07-22 a 2026-08-19', 'monthly_fee',
    '2026-07-22'::date, '2026-08-19'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Minis · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-18f848931d401efe50c09bf5', 'Mia Rodriguez', 'Ciclo 2026-06-29 a 2026-07-27', 'monthly_fee',
    '2026-06-29'::date, '2026-07-27'::date,
    37400000::bigint, 37400000::bigint, 'Programa: Regular · Nivel: NIVEL 2 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-5cece2589c46731dc7d28a90', 'Luciana Contento', 'Ciclo 2026-07-23 a 2026-08-20', 'monthly_fee',
    '2026-07-23'::date, '2026-08-20'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-a23ca8f4efa3aa48349df2e0', 'Luciana Campuzano', 'Ciclo 2026-06-23 a 2026-07-21', 'monthly_fee',
    '2026-06-23'::date, '2026-07-21'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-8a37294dc07471e3aa5c9d12', 'Sarah Ospina Velasquez', 'Ciclo 2026-06-24 a 2026-07-22', 'monthly_fee',
    '2026-06-24'::date, '2026-07-22'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-e5d162afcbe039258989f7b6', 'Isabella Ospina Velasquez', 'Ciclo 2026-06-24 a 2026-07-22', 'monthly_fee',
    '2026-06-24'::date, '2026-07-22'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 3 · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-58114e8245553de3d31a7efe', 'Gabriela Montenegro Borja', 'Ciclo 2026-07-25 a 2026-08-22', 'monthly_fee',
    '2026-07-25'::date, '2026-08-22'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: NIVEL 1 · Estado original: PENDIENTE 🟡'
  ),
(
    'notion-cycle-ff426faa415711b54dcd68da', 'Arianna Trejos', 'Ciclo 2026-03-25 a 2026-04-22', 'monthly_fee',
    '2026-03-25'::date, '2026-04-22'::date,
    37400::bigint, 37400::bigint, 'Programa: Regular · Nivel: NIVEL 4 · cirugia oreja · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-b431c68b70ba491fcaf44efc', 'Antonella Hernandez', 'Ciclo 2026-07-04 a 2026-08-01', 'monthly_fee',
    '2026-07-04'::date, '2026-08-01'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-de8b8b204fa2f60ce2b7cacf', 'Abigail Perea', 'Ciclo 2026-06-09 a 2026-07-07', 'monthly_fee',
    '2026-06-09'::date, '2026-07-07'::date,
    17800::bigint, 17800::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-dd34408df977431e41b54e3d', 'Martina Cortes', 'Ciclo 2026-07-07 a 2026-08-04', 'monthly_fee',
    '2026-07-07'::date, '2026-08-04'::date,
    22700::bigint, 22700::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-572c53679183fd01675c7201', 'Victoria Argoty', 'Ciclo 2026-05-04 a 2026-06-01', 'monthly_fee',
    '2026-05-04'::date, '2026-06-01'::date,
    38700000::bigint, 38700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-f80c2f80611f2803d762a542', 'Montserrat Dranguet', 'Ciclo 2026-07-02 a 2026-07-30', 'monthly_fee',
    '2026-07-02'::date, '2026-07-30'::date,
    27500000::bigint, 27500000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-f4316759747b52862f293e14', 'Luciana Aristizabal', 'Ciclo 2026-04-02 a 2026-04-30', 'monthly_fee',
    '2026-04-02'::date, '2026-04-30'::date,
    22700000::bigint, 22700000::bigint, 'Programa: Regular · Nivel: PRENIVEL · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-c6adc33ab17d13480b4b2583', 'Amy Olano', 'Ciclo 2026-07-27 a 2026-08-24', 'monthly_fee',
    '2026-07-27'::date, '2026-08-24'::date,
    33800000::bigint, 33800000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: AL DÍA 🟢'
  ),
(
    'notion-cycle-3ccfc1966907c2c95f17b4d4', 'Milagros Gil', 'Ciclo 2026-06-04 a 2026-07-02', 'monthly_fee',
    '2026-06-04'::date, '2026-07-02'::date,
    17800000::bigint, 17800000::bigint, 'Programa: Minis · Nivel: CIRCUITO · Estado original: VENCIDO 🔴'
  ),
(
    'notion-cycle-51d2f3e541834af85536f164', 'Violeta Kiwe', 'Ciclo 2026-08-05 a 2026-09-02', 'monthly_fee',
    '2026-08-05'::date, '2026-09-02'::date,
    66000000::bigint, 0::bigint, 'Programa: Intensivo · Nivel: NIVEL 6 · Estado original: AL DÍA 🟢'
  );

insert into public.notion_import_exceptions (
  import_type, external_id, person_name, reason, raw_data
)
select
  'financial_history',
  stage.external_id,
  stage.gymnast_name,
  case
    when count(gymnasts.id) = 0 then 'No se encontró una gimnasta con este nombre'
    else 'El nombre coincide con más de una gimnasta'
  end,
  jsonb_build_object(
    'concept', stage.concept,
    'issued_on', stage.issued_on,
    'amount_cents', stage.amount_cents,
    'paid_cents', stage.paid_cents
  )
from notion_financial_stage stage
left join public.gymnasts
  on lower(unaccent(trim(gymnasts.first_name || ' ' || gymnasts.last_name)))
   = lower(unaccent(trim(stage.gymnast_name)))
group by stage.external_id, stage.gymnast_name, stage.concept,
  stage.issued_on, stage.amount_cents, stage.paid_cents
having count(gymnasts.id) <> 1
on conflict (external_id) do nothing;

insert into public.billing_charges (
  gymnast_id, concept, category, description, issued_on, due_on,
  amount_cents, external_source, external_id
)
select
  (array_agg(gymnasts.id))[1],
  stage.concept,
  stage.category,
  stage.notes,
  stage.issued_on,
  stage.due_on,
  stage.amount_cents,
  'notion',
  stage.external_id
from notion_financial_stage stage
join public.gymnasts
  on lower(unaccent(trim(gymnasts.first_name || ' ' || gymnasts.last_name)))
   = lower(unaccent(trim(stage.gymnast_name)))
group by stage.external_id, stage.concept, stage.category, stage.notes,
  stage.issued_on, stage.due_on, stage.amount_cents
having count(gymnasts.id) = 1
on conflict (external_source, external_id) where external_source is not null and external_id is not null
do nothing;

insert into public.payments (
  gymnast_id, paid_on, amount_cents, payment_method, notes,
  external_source, external_id
)
select
  charges.gymnast_id,
  stage.issued_on,
  stage.paid_cents,
  'other',
  'Pago histórico importado desde Notion',
  'notion',
  stage.external_id
from notion_financial_stage stage
join public.billing_charges charges
  on charges.external_source = 'notion'
 and charges.external_id = stage.external_id
where stage.paid_cents > 0
on conflict (external_source, external_id) where external_source is not null and external_id is not null
do nothing;

insert into public.payment_allocations (
  payment_id, charge_id, amount_cents
)
select payments.id, charges.id, payments.amount_cents
from public.payments payments
join public.billing_charges charges
  on charges.external_source = payments.external_source
 and charges.external_id = payments.external_id
left join public.payment_allocations allocations
  on allocations.payment_id = payments.id and allocations.charge_id = charges.id
where payments.external_source = 'notion'
  and allocations.payment_id is null;
