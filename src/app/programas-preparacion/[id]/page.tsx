import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { enrollGymnast } from "./actions";
import { PreparationAttendanceForm } from "./preparation-attendance-form";

const statusLabel: Record<string, string> = {
  attended: "✅ Asistió",
  absent: "❌ No asistió",
  double_class: "🔁 Clase doble",
};

export default async function PreparationProgramPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ session?: string; saved?: string; enrolled?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { id } = await params;
  const messages = await searchParams;
  const today = new Date().toISOString().slice(0, 10);
  const selectedDate = messages.session || today;

  const [
    { data: program },
    { data: enrollmentData },
    { data: gymnastData },
    { data: sessionData },
  ] = await Promise.all([
    supabase.from("preparation_programs")
      .select("id, name, description, status, starts_on, ends_on")
      .eq("id", id).single(),
    supabase.from("preparation_program_enrollments")
      .select("gymnast_id, status, gymnasts(id, first_name, last_name)")
      .eq("program_id", id).neq("status", "cancelled"),
    supabase.from("gymnasts")
      .select("id, first_name, last_name")
      .neq("status", "retired").order("first_name").order("last_name"),
    supabase.from("preparation_sessions")
      .select("id, session_on, preparation_attendance(gymnast_id, status)")
      .eq("program_id", id).order("session_on", { ascending: false }),
  ]);
  if (!program) notFound();

  const enrollments = (enrollmentData ?? []) as Array<{
    gymnast_id: string;
    gymnasts: { id: string; first_name: string; last_name: string }
      | Array<{ id: string; first_name: string; last_name: string }> | null;
  }>;
  const participants = enrollments.map((row) => {
    const gymnast = Array.isArray(row.gymnasts) ? row.gymnasts[0] : row.gymnasts;
    return gymnast;
  }).filter(Boolean) as Array<{ id: string; first_name: string; last_name: string }>;
  const participantIds = new Set(participants.map((item) => item.id));
  const available = (gymnastData ?? []).filter((item) => !participantIds.has(item.id));
  const sessions = (sessionData ?? []) as Array<{
    id: string;
    session_on: string;
    preparation_attendance: Array<{ gymnast_id: string; status: string }>;
  }>;
  const currentSession = sessions.find((item) => item.session_on === selectedDate);
  const currentStatuses = new Map(
    (currentSession?.preparation_attendance ?? []).map((item) => [item.gymnast_id, item.status]),
  );

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/programas-preparacion" className="back-link">← Volver a programas</Link>
          <p className="eyebrow">Lista y asistencia</p>
          <h1>{program.name}</h1>
          <p>{program.description || "Programa especial de preparación."}</p>
        </div>
        <span className={`preparation-status ${program.status}`}>{participants.length} participantes</span>
      </header>
      <section className="module-content">
        {messages.saved && <div className="success-banner">✓ Asistencia guardada.</div>}
        {messages.enrolled && <div className="success-banner">✓ Deportista agregada al programa.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}

        <div className="preparation-tools">
          <form action={enrollGymnast} className="add-participant-form">
            <input type="hidden" name="program_id" value={id} />
            <select name="gymnast_id" required defaultValue="">
              <option value="" disabled>Seleccionar deportista</option>
              {available.map((gymnast) => (
                <option value={gymnast.id} key={gymnast.id}>{gymnast.first_name} {gymnast.last_name}</option>
              ))}
            </select>
            <button className="secondary-button">＋ Agregar a la lista</button>
          </form>
          <form method="get" className="session-date-form">
            <label>Fecha de entrenamiento<input type="date" name="session" defaultValue={selectedDate} /></label>
            <button className="primary-button">Ver fecha</button>
          </form>
        </div>

        {participants.length === 0 ? (
          <div className="data-panel table-empty"><span>★</span><h3>La lista está vacía</h3><p>Agrega las niñas que participarán en esta preparación.</p></div>
        ) : (
          <>
            <PreparationAttendanceForm
              programId={id}
              sessionOn={selectedDate}
              participants={participants.map((gymnast) => ({
                id: gymnast.id,
                name: `${gymnast.first_name} ${gymnast.last_name}`,
                status: (currentStatuses.get(gymnast.id) || "attended") as
                  "attended" | "absent" | "double_class",
              }))}
            />

            {sessions.length > 0 && (
              <div className="data-panel preparation-matrix-wrap">
                <div className="data-panel-heading"><span className="section-kicker">Historial</span><h2>Asistencia por fecha</h2></div>
                <div className="preparation-matrix">
                  <div className="matrix-row matrix-head"><strong>Deportista</strong>{sessions.map((session) => <span key={session.id}>{session.session_on}</span>)}</div>
                  {participants.map((gymnast) => (
                    <div className="matrix-row" key={gymnast.id}>
                      <strong>{gymnast.first_name} {gymnast.last_name}</strong>
                      {sessions.map((session) => {
                        const record = session.preparation_attendance.find((item) => item.gymnast_id === gymnast.id);
                        return <span className={`matrix-status ${record?.status || "empty"}`} key={session.id}>{record ? statusLabel[record.status] : "—"}</span>;
                      })}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </section>
    </main>
  );
}
