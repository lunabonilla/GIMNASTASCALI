import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import styles from "./page.module.css";

const date = (value: string | null) => value
  ? new Intl.DateTimeFormat("es-CO", {
      day: "numeric", month: "short", year: "numeric", timeZone: "UTC",
    }).format(new Date(`${value}T00:00:00Z`))
  : "Por definir";

const statusLabels: Record<string, string> = {
  confirmed: "Confirmada",
  defining: "En definición",
  cancelled: "Cancelada",
  completed: "Realizada",
};

export default async function CompetitionsPage() {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { data, error } = await supabase.from("competitions")
    .select("*").order("starts_on", { nullsFirst: false });
  const competitions = data ?? [];
  const today = new Date().toISOString().slice(0, 10);
  const upcoming = competitions.filter((item) => !item.ends_on || item.ends_on >= today);
  const past = competitions.filter((item) => item.ends_on && item.ends_on < today);

  const renderCards = (items: typeof competitions) => (
    <div className={styles.grid}>
      {items.map((competition) => (
        <article className={styles.card} key={competition.id}>
          <div className={styles.cardTop}>
            <span className={`${styles.status} ${styles[competition.status]}`}>{statusLabels[competition.status]}</span>
            <strong>{competition.year || "Año pendiente"}</strong>
          </div>
          <h2>{competition.name}</h2>
          <p className={styles.place}>⌖ {[competition.city, competition.country].filter(Boolean).join(", ") || competition.venue || "Lugar por definir"}</p>
          <dl>
            <div><dt>Fecha</dt><dd>{date(competition.starts_on)}{competition.ends_on && competition.ends_on !== competition.starts_on ? ` → ${date(competition.ends_on)}` : ""}</dd></div>
            <div><dt>Inscripción</dt><dd>{date(competition.registration_deadline_1)}</dd></div>
            <div><dt>Costo</dt><dd>{competition.estimated_cost_cents === null ? "Pendiente por confirmar" : new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(competition.estimated_cost_cents / 100)}</dd></div>
          </dl>
          {competition.notes && <p className={styles.note}>{competition.notes}</p>}
          <small className={styles.source}>Fuente: {competition.source_name || "Registro interno"}</small>
        </article>
      ))}
    </div>
  );

  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <div>
          <Link href="/" className={styles.back}>← Volver al inicio</Link>
          <p className={styles.eyebrow}>Calendario deportivo</p>
          <h1>Competencias</h1>
          <p>Fechas, sedes, inscripciones y costos para informar a las familias.</p>
        </div>
      </header>
      <section className={styles.content}>
        {error ? <div className="error-banner">No pudimos cargar las competencias.</div> : (
          <>
            <div className={styles.sectionHeading}><div><span>Próximas</span><h2>{upcoming.length} competencias y eventos</h2></div></div>
            {renderCards(upcoming)}
            {past.length > 0 && <><div className={`${styles.sectionHeading} ${styles.pastHeading}`}><div><span>Histórico</span><h2>Eventos anteriores</h2></div></div>{renderCards(past)}</>}
          </>
        )}
      </section>
    </main>
  );
}
