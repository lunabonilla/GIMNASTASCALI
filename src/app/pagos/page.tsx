import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function PaymentsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; view?: string; program?: string; level?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const {
    q = "",
    view = "collect",
    program = "",
    level: levelFilter = "",
  } = await searchParams;
  const [
    { data, error },
    { count: archivedCount },
    { count: exceptionCount },
  ] = await Promise.all([
    supabase
      .from("billing_charges")
      .select("id, gymnast_id, amount_cents, due_on, period_starts_on, voided_at, gymnasts(first_name, last_name, status, levels(name), gymnast_billing_profiles(program)), payment_allocations(amount_cents)")
      .is("voided_at", null)
      .order("due_on"),
    supabase
      .from("notion_financial_archive")
      .select("*", { count: "exact", head: true }),
    supabase
      .from("notion_import_exceptions")
      .select("*", { count: "exact", head: true }),
  ]);

  const charges = (data ?? []) as Array<{
    id: string;
    gymnast_id: string;
    amount_cents: number;
    due_on: string;
    gymnasts:
      | {
          first_name: string; last_name: string; status: string;
          levels: { name: string } | Array<{ name: string }> | null;
          gymnast_billing_profiles: { program: string | null } | Array<{ program: string | null }> | null;
        }
      | Array<{
          first_name: string; last_name: string; status: string;
          levels: { name: string } | Array<{ name: string }> | null;
          gymnast_billing_profiles: { program: string | null } | Array<{ program: string | null }> | null;
        }>
      | null;
    period_starts_on: string | null;
    payment_allocations: Array<{ amount_cents: number }>;
  }>;

  const accounts = new Map<string, {
    id: string;
    name: string;
    charged: number;
    paid: number;
    overdue: number;
    status: string;
    nextDue: string | null;
    cycleStart: string | null;
    program: string;
    level: string;
  }>();
  const today = new Date().toISOString().slice(0, 10);

  for (const charge of charges) {
    const gymnast = Array.isArray(charge.gymnasts)
      ? charge.gymnasts[0]
      : charge.gymnasts;
    const level = Array.isArray(gymnast?.levels) ? gymnast?.levels[0] : gymnast?.levels;
    const billing = Array.isArray(gymnast?.gymnast_billing_profiles)
      ? gymnast?.gymnast_billing_profiles[0]
      : gymnast?.gymnast_billing_profiles;
    const name = `${gymnast?.first_name ?? ""} ${gymnast?.last_name ?? ""}`.trim();
    const paid = charge.payment_allocations.reduce(
      (total, allocation) => total + Number(allocation.amount_cents),
      0,
    );
    const current = accounts.get(charge.gymnast_id) ?? {
      id: charge.gymnast_id,
      name: name || "Gimnasta",
      charged: 0,
      paid: 0,
      overdue: 0,
      status: gymnast?.status ?? "active",
      nextDue: null,
      cycleStart: null,
      program: billing?.program ?? "Sin programa",
      level: level?.name ?? "Sin nivel",
    };
    current.charged += Number(charge.amount_cents);
    current.paid += paid;
    if (charge.due_on < today) {
      current.overdue += Math.max(0, Number(charge.amount_cents) - paid);
    }
    if (Number(charge.amount_cents) - paid > 0) {
      if (!current.nextDue || charge.due_on < current.nextDue) {
        current.nextDue = charge.due_on;
        current.cycleStart = charge.period_starts_on;
      }
    }
    accounts.set(charge.gymnast_id, current);
  }

  const normalizedQuery = q.trim().toLocaleLowerCase("es");
  const allRows = [...accounts.values()];
  const availablePrograms = [...new Set(allRows.map((account) => account.program))]
    .filter((value) => value !== "Sin programa")
    .sort((a, b) => a.localeCompare(b, "es"));
  const availableLevels = [...new Set(allRows.map((account) => account.level))]
    .filter((value) => value !== "Sin nivel")
    .sort((a, b) => a.localeCompare(b, "es", { numeric: true }));
  const rows = allRows
    .filter((account) => account.name.toLocaleLowerCase("es").includes(normalizedQuery))
    .filter((account) => !program || account.program === program)
    .filter((account) => !levelFilter || account.level === levelFilter)
    .filter((account) => {
      const balance = account.charged - account.paid;
      if (view === "overdue") return account.overdue > 0;
      if (view === "paid") return balance === 0;
      if (view === "future") return balance > 0 && Boolean(account.nextDue && account.nextDue >= today);
      if (view === "active") return account.status === "active";
      if (view === "paused") return account.status === "suspended";
      if (view === "all") return true;
      return balance > 0;
    })
    .sort((a, b) => (b.charged - b.paid) - (a.charged - a.paid));
  const pendingTotal = allRows.reduce(
    (total, account) => total + account.charged - account.paid,
    0,
  );
  const overdueTotal = allRows.reduce((total, account) => total + account.overdue, 0);
  const chargedTotal = allRows.reduce((total, account) => total + account.charged, 0);
  const paidTotal = allRows.reduce((total, account) => total + account.paid, 0);
  const tagClass = (value: string, prefix: string) =>
    `${prefix}-${value.normalize("NFD").replace(/\p{Diacritic}/gu, "")
      .toLowerCase().replace(/\s+/g, "-")}`;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Administración financiera</p>
          <h1>Cartera y pagos</h1>
          <p>Consulta saldos, crea cobros y registra abonos por deportista.</p>
        </div>
        <div className="header-actions">
          <Link href="/pagos/frecuencias" className="secondary-button">Configurar frecuencias</Link>
          <Link href="/pagos/tarifas" className="secondary-button">Ver tarifas 2026</Link>
          <Link href="/pagos/nuevo" className="primary-button">＋ Nuevo cargo</Link>
        </div>
      </header>

      <section className="module-content">
        {(archivedCount ?? 0) > 0 && (
          <div className="notion-import-banner">
            <div>
              <strong>Historial de Notion importado</strong>
              <span>{archivedCount} registros originales conservados · {exceptionCount ?? 0} pendientes de asociación</span>
            </div>
            <Link href="/pagos/historial-notion">Consultar archivo →</Link>
          </div>
        )}
        <div className="finance-summary">
          <article>
            <span>Histórico cobrado</span>
            <strong>{money(chargedTotal)}</strong>
            <small>Suma de todos los cargos importados y nuevos</small>
          </article>
          <article>
            <span>Histórico abonado</span>
            <strong>{money(paidTotal)}</strong>
            <small>Pagos aplicados a esos cargos</small>
          </article>
          <article>
            <span>Cartera pendiente</span>
            <strong>{money(pendingTotal)}</strong>
            <small>Saldo total por recaudar</small>
          </article>
          <article className="overdue">
            <span>Cartera vencida</span>
            <strong>{money(overdueTotal)}</strong>
            <small>Cargos que pasaron su fecha límite</small>
          </article>
          <article>
            <span>Deportistas con cobros</span>
            <strong>{rows.length}</strong>
            <small>Estados de cuenta creados</small>
          </article>
        </div>

        <form className="search-form finance-filters" method="get">
          <input name="q" defaultValue={q} placeholder="Buscar por nombre de la deportista" />
          <select name="program" defaultValue={program} aria-label="Filtrar por programa">
            <option value="">Todos los programas</option>
            {availablePrograms.map((item) => <option value={item} key={item}>{item}</option>)}
          </select>
          <select name="level" defaultValue={levelFilter} aria-label="Filtrar por nivel">
            <option value="">Todos los niveles</option>
            {availableLevels.map((item) => <option value={item} key={item}>{item}</option>)}
          </select>
          <input type="hidden" name="view" value={view} />
          <button type="submit">Aplicar</button>
          {(q || program || levelFilter) && <Link href={`/pagos?view=${view}`}>Limpiar</Link>}
        </form>

        <nav className="payment-views" aria-label="Vistas de cartera">
          {[
            ["collect", "Por cobrar"],
            ["overdue", "Vencidas"],
            ["paid", "Al día"],
            ["future", "Ciclos futuros"],
            ["active", "Activas"],
            ["paused", "Pausadas"],
            ["all", "Todas"],
          ].map(([key, label]) => (
            <Link
              className={view === key ? "active" : ""}
              href={{
                pathname: "/pagos",
                query: {
                  view: key,
                  ...(q ? { q } : {}),
                  ...(program ? { program } : {}),
                  ...(levelFilter ? { level: levelFilter } : {}),
                },
              }}
              key={key}
            >
              {label}
            </Link>
          ))}
        </nav>

        {error ? (
          <div className="data-panel table-empty">No pudimos cargar la cartera.</div>
        ) : rows.length === 0 ? (
          <div className="data-panel table-empty">
            <span>$</span>
            <h3>{q ? "No encontramos coincidencias" : "Aún no hay cobros"}</h3>
            <p>{q ? "Prueba buscando otro nombre." : "Crea una mensualidad u otro cargo para comenzar."}</p>
            {!q && <Link href="/pagos/nuevo">Crear primer cargo</Link>}
          </div>
        ) : (
          <div className="data-panel">
            <div className="data-panel-heading">
              <div><span className="section-kicker">Estados de cuenta</span><h2>{rows.length} deportistas</h2></div>
            </div>
            <div className="finance-table">
              <div className="finance-row finance-head">
                <span>Deportista</span><span>Programa</span><span>Nivel</span><span>Estado</span><span>Inicio</span><span>Vencimiento</span><span>Saldo</span>
              </div>
              {rows.map((account) => {
                const balance = account.charged - account.paid;
                return (
                  <Link href={`/pagos/${account.id}`} className="finance-row" key={account.id}>
                    <strong>{account.name}</strong>
                    <span><i className={`notion-tag ${tagClass(account.program, "program")}`}>{account.program}</i></span>
                    <span><i className={`notion-tag ${tagClass(account.level, "level")}`}>{account.level}</i></span>
                    <span className={`finance-status ${balance === 0 ? "paid" : account.overdue > 0 ? "late" : "pending"}`}>
                      {balance === 0 ? "Al día" : account.overdue > 0 ? "Vencido" : "Pendiente"}
                    </span>
                    <span>{account.cycleStart ? new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(account.cycleStart)) : "—"}</span>
                    <strong>{account.nextDue ? new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(account.nextDue)) : "Sin deuda"}</strong>
                    <strong>{money(balance)}</strong>
                  </Link>
                );
              })}
            </div>
          </div>
        )}
      </section>
    </main>
  );
}
