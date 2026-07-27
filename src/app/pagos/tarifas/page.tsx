import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function RatesPage() {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const [{ data: rates }, { data: fees }] = await Promise.all([
    supabase
      .from("billing_rate_plans")
      .select("id, program, days_per_week, class_duration_minutes, cycle_weeks, amount_cents")
      .eq("active", true)
      .eq("effective_year", 2026)
      .order("program")
      .order("days_per_week"),
    supabase
      .from("club_fee_settings")
      .select("fee_key, label, amount_cents, effective_from, notes")
      .order("effective_from"),
  ]);

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/pagos" className="back-link">← Volver a cartera</Link>
          <p className="eyebrow">Configuración financiera</p>
          <h1>Tarifas 2026</h1>
          <p>Valores oficiales del club para ciclos de cuatro semanas.</p>
        </div>
      </header>
      <section className="module-content">
        <div className="rate-grid">
          {(rates ?? []).map((rate) => (
            <article key={rate.id}>
              <span className="section-kicker">{rate.program}</span>
              <h2>{rate.days_per_week ? `${rate.days_per_week} día${rate.days_per_week > 1 ? "s" : ""} por semana` : "Entrenamiento intensivo"}</h2>
              <strong>{money(rate.amount_cents)}</strong>
              <p>
                {rate.class_duration_minutes
                  ? `Clases de ${rate.class_duration_minutes} minutos`
                  : "Programa integral"}
                {" · "}{rate.cycle_weeks} semanas
              </p>
            </article>
          ))}
        </div>
        <div className="fee-grid">
          {(fees ?? []).map((fee) => (
            <article key={fee.fee_key}>
              <div><span className="section-kicker">Tarifa adicional</span><h2>{fee.label}</h2><p>{fee.notes}</p></div>
              <strong>{money(fee.amount_cents)}</strong>
            </article>
          ))}
        </div>
        <div className="info-banner">
          Para calcular ciclos pendientes de Minis y Regular, cada gimnasta debe tener registrada su frecuencia de 1 o 2 días semanales.
        </div>
      </section>
    </main>
  );
}
