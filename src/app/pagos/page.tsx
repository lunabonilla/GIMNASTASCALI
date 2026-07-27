import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import styles from "./page.module.css";

const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function PaymentsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; view?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { q = "", view = "collect" } = await searchParams;
  const [
    { data, error },
    { count: archivedCount },
    { count: exceptionCount },
  ] = await Promise.all([
    supabase
      .from("billing_charges")
      .select("id, gymnast_id, concept, category, description, amount_cents, due_on, period_starts_on, period_ends_on, voided_at, gymnasts(first_name, last_name, status), payment_allocations(amount_cents)")
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
    concept: string;
    category: string;
    description: string | null;
    amount_cents: number;
    due_on: string;
    gymnasts:
      | {
          first_name: string; last_name: string; status: string;
        }
      | Array<{
          first_name: string; last_name: string; status: string;
        }>
      | null;
    period_starts_on: string | null;
    period_ends_on: string | null;
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
    debts: Array<{
      concept: string;
      category: string;
      description: string | null;
      balance: number;
    }>;
  }>();
  const today = new Date().toISOString().slice(0, 10);

  for (const charge of charges) {
    const gymnast = Array.isArray(charge.gymnasts)
      ? charge.gymnasts[0]
      : charge.gymnasts;
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
      debts: [],
    };
    current.charged += Number(charge.amount_cents);
    current.paid += paid;
    if (charge.due_on < today) {
      current.overdue += Math.max(0, Number(charge.amount_cents) - paid);
    }
    const chargeBalance = Number(charge.amount_cents) - paid;
    if (chargeBalance > 0) {
      current.debts.push({
        concept: charge.concept,
        category: charge.category,
        description: charge.description,
        balance: chargeBalance,
      });
      if (!current.nextDue || charge.due_on < current.nextDue) {
        current.nextDue = charge.due_on;
        current.cycleStart = charge.period_starts_on;
      }
    }
    accounts.set(charge.gymnast_id, current);
  }

  const normalizedQuery = q.trim().toLocaleLowerCase("es");
  const allRows = [...accounts.values()];
  const rows = allRows
    .filter((account) => account.name.toLocaleLowerCase("es").includes(normalizedQuery))
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
  const paidTotal = allRows.reduce((total, account) => total + account.paid, 0);
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
          <Link href="/pagos/mensajes" className="secondary-button">Copiar mensajes de cobro</Link>
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
            <span>Total por cobrar</span>
            <strong>{money(pendingTotal)}</strong>
            <small>Todos los saldos pendientes</small>
          </article>
          <article className="overdue">
            <span>Ya se venció</span>
            <strong>{money(overdueTotal)}</strong>
            <small>Requiere gestión de cobro</small>
          </article>
          <article>
            <span>Total recibido</span>
            <strong>{money(paidTotal)}</strong>
            <small>Abonos y pagos registrados</small>
          </article>
        </div>

        <form className="search-form" method="get">
          <input name="q" defaultValue={q} placeholder="Buscar por nombre de la deportista" />
          <input type="hidden" name="view" value={view} />
          <button type="submit">Buscar</button>
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
            <Link className={view === key ? "active" : ""} href={`/pagos?view=${key}`} key={key}>
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
              <div><span className="section-kicker">Vista resumida</span><h2>{rows.length} estados de cuenta</h2></div>
            </div>
            <div className="finance-table">
              <div className={`${styles.financeRow} finance-head`}>
                <span>Deportista y estado</span><span>Qué debe</span><span>Ciclo</span><span>Saldo total</span>
              </div>
              {rows.map((account) => {
                const balance = account.charged - account.paid;
                return (
                  <Link href={`/pagos/${account.id}`} className={styles.financeRow} key={account.id}>
                    <span className={styles.accountName}>
                      <strong>{account.name}</strong>
                      <span className={`finance-status ${balance === 0 ? "paid" : account.overdue > 0 ? "late" : "pending"}`}>
                        {balance === 0 ? "Al día" : account.overdue > 0 ? "Vencido" : "Pendiente"}
                      </span>
                    </span>
                    <span className={styles.debtList}>
                      {account.debts.length === 0 ? (
                        <small>Sin cargos pendientes</small>
                      ) : (
                        <>
                          {account.debts.slice(0, 3).map((debt, index) => (
                            <span className={`${styles.debtTag} ${styles[debt.category] ?? ""}`} key={`${debt.concept}-${index}`}>
                              <span>
                                <strong>{debt.concept}</strong>
                                {debt.description && <small>{debt.description}</small>}
                              </span>
                              <b>{money(debt.balance)}</b>
                            </span>
                          ))}
                          {account.debts.length > 3 && (
                            <small className={styles.moreDebts}>＋ {account.debts.length - 3} cargos adicionales</small>
                          )}
                        </>
                      )}
                    </span>
                    <span className={styles.cycle}>
                      <small>Inició</small>
                      <strong>{account.cycleStart ? new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(account.cycleStart)) : "Sin registrar"}</strong>
                      <small>Vence</small>
                      <strong>{account.nextDue ? new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeZone: "UTC" }).format(new Date(account.nextDue)) : "Sin deuda"}</strong>
                    </span>
                    <span className={styles.balance}><strong>{money(balance)}</strong><small>Ver movimientos →</small></span>
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
