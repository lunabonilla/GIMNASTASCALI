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
console.log(JSON.stringify({
  movementRows: movements.length,
  cycleRows: cycles.length,
  totalRows: rows.length,
  paidRows: rows.filter((row) => row.paid > 0).length,
  pendingRows: rows.filter((row) => row.paid < row.amount).length,
  archivedRows: movementRaw.length + cycleRaw.length,
  chargedPesos: rows.reduce((total, row) => total + row.amount, 0),
  paidPesos: rows.reduce((total, row) => total + row.paid, 0),
  output: outputPath.pathname,
}, null, 2));
