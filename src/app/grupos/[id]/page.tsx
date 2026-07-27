import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { deleteGroup, endEnrollment, enrollGymnast } from "../actions";

const dayNames: Record<number, string> = {
  1: "Lunes", 2: "Martes", 3: "Miércoles", 4: "Jueves",
  5: "Viernes", 6: "Sábado", 7: "Domingo",
};

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{
    error?: string;
    assigned?: string;
    removed?: string;
    updated?: string;
  }>;
};

export default async function GroupDetailPage({ params, searchParams }: PageProps) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { id } = await params;
  const messages = await searchParams;
  const [
    { data: group },
    { data: enrollmentData },
    { data: gymnastData },
  ] = await Promise.all([
    supabase
      .from("training_groups")
      .select("id, name, capacity, monthly_fee_cents, billing_program, levels(name), staff_profiles(full_name), group_schedule_slots(weekday, starts_at, ends_at, location)")
      .eq("id", id)
      .single(),
    supabase
      .from("enrollments")
      .select("id, gymnast_id, starts_on, gymnasts(first_name, last_name)")
      .eq("group_id", id)
      .eq("active", true)
      .order("created_at"),
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
    capacity: number;
    monthly_fee_cents: number;
    billing_program: string | null;
    levels: { name: string } | Array<{ name: string }> | null;
    staff_profiles: Array<{ full_name: string }> | null;
    group_schedule_slots: Array<{
      weekday: number;
      starts_at: string;
      ends_at: string;
      location: string | null;
    }>;
  };
  const enrollments = (enrollmentData ?? []) as Array<{
    id: string;
    gymnast_id: string;
    starts_on: string;
    gymnasts:
      | { first_name: string; last_name: string }
      | Array<{ first_name: string; last_name: string }>
      | null;
  }>;
  const enrolledIds = new Set(enrollments.map((item) => item.gymnast_id));
  const availableGymnasts = ((gymnastData ?? []) as Array<{
    id: string;
    first_name: string;
    last_name: string;
  }>).filter((gymnast) => !enrolledIds.has(gymnast.id));
  const full = enrollments.length >= detail.capacity;
  const detailLevel = Array.isArray(detail.levels) ? detail.levels[0] : detail.levels;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/grupos" className="back-link">← Volver a grupos</Link>
          <p className="eyebrow">{detailLevel?.name ?? "Sin nivel"}</p>
          <h1>{detail.name}</h1>
          <p>
            {detail.staff_profiles?.[0]?.full_name ?? "Sin profesora"} ·{" "}
            {enrollments.length} de {detail.capacity} cupos ocupados ·{" "}
            {detail.billing_program ?? "Programa sin definir"}
          </p>
        </div>
        <div className="header-actions">
          <Link href={`/grupos/${detail.id}/editar`} className="outline-button">Editar grupo</Link>
          <Link href="/asistencia" className="outline-button">Ir a asistencia</Link>
        </div>
      </header>

      <section className="module-content">
        {messages.error && <div className="error-banner">{messages.error}</div>}
        {messages.assigned && <div className="success-banner">✓ Gimnasta asignada al grupo.</div>}
        {messages.removed && <div className="success-banner">✓ Gimnasta retirada; conservamos su historial.</div>}
        {messages.updated && <div className="success-banner">✓ Grupo y horario actualizados.</div>}

        <div className="group-detail-grid">
          <section className="data-panel">
            <div className="data-panel-heading">
              <span className="section-kicker">Deportistas</span>
              <h2>Integrantes del grupo</h2>
            </div>
            {enrollments.length === 0 ? (
              <div className="compact-empty">
                <p>Aún no hay gimnastas asignadas.</p>
              </div>
            ) : (
              <div className="member-list">
                {enrollments.map((enrollment) => {
                  const gymnast = Array.isArray(enrollment.gymnasts)
                    ? enrollment.gymnasts[0]
                    : enrollment.gymnasts;
                  return (
                    <div className="member-row" key={enrollment.id}>
                      <div className="member-avatar">
                        {gymnast?.first_name?.[0] ?? "G"}
                      </div>
                      <div>
                        <strong>{gymnast?.first_name} {gymnast?.last_name}</strong>
                        <span>Desde {new Intl.DateTimeFormat("es-CO", {
                          dateStyle: "medium", timeZone: "UTC",
                        }).format(new Date(enrollment.starts_on))}</span>
                      </div>
                      <form action={endEnrollment}>
                        <input type="hidden" name="group_id" value={detail.id} />
                        <input type="hidden" name="enrollment_id" value={enrollment.id} />
                        <button type="submit">Retirar</button>
                      </form>
                    </div>
                  );
                })}
              </div>
            )}
          </section>

          <aside className="detail-sidebar">
            <section className="data-panel assign-panel">
              <span className="section-kicker">Nuevo cupo</span>
              <h2>Asignar gimnasta</h2>
              {full ? (
                <div className="capacity-warning">El grupo alcanzó su capacidad máxima.</div>
              ) : (
                <form action={enrollGymnast}>
                  <input type="hidden" name="group_id" value={detail.id} />
                  <label>
                    Gimnasta activa
                    <select name="gymnast_id" required defaultValue="">
                      <option value="" disabled>Seleccionar gimnasta</option>
                      {availableGymnasts.map((gymnast) => (
                        <option value={gymnast.id} key={gymnast.id}>
                          {gymnast.first_name} {gymnast.last_name}
                        </option>
                      ))}
                    </select>
                  </label>
                  <button type="submit" className="primary-button">Asignar al grupo</button>
                </form>
              )}
            </section>

            <section className="data-panel schedule-summary">
              <span className="section-kicker">Horario semanal</span>
              <h2>Entrenamientos</h2>
              {detail.group_schedule_slots.map((slot) => (
                <div key={`${slot.weekday}-${slot.starts_at}`}>
                  <strong>{dayNames[slot.weekday]}</strong>
                  <span>{slot.starts_at.slice(0, 5)} – {slot.ends_at.slice(0, 5)}</span>
                  <small>{slot.location || "Sede principal"}</small>
                </div>
              ))}
            </section>
          </aside>
        </div>

        <section className="danger-zone">
          <div>
            <span className="section-kicker">Administración del grupo</span>
            <h2>Eliminar o retirar este grupo</h2>
            <p>Si ya tiene historial, se desactivará para conservar las asistencias y asignaciones.</p>
          </div>
          <form action={deleteGroup}>
            <input type="hidden" name="group_id" value={detail.id} />
            <button type="submit">Eliminar grupo</button>
          </form>
        </section>
      </section>
    </main>
  );
}
