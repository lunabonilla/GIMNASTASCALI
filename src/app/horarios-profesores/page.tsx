import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { formatClubTime } from "@/lib/format";
import { saveDailyAssignment } from "./actions";
import styles from "./page.module.css";

const isoToday = () => {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Bogota",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  return formatter.format(new Date());
};

const dateLabel = (date: string) =>
  new Intl.DateTimeFormat("es-CO", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(`${date}T12:00:00Z`));

export default async function StaffSchedulePage({
  searchParams,
}: {
  searchParams: Promise<{ date?: string; saved?: string; error?: string; view?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const query = await searchParams;
  const selectedDate = /^\d{4}-\d{2}-\d{2}$/.test(query.date ?? "")
    ? query.date!
    : isoToday();
  const weekday = new Date(`${selectedDate}T12:00:00Z`).getUTCDay() || 7;

  const [
    { data: slotsData },
    { data: staffData },
    { data: assignmentsData },
  ] = await Promise.all([
    supabase
      .from("group_schedule_slots")
      .select("id, group_id, starts_at, ends_at, location, training_groups(id, name, active, coach_profile_id, levels(name))")
      .eq("weekday", weekday)
      .order("starts_at"),
    supabase
      .from("staff_profiles")
      .select("id, full_name, role, active")
      .eq("active", true)
      .order("full_name"),
    supabase
      .from("daily_staff_assignments")
      .select("id, schedule_slot_id, coach_profile_id, notes")
      .eq("work_date", selectedDate),
  ]);

  const staff = staffData ?? [];
  const staffNames = new Map(staff.map((person) => [person.id, person.full_name]));
  const assignments = new Map(
    (assignmentsData ?? []).map((assignment) => [assignment.schedule_slot_id, assignment]),
  );
  const slots = (slotsData ?? []).filter((slot) => {
    const group = Array.isArray(slot.training_groups)
      ? slot.training_groups[0]
      : slot.training_groups;
    return group?.active;
  });

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Operación diaria</p>
          <h1>Jornada de profesores</h1>
          <p>Asigna quién atiende cada grupo sin cambiar su horario habitual.</p>
        </div>
      </header>

      <section className="module-content">
        {query.saved && <div className="success-banner">✓ Asignación de la jornada guardada.</div>}
        {query.error && <div className="error-banner">{query.error}</div>}

        <section className={styles.dayControl}>
          <div>
            <span>Jornada seleccionada</span>
            <h2>{dateLabel(selectedDate)}</h2>
          </div>
          <form method="get">
            <label>
              Cambiar fecha
              <input type="date" name="date" defaultValue={selectedDate} />
            </label>
            <button type="submit">Ver jornada</button>
          </form>
        </section>

        <nav className={styles.viewTabs}>
          <Link href={`/horarios-profesores?date=${selectedDate}`} className={!query.view ? styles.active : ""}>
            Por grupos
          </Link>
          <Link href={`/horarios-profesores?date=${selectedDate}&view=profesores`} className={query.view === "profesores" ? styles.active : ""}>
            Resumen por profesora
          </Link>
        </nav>

        {slots.length === 0 ? (
          <div className="data-panel table-empty">
            <span>▦</span>
            <h3>No hay grupos fijos para este día</h3>
            <p>Puedes agregar el día desde la edición de un grupo.</p>
            <Link href="/grupos">Ir a grupos y horarios</Link>
          </div>
        ) : query.view === "profesores" ? (
          <div className={styles.teacherBoard}>
            {staff.map((person) => {
              const teacherSlots = slots.filter((slot) => {
                const group = Array.isArray(slot.training_groups) ? slot.training_groups[0] : slot.training_groups;
                const assignment = assignments.get(slot.id);
                return (assignment?.coach_profile_id ?? group?.coach_profile_id) === person.id;
              });
              if (teacherSlots.length === 0) return null;
              return (
                <article key={person.id}>
                  <div className={styles.teacherHeading}>
                    <span>{person.full_name.slice(0, 1)}</span>
                    <div><strong>{person.full_name}</strong><small>{teacherSlots.length} bloques asignados</small></div>
                  </div>
                  {teacherSlots.map((slot) => {
                    const group = Array.isArray(slot.training_groups) ? slot.training_groups[0] : slot.training_groups;
                    return (
                      <div className={styles.teacherSlot} key={slot.id}>
                        <strong>{formatClubTime(slot.starts_at)}–{formatClubTime(slot.ends_at)}</strong>
                        <span>{group?.name}</span>
                        <small>{slot.location || "Sede principal"}</small>
                      </div>
                    );
                  })}
                </article>
              );
            })}
          </div>
        ) : (
          <div className={styles.scheduleList}>
            <div className={styles.listHead}>
              <span>Hora</span><span>Grupo fijo</span><span>Profesora del día</span><span>Novedad</span><span />
            </div>
            {slots.map((slot) => {
              const group = Array.isArray(slot.training_groups)
                ? slot.training_groups[0]
                : slot.training_groups;
              const level = Array.isArray(group?.levels) ? group?.levels[0] : group?.levels;
              const assignment = assignments.get(slot.id);
              const selectedCoach = assignment
                ? assignment.coach_profile_id ?? ""
                : group?.coach_profile_id ?? "";
              return (
                <form action={saveDailyAssignment} className={styles.scheduleRow} key={slot.id}>
                  <input type="hidden" name="work_date" value={selectedDate} />
                  <input type="hidden" name="group_id" value={slot.group_id} />
                  <input type="hidden" name="schedule_slot_id" value={slot.id} />
                  <div className={styles.time}>
                    <strong>{formatClubTime(slot.starts_at)}</strong>
                    <small>{formatClubTime(slot.ends_at)}</small>
                  </div>
                  <div className={styles.group}>
                    <strong>{group?.name}</strong>
                    <small>{level?.name ?? "Sin nivel"} · {slot.location || "Sede principal"}</small>
                  </div>
                  <label>
                    <span>Profesora del día</span>
                    <select name="coach_profile_id" defaultValue={selectedCoach}>
                      <option value="">Sin asignar</option>
                      {staff.map((person) => (
                        <option value={person.id} key={person.id}>{person.full_name}</option>
                      ))}
                    </select>
                    {!assignment && group?.coach_profile_id && (
                      <small>Habitual: {staffNames.get(group.coach_profile_id) ?? "Profesora asignada"}</small>
                    )}
                  </label>
                  <label>
                    <span>Novedad o instrucción</span>
                    <input name="notes" defaultValue={assignment?.notes ?? ""} placeholder="Ej. reemplazo por ausencia" />
                  </label>
                  <button type="submit">{assignment ? "Actualizar" : "Asignar"}</button>
                </form>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
