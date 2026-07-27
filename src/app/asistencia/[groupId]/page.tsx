import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { saveAttendance } from "../actions";

type PageProps = {
  params: Promise<{ groupId: string }>;
  searchParams: Promise<{ date?: string; saved?: string; error?: string }>;
};

export default async function GroupAttendancePage({ params, searchParams }: PageProps) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { groupId } = await params;
  const query = await searchParams;
  const date = query.date || new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Bogota",
  });
  const [{ data: group }, { data: enrollmentData }] = await Promise.all([
    supabase
      .from("training_groups")
      .select("id, name, group_schedule_slots(starts_at, ends_at)")
      .eq("id", groupId)
      .single(),
    supabase
      .from("enrollments")
      .select("gymnast_id, gymnasts(first_name, last_name)")
      .eq("group_id", groupId)
      .eq("active", true),
  ]);
  if (!group) notFound();

  const detail = group as {
    id: string;
    name: string;
    group_schedule_slots: Array<{ starts_at: string; ends_at: string }>;
  };
  const slot = detail.group_schedule_slots[0];
  const enrollments = (enrollmentData ?? []) as Array<{
    gymnast_id: string;
    gymnasts:
      | { first_name: string; last_name: string }
      | Array<{ first_name: string; last_name: string }>
      | null;
  }>;

  let currentRecords = new Map<string, string>();
  if (slot) {
    const startIso = new Date(`${date}T${slot.starts_at.slice(0, 8)}-05:00`).toISOString();
    const { data: session } = await supabase
      .from("class_sessions")
      .select("id")
      .eq("group_id", groupId)
      .eq("starts_at", startIso)
      .maybeSingle();
    if (session) {
      const { data: attendance } = await supabase
        .from("attendance_records")
        .select("gymnast_id, status")
        .eq("session_id", session.id);
      currentRecords = new Map(
        (attendance ?? []).map((record) => [String(record.gymnast_id), String(record.status)]),
      );
    }
  }

  return (
    <main className="form-page">
      <div className="attendance-card">
        <Link href="/asistencia" className="back-link">← Volver a asistencia</Link>
        <div className="attendance-heading">
          <div>
            <span className="section-kicker">Tomar asistencia</span>
            <h1>{detail.name}</h1>
          </div>
          <form method="get" className="date-picker">
            <label>Fecha<input type="date" name="date" defaultValue={date} /></label>
            <button type="submit">Ver fecha</button>
          </form>
        </div>
        {query.saved && <div className="success-banner">✓ Asistencia guardada correctamente.</div>}
        {query.error && <div className="error-banner">{query.error}</div>}

        {!slot ? (
          <div className="table-empty">
            <h3>Este grupo no tiene horario</h3>
            <p>Añade un horario antes de registrar asistencia.</p>
          </div>
        ) : enrollments.length === 0 ? (
          <div className="table-empty">
            <h3>Este grupo no tiene gimnastas</h3>
            <p>Asigna deportistas desde la ficha del grupo.</p>
            <Link href={`/grupos/${groupId}`}>Administrar grupo</Link>
          </div>
        ) : (
          <form action={saveAttendance}>
            <input type="hidden" name="group_id" value={groupId} />
            <input type="hidden" name="date" value={date} />
            <input type="hidden" name="starts_at" value={slot.starts_at.slice(0, 8)} />
            <input type="hidden" name="ends_at" value={slot.ends_at.slice(0, 8)} />
            <div className="attendance-list">
              {enrollments.map((enrollment, index) => {
                const gymnast = Array.isArray(enrollment.gymnasts)
                  ? enrollment.gymnasts[0]
                  : enrollment.gymnasts;
                return (
                  <div className="attendance-row" key={enrollment.gymnast_id}>
                    <span>{index + 1}</span>
                    <strong>{gymnast?.first_name} {gymnast?.last_name}</strong>
                    <select
                      name={`attendance_${enrollment.gymnast_id}`}
                      defaultValue={currentRecords.get(enrollment.gymnast_id) ?? "present"}
                    >
                      <option value="present">Presente</option>
                      <option value="absent">Ausente</option>
                      <option value="excused">Con excusa</option>
                      <option value="makeup">Recuperación</option>
                    </select>
                  </div>
                );
              })}
            </div>
            <div className="attendance-footer">
              <span>{enrollments.length} gimnastas en la lista</span>
              <button type="submit" className="primary-button">Guardar asistencia</button>
            </div>
          </form>
        )}
      </div>
    </main>
  );
}
