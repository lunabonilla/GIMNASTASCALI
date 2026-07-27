import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const dayNames: Record<number, string> = {
  1: "Lunes", 2: "Martes", 3: "Miércoles", 4: "Jueves",
  5: "Viernes", 6: "Sábado", 7: "Domingo",
};

export default async function GroupsPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { created } = await searchParams;
  const { data, error } = await supabase
    .from("training_groups")
    .select("id, name, group_type, capacity, monthly_fee_cents, active, levels(name), staff_profiles(full_name), group_schedule_slots(weekday, starts_at, ends_at, location), enrollments(id)")
    .order("name");

  const groups = (data ?? []) as Array<{
    id: string; name: string; group_type: "regular" | "integral";
    capacity: number; monthly_fee_cents: number; active: boolean;
    levels: Array<{ name: string }> | null;
    staff_profiles: Array<{ full_name: string }> | null;
    group_schedule_slots: Array<{ weekday: number; starts_at: string; ends_at: string; location: string | null }>;
    enrollments: Array<{ id: string }>;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Operación deportiva</p>
          <h1>Grupos y horarios</h1>
          <p>Organiza niveles, profesoras, cupos y jornadas semanales.</p>
        </div>
        <Link href="/grupos/nuevo" className="primary-button">＋ Crear grupo</Link>
      </header>

      <section className="module-content">
        {created && <div className="success-banner">✓ Grupo y horario creados correctamente.</div>}
        {error ? (
          <div className="data-panel table-empty">No pudimos cargar los grupos.</div>
        ) : groups.length === 0 ? (
          <div className="data-panel table-empty">
            <span>▦</span><h3>Aún no hay grupos</h3>
            <p>Crea el primer grupo para organizar los entrenamientos.</p>
            <Link href="/grupos/nuevo">Crear primer grupo</Link>
          </div>
        ) : (
          <div className="group-grid">
            {groups.map((group) => {
              const occupied = group.enrollments.length;
              const percentage = Math.min(100, Math.round((occupied / group.capacity) * 100));
              return (
                <article className="group-card" key={group.id}>
                  <div className="group-card-top">
                    <div>
                      <span className="section-kicker">{group.group_type === "integral" ? "Integral" : "Regular"}</span>
                      <h2>{group.name}</h2>
                    </div>
                    <span className="status-chip">{group.active ? "Activo" : "Inactivo"}</span>
                  </div>
                  <div className="group-meta">
                    <div><span>Nivel</span><strong>{group.levels?.[0]?.name ?? "Sin asignar"}</strong></div>
                    <div><span>Profesora</span><strong>{group.staff_profiles?.[0]?.full_name ?? "Sin asignar"}</strong></div>
                  </div>
                  <div className="schedule-list">
                    {group.group_schedule_slots.map((slot) => (
                      <div key={`${slot.weekday}-${slot.starts_at}`}>
                        <strong>{dayNames[slot.weekday]}</strong>
                        <span>{slot.starts_at.slice(0, 5)} – {slot.ends_at.slice(0, 5)}</span>
                        <small>{slot.location || "Sede principal"}</small>
                      </div>
                    ))}
                  </div>
                  <div className="capacity-block">
                    <div><span>Cupos</span><strong>{occupied} / {group.capacity}</strong></div>
                    <div className="capacity-track"><i style={{ width: `${percentage}%` }} /></div>
                  </div>
                  <footer>
                    <span>{new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(group.monthly_fee_cents / 100)}<small> / mes</small></span>
                    <button disabled>Administrar →</button>
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
