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

const dateLabel = (date: string | null) =>
  date
    ? new Intl.DateTimeFormat("es-CO", {
        day: "numeric",
        month: "short",
        year: "numeric",
        timeZone: "UTC",
      }).format(new Date(date))
    : "Sin registrar";

type Charge = {
  id: string;
  gymnast_id: string;
  concept: string;
  category: string;
  description: string | null;
  amount_cents: number;
  due_on: string;
  period_starts_on: string | null;
  period_ends_on: string | null;
  gymnasts:
    | { first_name: string; last_name: string; status: string }
    | Array<{ first_name: string; last_name: string; status: string }>
    | null;
  payment_allocations: Array<{ amount_cents: number }>;
};

type Account = {
  id: string;
  name: string;
  status: string;
  charged: number;
  paid: number;
  overdue: number;
  nextDue: string | null;
  cycleStart: string | null;
  cycleEnd: string | null;
  debts: Array<{
    concept: string;
    category: string;
    description: string | null;
    balance: number;
    dueOn: string;
  }>;
};

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
    supabase.from("notion_financial_archive").select("*", { count: "exact", head: true }),
    supabase.from("notion_import_exceptions").select("*", { count: "exact", head: true }),
  ]);

  const accounts = new Map<string, Account>();
  const today = new Date().toISOString().slice(0, 10);

  for (const charge of (data ?? []) as Charge[]) {
    const gymnast = Array.isArray(charge.gymnasts) ? charge.gymnasts[0] : charge.gymnasts;
    const paid = charge.payment_allocations.reduce(
      (total, allocation) => total + Number(allocation.amount_cents),
      0,
    );
    const balance = Math.max(0, Number(charge.amount_cents) - paid);
    const current = accounts.get(charge.gymnast_id) ?? {
      id: charge.gymnast_id,
      name: `${gymnast?.first_name ?? ""} ${gymnast?.last_name ?? ""}`.trim() || "Gimnasta",
      status: gymnast?.status ?? "active",
      charged: 0,
      paid: 0,
      overdue: 0,
      nextDue: null,
      cycleStart: null,
      cycleEnd: null,
      debts: [],
    };
    current.charged += Number(charge.amount_cents);
    current.paid += paid;
    if (charge.due_on < today) current.overdue += balance;
    if (balance > 0) {
      current.debts.push({
        concept: charge.concept,
        category: charge.category,
        description: charge.description,
        balance,
        dueOn: charge.due_on,
      });
      if (!current.nextDue || charge.due_on < current.nextDue) {
        current.nextDue = charge.due_on;
        current.cycleStart = charge.period_starts_on;
        current.cycleEnd = charge.period_ends_on;
      }
    }
    accounts.set(charge.gymnast_id, current);
  }

  const allRows = [...accounts.values()];
  const balanceOf = (account: Account) => account.charged - account.paid;
  const counts = {
    collect: allRows.filter((account) => balanceOf(account) > 0).length,
    overdue: allRows.filter((account) => account.overdue > 0).length,
    paid: allRows.filter((account) => balanceOf(account) === 0).length,
    future: allRows.filter(
      (account) => balanceOf(account) > 0 && Boolean(account.nextDue && account.nextDue >= today),
    ).length,
    paused: allRows.filter((account) => account.status === "suspended").length,
    all: allRows.length,
  };
  const normalizedQuery = q.trim().toLocaleLowerCase("es");
  const rows = allRows
    .filter((account) => account.name.toLocaleLowerCase("es").includes(normalizedQuery))
    .filter((account) => {
      const balance = balanceOf(account);
      if (view === "overdue") return account.overdue > 0;
      if (view === "paid") return balance === 0;
      if (view === "future") return balance > 0 && Boolean(account.nextDue && account.nextDue >= today);
      if (view === "paused") return account.status === "suspended";
      if (view === "all") return true;
      return balance > 0;
    })
    .sort((a, b) => {
      if (a.overdue > 0 && b.overdue === 0) return -1;
      if (b.overdue > 0 && a.overdue === 0) return 1;
      return balanceOf(b) - balanceOf(a);
    });

  const pendingTotal = allRows.reduce((total, account) => total + balanceOf(account), 0);
  const overdueTotal = allRows.reduce((total, account) => total + account.overdue, 0);
  const paidTotal = allRows.reduce((total, account) => total + account.paid, 0);
  const views: Array<[keyof typeof counts, string]> = [
    ["collect", "Por cobrar"],
    ["overdue", "Vencidas"],
    ["paid", "Al día"],
    ["future", "Ciclos futuros"],
    ["paused", "Pausadas"],
    ["all", "Todas"],
  ];

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Administración financiera</p>
          <h1>Control de cartera</h1>
          <p>Revisa lo que debe cada gimnasta y registra sus pagos y abonos.</p>
        </div>
        <div className="header-actions">
          <Link href="/pagos/mensajes" className="secondary-button">Mensajes de cobro</Link>
          <Link href="/pagos/tarifas" className="secondary-button">Tarifas</Link>
          <Link href="/pagos/nuevo" className="primary-button">＋ Nuevo movimiento</Link>
        </div>
      </header>

      <section className="module-content">
        <div className={styles.summary}>
          <article className={styles.primarySummary}>
            <span>Saldo total pendiente</span>
            <strong>{money(pendingTotal)}</strong>
            <small>{counts.collect} gimnastas por cobrar</small>
          </article>
          <article className={styles.lateSummary}>
            <span>Cartera vencida</span>
            <strong>{money(overdueTotal)}</strong>
            <small>{counts.overdue} requieren seguimiento</small>
          </article>
          <article className={styles.paidSummary}>
            <span>Total recibido</span>
            <strong>{money(paidTotal)}</strong>
            <small>Pagos y abonos registrados</small>
          </article>
        </div>

        {(archivedCount ?? 0) > 0 && (
          <div className={styles.archiveNotice}>
            <div>
              <strong>Historial original de Notion</strong>
              <span>{archivedCount} movimientos conservados · {exceptionCount ?? 0} por revisar</span>
            </div>
            <Link href="/pagos/historial-notion">Consultar archivo →</Link>
          </div>
        )}

        <section className={styles.workspace}>
          <div className={styles.toolbar}>
            <nav className={styles.views} aria-label="Vistas de cartera">
              {views.map(([key, label]) => (
                <Link
                  className={view === key ? styles.activeView : ""}
                  href={`/pagos?view=${key}`}
                  key={key}
                >
                  {label}<span>{counts[key]}</span>
                </Link>
              ))}
            </nav>
            <form className={styles.search} method="get">
              <input name="q" defaultValue={q} placeholder="Buscar gimnasta…" />
              <input type="hidden" name="view" value={view} />
              <button type="submit">Buscar</button>
            </form>
          </div>

          <div className={styles.titleRow}>
            <div>
              <span className="section-kicker">Estados de cuenta</span>
              <h2>{rows.length} gimnastas</h2>
            </div>
            <Link href="/pagos/nuevo">＋ Agregar cargo</Link>
          </div>

          {error ? (
            <div className="table-empty">No pudimos cargar la cartera.</div>
          ) : rows.length === 0 ? (
            <div className="table-empty">
              <span>$</span>
              <h3>{q ? "No encontramos coincidencias" : "Esta vista está vacía"}</h3>
              <p>{q ? "Prueba buscando otro nombre." : "No hay cuentas con este estado."}</p>
            </div>
          ) : (
            <div className={styles.accounts}>
              {rows.map((account) => {
                const balance = balanceOf(account);
                const state = balance === 0 ? "paid" : account.overdue > 0 ? "late" : "pending";
                return (
                  <details className={styles.account} key={account.id}>
                    <summary>
                      <span className={styles.person}>
                        <i>{account.name.charAt(0)}</i>
                        <span>
                          <strong>{account.name}</strong>
                          <span className={styles.personMeta}>
                            <small className={styles[state]}>
                              {state === "paid" ? "Al día" : state === "late" ? "Pago vencido" : "Pago pendiente"}
                            </small>
                            <small>{account.debts.length} {account.debts.length === 1 ? "cargo" : "cargos"}</small>
                          </span>
                        </span>
                      </span>
                      <span className={styles.due}>
                        <small>{account.nextDue && account.nextDue < today ? "Venció el" : "Próximo vencimiento"}</small>
                        <strong>{account.nextDue ? dateLabel(account.nextDue) : "Sin deuda"}</strong>
                      </span>
                      <span className={styles.balance}>
                        <small>Saldo total</small>
                        <strong>{money(balance)}</strong>
                      </span>
                      <i className={styles.chevron} aria-hidden="true">⌄</i>
                    </summary>

                    <div className={styles.detail}>
                      <div className={styles.detailHeading}>
                        <div>
                          <span className="section-kicker">Detalle de la cuenta</span>
                          <h3>{account.debts.length ? "¿Qué debe?" : "Sin cargos pendientes"}</h3>
                        </div>
                        <span><small>Total abonado</small><strong>{money(account.paid)}</strong></span>
                      </div>
                      <div className={styles.breakdown}>
                        {account.debts.length === 0 ? (
                          <p>Esta gimnasta no tiene cargos pendientes.</p>
                        ) : account.debts.map((debt, index) => (
                          <div className={styles.debtLine} key={`${debt.concept}-${index}`}>
                            <i className={`${styles.debtIcon} ${styles[debt.category] ?? ""}`}>
                              {debt.category === "monthly_fee" ? "4S" : debt.category === "product" ? "□" : debt.category === "competition" ? "★" : "+"}
                            </i>
                            <span>
                              <strong>{debt.concept}</strong>
                              {debt.description && <small>{debt.description}</small>}
                              <small className={debt.dueOn < today ? styles.debtLate : ""}>
                                {debt.dueOn < today ? "Venció" : "Vence"} {dateLabel(debt.dueOn)}
                              </small>
                            </span>
                            <span className={styles.debtAmount}><small>Por pagar</small><b>{money(debt.balance)}</b></span>
                          </div>
                        ))}
                      </div>
                      {(account.cycleStart || account.cycleEnd) && (
                        <div className={styles.cycleStrip}>
                          <span>Ciclo actual</span>
                          <strong>{dateLabel(account.cycleStart)} → {dateLabel(account.cycleEnd)}</strong>
                        </div>
                      )}
                      <div className={styles.actions}>
                        <Link href={`/pagos/${account.id}`}>Ver movimientos</Link>
                        <Link href={`/pagos/${account.id}`} className={styles.payButton}>
                          ＋ Registrar pago o abono
                        </Link>
                      </div>
                    </div>
                  </details>
                );
              })}
            </div>
          )}
        </section>
      </section>
    </main>
  );
}
