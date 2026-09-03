import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { formatClubTime } from "@/lib/format";

const weekdayLabels: Record<number, string> = {
  1: "Lunes",
  2: "Martes",
  3: "Miércoles",
  4: "Jueves",
  5: "Viernes",
  6: "Sábado",
  7: "Domingo",
};

export default async function AttendancePage() {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { data, error } = await supabase
    .from("training_groups")
    .select("id, name, capacity, levels(name), staff_profiles(full_name), group_schedule_slots(weekday, starts_at, ends_at), enrollments(id)")
    .eq("active", true)
    .order("name");
  const groups = (data ?? []) as Array<{
    id: string;
    name: string;
    capacity: number;
    levels: { name: string } | Array<{ name: string }> | null;
    staff_profiles: Array<{ full_name: string }> | null;
    group_schedule_slots: Array<{ weekday: number; starts_at: string; ends_at: string }>;
    enrollments: Array<{ id: string }>;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Seguimiento diario</p>
          <h1>Asistencia</h1>
          <p>Selecciona un grupo para registrar la clase.</p>
        </div>
      </header>
      <section className="module-content">
        {error ? (
          <div className="data-panel table-empty">No pudimos cargar los grupos.</div>
        ) : groups.length === 0 ? (
          <div className="data-panel table-empty">
            <span>✓</span><h3>Primero crea un grupo</h3>
            <p>La asistencia se activa cuando un grupo tiene gimnastas asignadas.</p>
            <Link href="/grupos/nuevo">Crear grupo</Link>
          </div>
        ) : (
          <div className="attendance-group-list">
            {groups.map((group) => {
              const groupLevel = Array.isArray(group.levels) ? group.levels[0] : group.levels;
              const schedules = [...group.group_schedule_slots].sort((first, second) =>
                first.weekday - second.weekday || first.starts_at.localeCompare(second.starts_at),
              );
              return (
              <Link href={`/asistencia/${group.id}`} className="attendance-group-card" key={group.id}>
                <span className="attendance-check">✓</span>
                <div>
                  <small>{groupLevel?.name ?? "Sin nivel"}</small>
                  <h2>{group.name}</h2>
                  <p>{group.staff_profiles?.[0]?.full_name ?? "Sin profesora asignada"}</p>
                </div>
                <div className="attendance-group-times">
                  <small>Hora de inicio</small>
                  {schedules.length ? schedules.map((schedule) => (
                    <strong key={`${schedule.weekday}-${schedule.starts_at}`}>
                      {weekdayLabels[schedule.weekday]} · {formatClubTime(schedule.starts_at)}
                    </strong>
                  )) : <strong>Sin horario</strong>}
                </div>
                <strong>{group.enrollments.length} gimnastas</strong>
                <i>→</i>
              </Link>
            );})}
          </div>
        )}
      </section>
    </main>
  );
}
