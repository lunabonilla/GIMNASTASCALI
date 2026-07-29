import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createGroup } from "../actions";
import { ProgramDurationSelect } from "../program-duration-select";

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
      <div className="form-card wide-form">
        <Link href="/grupos" className="back-link">← Volver a grupos</Link>
        <div className="form-heading">
          <span className="section-kicker">Nuevo grupo</span>
          <h1>Crear grupo y horario</h1>
          <p>Selecciona el programa, los días y un horario compartido para crear la clase completa.</p>
        </div>
        {error && <div className="error-banner">{error}</div>}
        <form action={createGroup} className="gymnast-form">
          <fieldset>
            <legend>Información del grupo</legend>
            <div className="form-grid">
              <label>Nombre del grupo *<input name="name" required placeholder="Ej. Nivel 1 - Tarde" /></label>
              <label>Programa *<ProgramDurationSelect defaultValue="Regular" /></label>
              <label>Nivel<select name="level_id" defaultValue=""><option value="">Sin asignar</option>{levels.map((level) => <option value={level.id} key={level.id}>{level.name}</option>)}</select></label>
              <label>Profesora<select name="coach_profile_id" defaultValue=""><option value="">Sin asignar</option>{staff.map((person) => <option value={person.id} key={person.id}>{person.full_name}</option>)}</select></label>
              <label>Cupos *<input name="capacity" type="number" min="1" defaultValue="12" required /></label>
              <div className="auto-rate-note">La tarifa se calculará automáticamente según el programa y la cantidad de días.</div>
              <label>Edad mínima<input name="minimum_age" type="number" min="0" /></label>
              <label>Edad máxima<input name="maximum_age" type="number" min="0" /></label>
            </div>
          </fieldset>
          <fieldset>
            <legend>Días y horario semanal</legend>
            <div className="form-grid">
              <div className="full-field">
                <span className="field-label">Días de entrenamiento *</span>
                <div className="weekday-picker">
                  {[
                    [1, "Lunes"], [2, "Martes"], [3, "Miércoles"],
                    [4, "Jueves"], [5, "Viernes"], [6, "Sábado"], [7, "Domingo"],
                  ].map(([day, label]) => (
                    <label key={day}>
                      <input type="checkbox" name="weekdays" value={day} />
                      <span>{label}</span>
                    </label>
                  ))}
                </div>
              </div>
              <label>Hora de inicio *<input name="starts_at" type="time" required /></label>
              <label>Hora de finalización *<input name="ends_at" type="time" required /><small>Se calcula automáticamente según el programa y puedes ajustarla.</small></label>
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
