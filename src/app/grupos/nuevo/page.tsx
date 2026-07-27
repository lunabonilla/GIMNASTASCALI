import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createGroup } from "../actions";

export default async function NewGroupPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const [{ data: levelsData }, { data: staffData }, { error }] = await Promise.all([
    supabase.from("levels").select("id, name").eq("active", true).order("sort_order"),
    supabase.from("staff_profiles").select("id, full_name, role").eq("active", true).order("full_name"),
    searchParams,
  ]);
  const levels = (levelsData ?? []) as Array<{ id: string; name: string }>;
  const staff = (staffData ?? []) as Array<{ id: string; full_name: string; role: string }>;

  return (
    <main className="form-page">
      <div className="form-card">
        <Link href="/grupos" className="back-link">← Volver a grupos</Link>
        <div className="form-heading">
          <span className="section-kicker">Nuevo grupo</span>
          <h1>Crear grupo y horario</h1>
          <p>Empieza con una jornada; después podrás añadir más horarios.</p>
        </div>
        {error && <div className="error-banner">{error}</div>}
        <form action={createGroup} className="gymnast-form">
          <fieldset>
            <legend>Información del grupo</legend>
            <div className="form-grid">
              <label>Nombre del grupo *<input name="name" required placeholder="Ej. Nivel 1 - Tarde" /></label>
              <label>Modalidad *<select name="group_type" defaultValue="regular"><option value="regular">Regular</option><option value="integral">Integral</option></select></label>
              <label>Nivel<select name="level_id" defaultValue=""><option value="">Sin asignar</option>{levels.map((level) => <option value={level.id} key={level.id}>{level.name}</option>)}</select></label>
              <label>Profesora<select name="coach_profile_id" defaultValue=""><option value="">Sin asignar</option>{staff.map((person) => <option value={person.id} key={person.id}>{person.full_name}</option>)}</select></label>
              <label>Cupos *<input name="capacity" type="number" min="1" defaultValue="12" required /></label>
              <label>Mensualidad (COP)<input name="monthly_fee" type="number" min="0" step="1000" placeholder="250000" /></label>
              <label>Edad mínima<input name="minimum_age" type="number" min="0" /></label>
              <label>Edad máxima<input name="maximum_age" type="number" min="0" /></label>
            </div>
          </fieldset>
          <fieldset>
            <legend>Primer horario semanal</legend>
            <div className="form-grid">
              <label>Día *<select name="weekday" defaultValue="1"><option value="1">Lunes</option><option value="2">Martes</option><option value="3">Miércoles</option><option value="4">Jueves</option><option value="5">Viernes</option><option value="6">Sábado</option><option value="7">Domingo</option></select></label>
              <label>Sede o espacio<input name="location" placeholder="Sede principal" /></label>
              <label>Hora de inicio *<input name="starts_at" type="time" required /></label>
              <label>Hora de finalización *<input name="ends_at" type="time" required /></label>
            </div>
          </fieldset>
          <div className="form-actions">
            <Link href="/grupos">Cancelar</Link>
            <button type="submit" className="primary-button">Crear grupo</button>
          </div>
        </form>
      </div>
    </main>
  );
}
