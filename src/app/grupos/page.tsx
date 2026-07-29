import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { formatClubTime } from "@/lib/format";
import styles from "./page.module.css";

const days = [
  [1, "Lunes"], [2, "Martes"], [3, "Miércoles"], [4, "Jueves"],
  [5, "Viernes"], [6, "Sábado"], [7, "Domingo"],
] as const;

type Enrollment = {
  id: string;
  active: boolean;
  participation_status: "active" | "vacation" | "paused" | "injured" | "pending";
  gymnasts:
    | { first_name: string; last_name: string }
    | Array<{ first_name: string; last_name: string }>
    | null;
};

type Group = {
  id: string;
  name: string;
  billing_program: string | null;
  capacity: number;
  active: boolean;
  levels: { name: string } | Array<{ name: string }> | null;
  staff_profiles: Array<{ full_name: string }> | null;
  group_schedule_slots: Array<{
    id: string;
    weekday: number;
    starts_at: string;
    ends_at: string;
  }>;
  enrollments: Enrollment[];
};

export default async function GroupsPage({
  searchParams,
}: {
  searchParams: Promise<{
    day?: string;
    created?: string;
    deleted?: string;
    archived?: string;
    permanently_deleted?: string;
  }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const params = await searchParams;
  const weekdayName = new Intl.DateTimeFormat("en-US", {
    weekday: "long",
    timeZone: "America/Bogota",
  }).format(new Date());
  const weekdayNumbers: Record<string, number> = {
    Monday: 1, Tuesday: 2, Wednesday: 3, Thursday: 4,
    Friday: 5, Saturday: 6, Sunday: 7,
  };
  const actualWeekday = weekdayNumbers[weekdayName] ?? 1;
  const requestedDay = Number(params.day);
  const selectedDay = Number.isInteger(requestedDay) && requestedDay >= 1 && requestedDay <= 7
    ? requestedDay
    : actualWeekday;

  const { data, error } = await supabase
    .from("training_groups")
    .select("id, name, billing_program, capacity, active, levels(name), staff_profiles(full_name), group_schedule_slots(id, weekday, starts_at, ends_at), enrollments(id, active, participation_status, gymnasts(first_name, last_name))")
    .order("name");
  const groups = (data ?? []) as Group[];
  const dayCounts = new Map<number, number>();
  for (const group of groups) {
    for (const weekday of new Set(group.group_schedule_slots.map((slot) => slot.weekday))) {
      dayCounts.set(weekday, (dayCounts.get(weekday) ?? 0) + 1);
    }
  }

  const cards = groups
    .flatMap((group) =>
      group.group_schedule_slots
        .filter((slot) => slot.weekday === selectedDay)
        .map((slot) => ({ group, slot })),
    )
    .sort((a, b) => a.slot.starts_at.localeCompare(b.slot.starts_at));
  const selectedDayName = days.find(([day]) => day === selectedDay)?.[1] ?? "Día";

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Operación deportiva</p>
          <h1>Grupos y horarios</h1>
          <p>Tablero semanal de grupos, horarios y gimnastas.</p>
        </div>
        <Link href="/grupos/nuevo" className="primary-button">＋ Crear grupo</Link>
      </header>

      <section className="module-content">
        {params.created && <div className="success-banner">✓ Grupo y horario creados correctamente.</div>}
        {params.deleted && <div className="success-banner">✓ Grupo vacío eliminado definitivamente.</div>}
        {params.permanently_deleted && <div className="success-banner">✓ Grupo eliminado definitivamente.</div>}
        {params.archived && <div className="success-banner">✓ Grupo desactivado; su historial quedó protegido.</div>}

        <nav className={styles.dayTabs} aria-label="Días de la semana">
          {days.map(([day, label]) => (
            <Link
              href={`/grupos?day=${day}`}
              className={selectedDay === day ? styles.activeDay : ""}
              key={day}
            >
              {label}<span>{dayCounts.get(day) ?? 0}</span>
            </Link>
          ))}
        </nav>

        <div className={styles.boardHeading}>
          <div>
            <span className="section-kicker">Horario semanal</span>
            <h2>{selectedDayName}</h2>
          </div>
          <div className={styles.legend}>
            <span className={styles.active}>Entrenando</span>
            <span className={styles.vacation}>Vacaciones</span>
            <span className={styles.paused}>Pausa</span>
            <span className={styles.injured}>Lesión</span>
            <span className={styles.pending}>Pendiente</span>
          </div>
        </div>

        {error ? (
          <div className="data-panel table-empty">No pudimos cargar los grupos.</div>
        ) : groups.length === 0 ? (
          <div className="data-panel table-empty">
            <span>▦</span><h3>Aún no hay grupos</h3>
            <p>Crea el primer grupo para organizar los entrenamientos.</p>
            <Link href="/grupos/nuevo">Crear primer grupo</Link>
          </div>
        ) : cards.length === 0 ? (
          <div className="data-panel table-empty">
            <span>○</span><h3>No hay grupos el {selectedDayName.toLowerCase()}</h3>
            <p>Elige otro día o crea un horario nuevo.</p>
          </div>
        ) : (
          <div className={styles.scheduleBoard}>
            {cards.map(({ group, slot }) => {
              const level = Array.isArray(group.levels) ? group.levels[0] : group.levels;
              const enrollments = group.enrollments.filter((item) => item.active);
              return (
                <article className={`${styles.groupNote} ${!group.active ? styles.inactiveGroup : ""}`} key={`${group.id}-${slot.id}`}>
                  <div className={styles.noteTop}>
                    <div>
                      <strong>{formatClubTime(slot.starts_at)}–{formatClubTime(slot.ends_at)}</strong>
                      <span>{level?.name ?? group.billing_program ?? "Sin nivel"}</span>
                    </div>
                    <small>{enrollments.length}/{group.capacity}</small>
                  </div>
                  <Link href={`/grupos/${group.id}`} className={styles.groupName}>{group.name}</Link>
                  <p className={styles.coach}>{group.staff_profiles?.[0]?.full_name ?? "Profesora sin asignar"}</p>
                  <div className={styles.gymnastNames}>
                    {enrollments.length === 0 ? (
                      <p>Sin gimnastas asignadas</p>
                    ) : enrollments.map((enrollment) => {
                      const gymnast = Array.isArray(enrollment.gymnasts)
                        ? enrollment.gymnasts[0]
                        : enrollment.gymnasts;
                      return (
                        <span className={styles[enrollment.participation_status]} key={enrollment.id}>
                          {gymnast?.first_name} {gymnast?.last_name}
                        </span>
                      );
                    })}
                  </div>
                  <footer>
                    {!group.active && <span>Grupo inactivo</span>}
                    <Link href={`/grupos/${group.id}`}>Administrar →</Link>
                  </footer>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
