import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { updateGroup } from "../../actions";

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
  if (!group) notFound();

  const slots = group.group_schedule_slots ?? [];
  const selectedDays = new Set(slots.map((slot) => slot.weekday));
  const firstSlot = slots[0];

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
              <label>Programa *<select name="billing_program" defaultValue={group.billing_program ?? "Regular"}><option value="Minis">Minis · clases de 1 hora</option><option value="Regular">Regular · clases de 1,5 horas</option><option value="Intensivo">Integral / Intensivo</option></select></label>
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
            <div className="form-grid">
              <div className="full-field">
                <span className="field-label">Días de entrenamiento *</span>
                <div className="weekday-picker">
                  {days.map(([day, label]) => (
                    <label key={day}>
                      <input type="checkbox" name="weekdays" value={day} defaultChecked={selectedDays.has(day)} />
                      <span>{label}</span>
                    </label>
                  ))}
                </div>
              </div>
              <label>Sede o espacio<input name="location" defaultValue={firstSlot?.location ?? ""} /></label>
              <label>Hora de inicio *<input name="starts_at" type="time" required defaultValue={firstSlot?.starts_at?.slice(0, 5) ?? ""} /></label>
              <label>Hora de finalización *<input name="ends_at" type="time" required defaultValue={firstSlot?.ends_at?.slice(0, 5) ?? ""} /></label>
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
