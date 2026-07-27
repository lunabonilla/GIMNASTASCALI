import fs from "node:fs";
import crypto from "node:crypto";
import { parse } from "csv-parse/sync";

const base =
  "/Users/lunabonilladuque/Downloads/CLUB DEPORTIVO GIMNASTAS - ORGANIZACIÓN GENERAL";
const movementsPath = `${base}/Movimientos Deportistas 0053cfc8ffae476d9df5c2aeb0883524.csv`;
const cyclesPath = `${base}/CONTROL DE PAGO DEPORTISTAS/💸 Control de pagos e14b7aa062ee4ab1815cd0f6fb04c95c.csv`;
const outputPath =
  new URL("../supabase/migrations/20260726260000_import_notion_financial_history.sql", import.meta.url);

const readCsv = (path) =>
  parse(fs.readFileSync(path), {
    columns: true,
    skip_empty_lines: true,
    bom: true,
    relax_column_count: true,
  });

const sql = (value) =>
  value === null || value === undefined || value === ""
    ? "null"
    : `'${String(value).replaceAll("'", "''")}'`;

const amount = (value) => {
  const original = String(value ?? "").trim();
  if (!original) return 0;
  const digits = original.replace(/\D/g, "");
  const hasDecimalComma = /,\d{2}(?:\D*)$/.test(original);
  const parsed = hasDecimalComma ? Number(digits) / 100 : Number(digits);
  return Number.isFinite(parsed) ? Math.round(parsed) : 0;
};

const months = {
  enero: 1, febrero: 2, marzo: 3, abril: 4, mayo: 5, junio: 6,
  julio: 7, agosto: 8, septiembre: 9, octubre: 10, noviembre: 11, diciembre: 12,
};

const spanishDate = (value) => {
  const match = String(value ?? "")
    .toLocaleLowerCase("es")
    .match(/(\d{1,2}) de ([a-záéíóúñ]+) de (\d{4})/);
  if (!match || !months[match[2]]) return null;
  return `${match[3]}-${String(months[match[2]]).padStart(2, "0")}-${match[1].padStart(2, "0")}`;
};

const personName = (value) => String(value ?? "").split(" (")[0].trim();
const hash = (prefix, row) =>
  `${prefix}-${crypto.createHash("sha256").update(JSON.stringify(row)).digest("hex").slice(0, 24)}`;

const category = (concept) => {
  const normalized = String(concept ?? "").toLocaleLowerCase("es");
  if (normalized.includes("ciclo") || normalized.includes("mensual")) return "monthly_fee";
  if (normalized.includes("personalizado")) return "private_class";
  if (normalized.includes("clase extra") || normalized.includes("chequeo")) return "extra_class";
  if (
    normalized.includes("trusa") || normalized.includes("camiseta") ||
    normalized.includes("chaqueta") || normalized.includes("guante") ||
    normalized.includes("accesorio")
  ) return "product";
  if (normalized.includes("verano") || normalized.includes("compet")) return "competition";
  return "other";
};

const movementRaw = readCsv(movementsPath);
const cycleRaw = readCsv(cyclesPath);

const movements = movementRaw
  .map((row, index) => {
    const gymnast = personName(row.Deportista);
    const net = amount(row["Valor neto"]) || amount(row.Valor);
    if (!gymnast || net <= 0) return null;
    const pending = Math.max(0, amount(row["Valor pendiente"]));
    const explicitPaid = amount(row["Abonado a este cargo"]);
    const paid =
      explicitPaid > 0
        ? Math.min(net, explicitPaid)
        : String(row.Estado).includes("Pagado")
          ? net
          : String(row.Estado).includes("Parcial")
            ? Math.max(0, net - pending)
            : 0;
    const date = spanishDate(row.Fecha) ?? "2026-01-01";
    const concept = row.Concepto?.trim() || row.Movimiento?.trim() || "Cargo de Notion";
    const notes = [
      row.Profesor ? `Profesora: ${row.Profesor}` : "",
      row.Observaciones,
      `Estado original: ${row.Estado || "Sin estado"}`,
    ].filter(Boolean).join(" · ");
    return {
      source: hash("notion-movement", { index, row }),
      gymnast, concept, category: category(concept), date,
      amount: net, paid, notes,
    };
  })
  .filter(Boolean);

const cycles = cycleRaw
  .map((row, index) => {
    const gymnast = row["Nombre de la deportista"]?.trim();
    const start = spanishDate(row["Inicio ciclo"]);
    const end = spanishDate(row["Fecha fin del ciclo"]) || spanishDate(row["Próximo ciclo"]);
    const paid = amount(row["Valor pagado"]);
    if (!gymnast || !start || !end) return null;
    const defaultAmount = row.Programa?.toLocaleLowerCase("es").includes("intensivo") ? 660000 : paid;
    const total = Math.max(paid, defaultAmount);
    if (total <= 0) return null;
    const notes = [
      row.Programa ? `Programa: ${row.Programa}` : "",
      row.Nivel ? `Nivel: ${row.Nivel}` : "",
      row.Observaciones,
      `Estado original: ${row["Estado del ciclo"] || "Sin estado"}`,
    ].filter(Boolean).join(" · ");
    return {
      source: hash("notion-cycle", { index, row }),
      gymnast,
      concept: `Ciclo ${start} a ${end}`,
      category: "monthly_fee",
      date: start,
      due: end,
      amount: total,
      paid: Math.min(total, paid),
      inferred: paid === 0 && defaultAmount > 0,
      notes,
    };
  })
  .filter(Boolean);

