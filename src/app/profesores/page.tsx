import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentStaffProfile } from "@/lib/current-staff";
import { createCoach, updateCoach } from "./actions";
import styles from "./page.module.css";

export default async function CoachesPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; updated?: string; error?: string }>;
}) {
  const current = await getCurrentStaffProfile();
  if (!current?.active) redirect("/login");
  const params = await searchParams;
  const supabase = await createClient();
  const { data } = await supabase
    .from("staff_profiles")
    .select("id, full_name, phone, role, active")
    .order("active", { ascending: false })
    .order("full_name");
  const staff = data ?? [];

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Equipo del club</p>
          <h1>Profesores</h1>
          <p>Administra las personas que pueden asignarse a grupos y jornadas.</p>
        </div>
      </header>
      <section className="module-content">
        {params.created && <div className="success-banner">✓ Profesor creado correctamente.</div>}
        {params.updated && <div className="success-banner">✓ Información actualizada.</div>}
        {params.error && <div className="error-banner">{params.error}</div>}

        <form action={createCoach} className={styles.createForm}>
          <div><span className="section-kicker">Nuevo integrante</span><strong>Agregar profesor</strong></div>
          <label>Nombre<input name="full_name" placeholder="Nombre del profesor" required /></label>
          <label>Teléfono<input name="phone" type="tel" placeholder="Opcional" /></label>
          <button className="primary-button" type="submit">＋ Agregar</button>
        </form>

        <div className={styles.summary}>
          <strong>{staff.filter((person) => person.active).length} activos</strong>
          <span>{staff.filter((person) => !person.active).length} inactivos</span>
        </div>
        <div className={styles.grid}>
          {staff.map((person) => (
            <form action={updateCoach} className={styles.card} key={person.id}>
              <input type="hidden" name="id" value={person.id} />
              <div className={styles.cardTop}>
                <span className={person.active ? styles.active : styles.inactive}>
                  {person.active ? "Activo" : "Inactivo"}
                </span>
                {person.id === current.id && <small>Tu usuario</small>}
              </div>
              <label>Nombre<input name="full_name" defaultValue={person.full_name} required /></label>
              <label>Teléfono<input name="phone" type="tel" defaultValue={person.phone ?? ""} placeholder="Sin registrar" /></label>
              <div className={styles.cardActions}>
                <label className={styles.toggle}>
                  <input name="active" type="checkbox" defaultChecked={person.active} disabled={person.id === current.id} />
                  Disponible para horarios
                </label>
                <button type="submit">Guardar</button>
              </div>
            </form>
          ))}
        </div>
      </section>
    </main>
  );
}
