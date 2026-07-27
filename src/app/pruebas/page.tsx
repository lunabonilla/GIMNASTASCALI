import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { updateTrialStatus } from "./actions";

const statusLabels: Record<string, string> = {
  scheduled: "Programada",
  attended: "Asistió",
  no_show: "No asistió",
  cancelled: "Cancelada",
  converted: "Inscrita",
};

export default async function TrialsPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; updated?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const messages = await searchParams;
  const { data, error } = await supabase
    .from("trial_bookings")
    .select("id, prospect_first_name, prospect_last_name, birth_date, guardian_name, guardian_phone, scheduled_for, status")
    .order("scheduled_for");
  const trials = (data ?? []) as Array<{
    id: string;
    prospect_first_name: string;
    prospect_last_name: string;
    birth_date: string;
    guardian_name: string;
    guardian_phone: string;
    scheduled_for: string;
    status: string;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Nuevas familias</p>
          <h1>Clases de prueba</h1>
          <p>Agenda visitas y acompaña el proceso hasta la inscripción.</p>
        </div>
        <Link href="/pruebas/nueva" className="primary-button">＋ Nueva clase de prueba</Link>
      </header>
      <section className="module-content">
        {messages.created && <div className="success-banner">✓ Clase de prueba agendada.</div>}
        {messages.updated && <div className="success-banner">✓ Estado actualizado.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}
        {error ? (
          <div className="data-panel table-empty">No pudimos cargar la agenda.</div>
        ) : trials.length === 0 ? (
          <div className="data-panel table-empty">
            <span>◇</span><h3>No hay clases de prueba</h3>
            <p>Agenda la primera visita de una familia interesada.</p>
            <Link href="/pruebas/nueva">Agendar clase</Link>
          </div>
        ) : (
          <div className="trial-list">
            {trials.map((trial) => {
              const scheduled = new Date(trial.scheduled_for);
              return (
                <article className="trial-card" key={trial.id}>
                  <div className="trial-date">
                    <strong>{new Intl.DateTimeFormat("es-CO", { day: "2-digit", timeZone: "America/Bogota" }).format(scheduled)}</strong>
                    <span>{new Intl.DateTimeFormat("es-CO", { month: "short", timeZone: "America/Bogota" }).format(scheduled)}</span>
                    <small>{new Intl.DateTimeFormat("es-CO", { hour: "numeric", minute: "2-digit", timeZone: "America/Bogota" }).format(scheduled)}</small>
                  </div>
                  <div className="trial-person">
                    <h2>{trial.prospect_first_name} {trial.prospect_last_name}</h2>
                    <p>Responsable: {trial.guardian_name} · {trial.guardian_phone}</p>
                  </div>
                  <span className={`trial-status ${trial.status}`}>{statusLabels[trial.status]}</span>
                  <form action={updateTrialStatus}>
                    <input type="hidden" name="trial_id" value={trial.id} />
                    <select name="status" defaultValue={trial.status}>
                      <option value="scheduled">Programada</option>
                      <option value="attended">Asistió</option>
                      <option value="no_show">No asistió</option>
                      <option value="cancelled">Cancelada</option>
                    </select>
                    <button type="submit">Guardar</button>
                  </form>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
