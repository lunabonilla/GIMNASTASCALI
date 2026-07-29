import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { updateGroup } from "../../actions";
import { ProgramDurationSelect } from "../../program-duration-select";

const days = [
  [1, "Lunes"], [2, "Martes"], [3, "Miércoles"],
  [4, "Jueves"], [5, "Viernes"], [6, "Sábado"], [7, "Domingo"],
] as const;

export default async function EditGroupPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { id } = await params;
  const { error } = await searchParams;

  const [{ data: group }, { data: levelsData }, { data: staffData }] = await Promise.all([
    supabase
      .from("training_groups")
      .select("id, name, billing_program, level_id, coach_profile_id, minimum_age, maximum_age, capacity, active, group_schedule_slots(weekday, starts_at, ends_at, location)")
      .eq("id", id)
      .single(),
    supabase.from("levels").select("id, name").eq("active", true).order("sort_order"),
    supabase.from("staff_profiles").select("id, full_name").eq("active", true).order("full_name"),
  ]);
  if (!group) redirect("/grupos?missing=1");

  const slots = group.group_schedule_slots ?? [];
  const slotsByDay = new Map(slots.map((slot) => [slot.weekday, slot]));

  return (
    <main className="form-page">
      <div className="form-card wide-form">
        <Link href={`/grupos/${id}`} className="back-link">← Volver al grupo</Link>
        <div className="form-heading">
          <span className="section-kicker">Editar grupo</span>
          <h1>{group.name}</h1>
          <p>Actualiza la información y el horario semanal del grupo.</p>
        </div>
        {error && <div className="error-banner">{error}</div>}
        <form action={updateGroup} className="gymnast-form">
          <input type="hidden" name="group_id" value={id} />
          <fieldset>
            <legend>Información del grupo</legend>
            <div className="form-grid">
              <label>Nombre del grupo *<input name="name" required defaultValue={group.name} /></label>
              <label>Programa *<ProgramDurationSelect defaultValue={group.billing_program ?? "Regular"} /></label>
              <label>Nivel<select name="level_id" defaultValue={group.level_id ?? ""}><option value="">Sin asignar</option>{(levelsData ?? []).map((level) => <option value={level.id} key={level.id}>{level.name}</option>)}</select></label>
              <label>Profesora<select name="coach_profile_id" defaultValue={group.coach_profile_id ?? ""}><option value="">Sin asignar</option>{(staffData ?? []).map((person) => <option value={person.id} key={person.id}>{person.full_name}</option>)}</select></label>
              <label>Cupos *<input name="capacity" type="number" min="1" defaultValue={group.capacity} required /></label>
              <label className="checkbox-field"><input name="active" type="checkbox" defaultChecked={group.active} /> Grupo activo</label>
              <label>Edad mínima<input name="minimum_age" type="number" min="0" defaultValue={group.minimum_age ?? ""} /></label>
              <label>Edad máxima<input name="maximum_age" type="number" min="0" defaultValue={group.maximum_age ?? ""} /></label>
            </div>
          </fieldset>
          <fieldset>
            <legend>Días y horario semanal</legend>
            <p className="schedule-editor-help">
              Marca los días de entrenamiento y define el horario de cada uno.
            </p>
            <div className="schedule-editor">
              <div className="schedule-editor-head">
                <span>Día</span><span>Inicio</span><span>Final</span>
              </div>
              {days.map(([day, label]) => {
                const slot = slotsByDay.get(day);
                return (
                  <div className="schedule-editor-row" key={day}>
                    <label className="schedule-day">
                      <input type="checkbox" name="weekdays" value={day} defaultChecked={Boolean(slot)} />
                      <span>{label}</span>
                    </label>
                    <label><span>Hora de inicio</span><input name={`starts_at_${day}`} type="time" defaultValue={slot?.starts_at?.slice(0, 5) ?? ""} /></label>
                    <label><span>Hora final</span><input name={`ends_at_${day}`} type="time" defaultValue={slot?.ends_at?.slice(0, 5) ?? ""} /></label>
                  </div>
                );
              })}
            </div>
          </fieldset>
          <div className="form-actions">
            <Link href={`/grupos/${id}`}>Cancelar</Link>
            <button type="submit" className="primary-button">Guardar cambios</button>
          </div>
        </form>
      </div>
    </main>
  );
}