const rows = [...movements, ...cycles];
const values = rows
  .map((row) => `(
    ${sql(row.source)}, ${sql(row.gymnast)}, ${sql(row.concept)}, ${sql(row.category)},
    ${sql(row.date)}::date, ${sql(row.due ?? row.date)}::date,
    ${row.amount * 100}::bigint, ${row.paid * 100}::bigint, ${sql(row.notes)}
  )`)
  .join(",\n");

const archiveValues = [
  ...movementRaw.map((row, index) => ({
    type: "movement",
    source: hash("notion-movement-archive", { index, row }),
    gymnast: personName(row.Deportista) || null,
    row,
  })),
  ...cycleRaw.map((row, index) => ({
    type: "cycle",
    source: hash("notion-cycle-archive", { index, row }),
    gymnast: row["Nombre de la deportista"]?.trim() || null,
    row,
  })),
]
  .map((record) => `(
    ${sql(record.type)}, ${sql(record.source)}, ${sql(record.gymnast)},
    ${sql(JSON.stringify(record.row))}::jsonb
  )`)
  .join(",\n");

const migration = `create extension if not exists unaccent;

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
${archiveValues}
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
${values};

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
`;

fs.writeFileSync(outputPath, migration);

const inferredCycleIds = cycles
  .filter((row) => row.inferred)
  .map((row) => sql(row.source))
  .join(",\n  ");
const correctionPath = new URL(
  "../supabase/migrations/20260726261000_remove_inferred_cycle_amounts.sql",
  import.meta.url,
);
fs.writeFileSync(
  correctionPath,
  `-- Cycles without an explicit amount remain in notion_financial_archive,
-- but must not affect real accounts receivable.
delete from public.billing_charges
where external_source = 'notion'
  and external_id in (
  ${inferredCycleIds}
  );
`,
);

const normalizeOfficialCycleAmount = (program, paid) => {
  const fixed = {
    Intensivo: 660000,
  };
  if (fixed[program]) return fixed[program];
  if (paid > 0 && paid < 1000) return paid * 1000;
  return paid;
};

const officialCycleRows = cycleRaw
  .map((row, index) => {
    const gymnast = row["Nombre de la deportista"]?.trim();
    const program = row.Programa?.trim();
    const start = spanishDate(row["Inicio ciclo"]);
    const end = spanishDate(row["Fecha fin del ciclo"]) || spanishDate(row["Próximo ciclo"]);
    const originalPaid = amount(row["Valor pagado"]);
    const normalizedPaid = originalPaid > 0 && originalPaid < 1000
      ? originalPaid * 1000
      : originalPaid;
    const officialAmount = normalizeOfficialCycleAmount(program, originalPaid);
    if (!gymnast || !start || !end || officialAmount <= 0) return null;
    return {
      source: hash("notion-cycle", { index, row }),
      gymnast,
      program,
      start,
      end,
      paid: Math.min(officialAmount, normalizedPaid),
      amount: officialAmount,
      concept: `Ciclo ${start} a ${end}`,
      notes: [
        program ? `Programa: ${program}` : "",
        row.Nivel ? `Nivel: ${row.Nivel}` : "",
        row.Observaciones,
        `Estado original: ${row["Estado del ciclo"] || "Sin estado"}`,
      ].filter(Boolean).join(" · "),
    };
  })
  .filter(Boolean);

const officialCycleValues = officialCycleRows.map((row) => `(
  ${sql(row.source)}, ${sql(row.gymnast)}, ${sql(row.program)},
  ${sql(row.start)}::date, ${sql(row.end)}::date,
  ${row.amount * 100}::bigint, ${row.paid * 100}::bigint,
  ${sql(row.concept)}, ${sql(row.notes)}
)`).join(",\n");

const officialRatesPath = new URL(
  "../supabase/migrations/20260726262000_apply_official_2026_cycle_rates.sql",
  import.meta.url,
);
fs.writeFileSync(officialRatesPath, `create table if not exists public.billing_rate_plans (
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
${officialCycleValues};

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
`);
console.log(JSON.stringify({
  movementRows: movements.length,
  cycleRows: cycles.length,
  totalRows: rows.length,
  paidRows: rows.filter((row) => row.paid > 0).length,
  pendingRows: rows.filter((row) => row.paid < row.amount).length,
  archivedRows: movementRaw.length + cycleRaw.length,
  chargedPesos: rows.reduce((total, row) => total + row.amount, 0),
  paidPesos: rows.reduce((total, row) => total + row.paid, 0),
  inferredCyclesRemovedFromBalance: cycles.filter((row) => row.inferred).length,
  officialCycleRows: officialCycleRows.length,
  output: outputPath.pathname,
}, null, 2));
