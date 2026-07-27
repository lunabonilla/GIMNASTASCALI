import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { addMakeupGymnast } from "../actions";
import { AttendanceForm } from "./attendance-form";

type PageProps = {
  params: Promise<{ groupId: string }>;
  searchParams: Promise<{
    date?: string;
    saved?: string;
    makeup?: string;
    error?: string;
  }>;
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
  const [{ data: group }, { data: enrollmentData }, { data: activeGymnastData }] = await Promise.all([
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
    supabase
      .from("gymnasts")
      .select("id, first_name, last_name")
      .eq("status", "active")
      .order("first_name"),
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
  let extraAttendees: Array<{
    gymnast_id: string;
    first_name: string;
    last_name: string;
  }> = [];
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
        .select("gymnast_id, status, gymnasts(first_name, last_name)")
        .eq("session_id", session.id);
      currentRecords = new Map(
        (attendance ?? []).map((record) => [String(record.gymnast_id), String(record.status)]),
      );
      const enrolledIds = new Set(enrollments.map((item) => item.gymnast_id));
      extraAttendees = (attendance ?? []).flatMap((record) => {
        if (enrolledIds.has(String(record.gymnast_id))) return [];
        const related = record.gymnasts as
          | { first_name: string; last_name: string }
          | Array<{ first_name: string; last_name: string }>
          | null;
        const gymnast = Array.isArray(related) ? related[0] : related;
        if (!gymnast) return [];
        return [{
          gymnast_id: String(record.gymnast_id),
          first_name: gymnast.first_name,
          last_name: gymnast.last_name,
        }];
      });
    }
  }
  const visibleIds = new Set([
    ...enrollments.map((item) => item.gymnast_id),
    ...extraAttendees.map((item) => item.gymnast_id),
  ]);
  const makeupOptions = ((activeGymnastData ?? []) as Array<{
    id: string;
    first_name: string;
    last_name: string;
  }>).filter((gymnast) => !visibleIds.has(gymnast.id));

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
        {query.makeup && <div className="success-banner">✓ Gimnasta agregada como recuperación.</div>}
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
          <>
          <form action={addMakeupGymnast} className="makeup-form">
            <input type="hidden" name="group_id" value={groupId} />
            <input type="hidden" name="date" value={date} />
            <input type="hidden" name="starts_at" value={slot.starts_at.slice(0, 8)} />
            <input type="hidden" name="ends_at" value={slot.ends_at.slice(0, 8)} />
            <div>
              <strong>Agregar recuperación</strong>
              <span>Incluye una gimnasta de otro grupo solo para esta clase.</span>
            </div>
            <select name="gymnast_id" required defaultValue="">
              <option value="" disabled>Buscar y seleccionar gimnasta</option>
              {makeupOptions.map((gymnast) => (
                <option value={gymnast.id} key={gymnast.id}>
                  {gymnast.first_name} {gymnast.last_name}
                </option>
              ))}
            </select>
            <button type="submit">＋ Agregar</button>
          </form>
          <AttendanceForm
            groupId={groupId}
            date={date}
            startsAt={slot.starts_at.slice(0, 8)}
            endsAt={slot.ends_at.slice(0, 8)}
            gymnasts={[
              ...enrollments.map((enrollment) => {
                const gymnast = Array.isArray(enrollment.gymnasts)
                  ? enrollment.gymnasts[0]
                  : enrollment.gymnasts;
                return {
                  id: enrollment.gymnast_id,
                  name: `${gymnast?.first_name ?? ""} ${gymnast?.last_name ?? ""}`.trim(),
                  initialStatus: (currentRecords.get(enrollment.gymnast_id) ?? "present") as
                    "present" | "absent" | "excused" | "makeup",
                  isMakeup: false,
                };
              }),
              ...extraAttendees.map((gymnast) => ({
                id: gymnast.gymnast_id,
                name: `${gymnast.first_name} ${gymnast.last_name}`.trim(),
                initialStatus: (currentRecords.get(gymnast.gymnast_id) ?? "makeup") as
                  "present" | "absent" | "excused" | "makeup",
                isMakeup: true,
              })),
            ]}
          />
          </>
        )}
      </div>
    </main>
  );
}
