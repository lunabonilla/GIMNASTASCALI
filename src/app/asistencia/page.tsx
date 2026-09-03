import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { formatClubTime } from "@/lib/format";

const weekdays = [
  [1, "Lunes"], [2, "Martes"], [3, "Miércoles"], [4, "Jueves"],
  [5, "Viernes"], [6, "Sábado"], [7, "Domingo"],
] as const;

const dateForWeekday = (weekday: number) => {
  const todayText = new Date().toLocaleDateString("en-CA", { timeZone: "America/Bogota" });
  const today = new Date(`${todayText}T12:00:00-05:00`);
  const currentWeekday = today.getDay() || 7;
  today.setDate(today.getDate() + weekday - currentWeekday);
  return today.toLocaleDateString("en-CA", { timeZone: "America/Bogota" });
};

export default async function AttendancePage({
  searchParams,
}: {
  searchParams: Promise<{ day?: string }>;
}) {
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
  const params = await searchParams;
  const todayName = new Intl.DateTimeFormat("en-US", {
    weekday: "long",
    timeZone: "America/Bogota",
  }).format(new Date());
  const dayNumbers: Record<string, number> = {
    Monday: 1, Tuesday: 2, Wednesday: 3, Thursday: 4,
    Friday: 5, Saturday: 6, Sunday: 7,
  };
  const requestedDay = Number(params.day);
  const selectedDay = Number.isInteger(requestedDay) && requestedDay >= 1 && requestedDay <= 7
    ? requestedDay
    : dayNumbers[todayName] ?? 1;
  const selectedDayName = weekdays.find(([day]) => day === selectedDay)?.[1] ?? "Día";
  const selectedDate = dateForWeekday(selectedDay);
  const dayCounts = new Map<number, number>();
  for (const group of groups) {
    for (const day of new Set(group.group_schedule_slots.map((slot) => slot.weekday))) {
      dayCounts.set(day, (dayCounts.get(day) ?? 0) + 1);
    }
  }
  const cards = groups
    .flatMap((group) => group.group_schedule_slots
      .filter((slot) => slot.weekday === selectedDay)
      .map((slot) => ({ group, slot })))
    .sort((first, second) => first.slot.starts_at.localeCompare(second.slot.starts_at));

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
        <nav className="attendance-day-tabs" aria-label="Días de asistencia">
          {weekdays.map(([day, label]) => (
            <Link
              href={`/asistencia?day=${day}`}
              className={selectedDay === day ? "active" : ""}
              key={day}
            >
              <b>{label.slice(0, 3)}</b><span>{dayCounts.get(day) ?? 0}</span>
            </Link>
          ))}
        </nav>
        <div className="attendance-day-heading">
          <div><span>Clases del día</span><h2>{selectedDayName}</h2></div>
          <small>{cards.length} {cards.length === 1 ? "grupo" : "grupos"}</small>
        </div>
        {error ? (
          <div className="data-panel table-empty">No pudimos cargar los grupos.</div>
        ) : groups.length === 0 ? (
          <div className="data-panel table-empty">
            <span>✓</span><h3>Primero crea un grupo</h3>
            <p>La asistencia se activa cuando un grupo tiene gimnastas asignadas.</p>
            <Link href="/grupos/nuevo">Crear grupo</Link>
          </div>
        ) : cards.length === 0 ? (
          <div className="data-panel table-empty">
            <span>○</span><h3>No hay clases el {selectedDayName.toLowerCase()}</h3>
            <p>Selecciona otro día para tomar asistencia.</p>
          </div>
        ) : (
          <div className="attendance-group-list">
            {cards.map(({ group, slot }) => {
              const groupLevel = Array.isArray(group.levels) ? group.levels[0] : group.levels;
              return (
              <Link
                href={`/asistencia/${group.id}?date=${selectedDate}&day=${selectedDay}&starts=${encodeURIComponent(slot.starts_at)}`}
                className="attendance-group-card"
                key={`${group.id}-${slot.starts_at}`}
              >
                <div className="attendance-card-topline">
                  <small>{groupLevel?.name ?? "Sin nivel"}</small>
                  <span>{group.enrollments.length} gimnastas</span>
                </div>
                <div className="attendance-title-row">
                  <h2>{group.name}</h2>
                  <div className="attendance-group-times">
                    <strong>{formatClubTime(slot.starts_at)}</strong>
                  </div>
                </div>
                <div className="attendance-card-footer">
                  <p>{group.staff_profiles?.[0]?.full_name ?? "Sin profesora asignada"}</p>
                  <span>Tomar asistencia →</span>
                </div>
              </Link>
            );})}
          </div>
        )}
      </section>
    </main>
  );
}
