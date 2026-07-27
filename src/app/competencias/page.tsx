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

export default async function CompetitionsPage({
  searchParams,
}: {
  searchParams: Promise<{ view?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { data, error } = await supabase.from("competitions")
    .select("*").order("starts_on", { nullsFirst: false });
  const competitions = data ?? [];
  const { view = "upcoming" } = await searchParams;
  const today = new Date().toISOString().slice(0, 10);
  const upcoming = competitions.filter((item) => !item.ends_on || item.ends_on >= today);
  const past = competitions.filter((item) => item.ends_on && item.ends_on < today);
  const visible = view === "confirmed"
    ? upcoming.filter((item) => item.status === "confirmed")
    : view === "defining"
      ? upcoming.filter((item) => item.status === "defining")
      : view === "past"
        ? past
        : upcoming;

  const renderRows = (items: typeof competitions) => (
    <div className={styles.database}>
      <div className={styles.tableHead}>
        <span>Competencia</span>
        <span>Estado</span>
        <span>Fecha</span>
        <span>Sede</span>
        <span>Inscripción</span>
        <span>Costo</span>
      </div>
      {items.map((competition) => (
        <article className={styles.tableRow} key={competition.id}>
          <div className={styles.nameCell}>
            <span className={styles.pageIcon}>🏆</span>
            <div>
              <strong>{competition.name}</strong>
              <small>{competition.year || "Año por definir"} · {competition.source_name || "Registro interno"}</small>
            </div>
          </div>
          <div data-label="Estado"><span className={`${styles.status} ${styles[competition.status]}`}>{statusLabels[competition.status]}</span></div>
          <div data-label="Fecha" className={styles.dateCell}>
            <strong>{date(competition.starts_on)}</strong>
            {competition.ends_on && competition.ends_on !== competition.starts_on && <small>hasta {date(competition.ends_on)}</small>}
          </div>
          <div data-label="Sede">
            <strong>{[competition.city, competition.country].filter(Boolean).join(", ") || "Por definir"}</strong>
            {competition.venue && <small>{competition.venue}</small>}
          </div>
          <div data-label="Inscripción" className={styles.dateCell}>
            <strong>{date(competition.registration_deadline_1)}</strong>
            {competition.registration_deadline_2 && <small>2.º plazo: {date(competition.registration_deadline_2)}</small>}
          </div>
          <div data-label="Costo">
            <strong>{competition.estimated_cost_cents === null ? "Por confirmar" : new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(competition.estimated_cost_cents / 100)}</strong>
          </div>
          {competition.notes && <p className={styles.rowNote}>{competition.notes}</p>}
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
            <nav className={styles.views} aria-label="Vistas de competencias">
              {[
                ["upcoming", "📅 Próximas", upcoming.length],
                ["confirmed", "✅ Confirmadas", upcoming.filter((item) => item.status === "confirmed").length],
                ["defining", "🟡 En definición", upcoming.filter((item) => item.status === "defining").length],
                ["past", "🗂 Histórico", past.length],
              ].map(([key, label, count]) => (
                <Link className={view === key ? styles.activeView : ""} href={`/competencias?view=${key}`} key={String(key)}>
                  {label} <span>{count}</span>
                </Link>
              ))}
            </nav>
            <div className={styles.sectionHeading}><div><span>Vista actual</span><h2>{visible.length} competencias y eventos</h2></div></div>
            {renderRows(visible)}
          </>
        )}
      </section>
    </main>
  );
}
