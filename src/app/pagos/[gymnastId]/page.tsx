import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { registerPayment } from "../actions";

const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
  }).format(cents / 100);

const categoryLabels: Record<string, string> = {
  monthly_fee: "Mensualidad",
  extra_class: "Clase extra",
  private_class: "Personalizado",
  product: "Artículo",
  competition: "Competencia",
  other: "Otro",
};
const conceptClass = (concept: string) =>
  `charge-concept-${concept.normalize("NFD").replace(/\p{Diacritic}/gu, "")
    .toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "")}`;

export default async function AccountPage({
  params,
  searchParams,
}: {
  params: Promise<{ gymnastId: string }>;
  searchParams: Promise<{ created?: string; paid?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { gymnastId } = await params;
  const messages = await searchParams;

  const [{ data: gymnast }, { data }] = await Promise.all([
    supabase
      .from("gymnasts")
      .select("id, first_name, last_name")
      .eq("id", gymnastId)
      .single(),
    supabase
      .from("billing_charges")
      .select("id, concept, category, description, issued_on, due_on, amount_cents, voided_at, payment_allocations(amount_cents, payments(id, paid_on, payment_method, reference))")
      .eq("gymnast_id", gymnastId)
      .is("voided_at", null)
      .order("due_on", { ascending: false }),
  ]);
  if (!gymnast) notFound();

  const charges = (data ?? []) as Array<{
    id: string;
    concept: string;
    category: string;
    description: string | null;
    issued_on: string;
    due_on: string;
    amount_cents: number;
    payment_allocations: Array<{
      amount_cents: number;
      payments: Array<{
        id: string; paid_on: string; payment_method: string; reference: string | null;
      }> | null;
    }>;
  }>;
  const charged = charges.reduce((total, charge) => total + Number(charge.amount_cents), 0);
  const paid = charges.reduce(
    (total, charge) =>
      total + charge.payment_allocations.reduce(
        (subtotal, allocation) => subtotal + Number(allocation.amount_cents),
        0,
      ),
    0,
  );
  const today = new Date().toISOString().slice(0, 10);

  return (
    <main className="module-page">
      <header className="module-header account-header">
        <div>
          <Link href="/pagos" className="back-link">← Volver a cartera</Link>
          <p className="eyebrow">Estado de cuenta</p>
          <h1>{gymnast.first_name} {gymnast.last_name}</h1>
          <p>Cargos, abonos y saldos de la deportista.</p>
        </div>
        <Link href={`/pagos/nuevo?gymnast=${gymnastId}`} className="primary-button">＋ Nuevo cargo</Link>
      </header>

      <section className="module-content">
        {messages.created && <div className="success-banner">✓ Cargo creado correctamente.</div>}
        {messages.paid && <div className="success-banner">✓ Pago registrado y aplicado al saldo.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}

        <div className="account-totals">
          <div><span>Total cobrado</span><strong>{money(charged)}</strong></div>
          <div><span>Total abonado</span><strong>{money(paid)}</strong></div>
          <div className="balance"><span>Saldo pendiente</span><strong>{money(charged - paid)}</strong></div>
        </div>

        {charges.length === 0 ? (
          <div className="data-panel table-empty">
            <span>$</span><h3>No hay movimientos</h3>
            <p>Crea el primer cargo para esta deportista.</p>
            <Link href={`/pagos/nuevo?gymnast=${gymnastId}`}>Crear cargo</Link>
          </div>
        ) : (
          <div className="charge-list">
            {charges.map((charge) => {
              const chargePaid = charge.payment_allocations.reduce(
                (total, allocation) => total + Number(allocation.amount_cents),
                0,
              );
              const balance = Number(charge.amount_cents) - chargePaid;
              const isLate = charge.due_on < today && balance > 0;
              return (
                <article className="charge-card" key={charge.id}>
                  <div className="charge-main">
                    <div>
                      <span className="section-kicker">{categoryLabels[charge.category] ?? "Cargo"}</span>
                      <h2><span className={`charge-concept ${conceptClass(charge.concept)}`}>{charge.concept}</span></h2>
                      {charge.description && <p className="charge-description">{charge.description}</p>}
                      <p>Vence: {new Intl.DateTimeFormat("es-CO", { dateStyle: "long", timeZone: "UTC" }).format(new Date(`${charge.due_on}T00:00:00Z`))}</p>
                    </div>
                    <div className="charge-amount">
                      <strong>{money(Number(charge.amount_cents))}</strong>
                      <span className={`finance-status ${balance === 0 ? "paid" : isLate ? "late" : "pending"}`}>
                        {balance === 0 ? "Pagado" : isLate ? "Vencido" : "Pendiente"}
                      </span>
                    </div>
                  </div>
                  <div className="charge-progress">
                    <span>Abonado: {money(chargePaid)}</span>
                    <strong>Saldo: {money(balance)}</strong>
                  </div>
                  {charge.payment_allocations.length > 0 && (
                    <div className="payment-history">
                      {charge.payment_allocations.map((allocation, index) => (
                        <div key={`${charge.id}-${index}`}>
                          <span>✓ Abono del {allocation.payments?.[0]?.paid_on ?? "día registrado"}</span>
                          <strong>{money(Number(allocation.amount_cents))}</strong>
                        </div>
                      ))}
                    </div>
                  )}
                  {balance > 0 && (
                    <details className="payment-box">
                      <summary>＋ Registrar abono</summary>
                      <form action={registerPayment} className="inline-payment-form">
                        <input type="hidden" name="gymnast_id" value={gymnastId} />
                        <input type="hidden" name="charge_id" value={charge.id} />
                        <label>Valor en pesos<input name="amount" inputMode="numeric" placeholder={String(balance / 100)} required /></label>
                        <label>Fecha<input type="date" name="paid_on" defaultValue={today} required /></label>
                        <label>Medio<select name="payment_method" defaultValue="transfer"><option value="transfer">Transferencia</option><option value="cash">Efectivo</option><option value="card">Tarjeta</option><option value="other">Otro</option></select></label>
                        <label>Referencia<input name="reference" placeholder="Opcional" /></label>
                        <label className="full-field">Notas<input name="notes" placeholder="Observaciones del pago" /></label>
                        <button type="submit" className="primary-button">Guardar pago</button>
                      </form>
                    </details>
                  )}
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
