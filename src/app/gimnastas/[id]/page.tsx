import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { updateGymnast } from "../actions";

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ error?: string; updated?: string }>;
};

const dayNames: Record<number, string> = {
  1: "Lun", 2: "Mar", 3: "Mié", 4: "Jue", 5: "Vie", 6: "Sáb", 7: "Dom",
};
const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency", currency: "COP", maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function GymnastProfilePage({ params, searchParams }: PageProps) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { id } = await params;
  const messages = await searchParams;

  const [
    { data: gymnast },
    { data: links },
    { data: privateData },
    { data: levelData },
    { data: enrollmentData },
    { data: billingProfile },
    { data: charges },
    { count: attendanceCount },
    { count: presentCount },
  ] = await Promise.all([
    supabase.from("gymnasts")
      .select("id, first_name, last_name, birth_date, identity_document, level_id, status, joined_on, experience_notes")
      .eq("id", id).single(),
    supabase.from("gymnast_guardians")
      .select("guardians(id, full_name, identity_document, phone, alternate_phone, relationship, email, notes)")
      .eq("gymnast_id", id).eq("is_primary", true).maybeSingle(),
    supabase.from("gymnast_private_details").select("*").eq("gymnast_id", id).maybeSingle(),
    supabase.from("levels").select("id, name").eq("active", true).order("sort_order"),
    supabase.from("enrollments")
      .select("starts_on, training_groups(id, name, billing_program, monthly_fee_cents, staff_profiles(full_name), group_schedule_slots(weekday, starts_at, ends_at, location))")
      .eq("gymnast_id", id).eq("active", true).maybeSingle(),
    supabase.from("gymnast_billing_profiles")
      .select("program, days_per_week, custom_cycle_amount_cents, pricing_notes").eq("gymnast_id", id).maybeSingle(),
    supabase.from("billing_charges")
      .select("amount_cents, payment_allocations(amount_cents)")
      .eq("gymnast_id", id).is("voided_at", null),
    supabase.from("attendance_records").select("*", { count: "exact", head: true }).eq("gymnast_id", id),
    supabase.from("attendance_records").select("*", { count: "exact", head: true }).eq("gymnast_id", id).in("status", ["present", "makeup"]),
  ]);
  if (!gymnast) notFound();

  const guardianRelation = links?.guardians;
  const guardian = Array.isArray(guardianRelation) ? guardianRelation[0] : guardianRelation;
  const groupRelation = enrollmentData?.training_groups;
  const group = Array.isArray(groupRelation) ? groupRelation[0] : groupRelation;
  const coachRelation = group?.staff_profiles;
  const coach = Array.isArray(coachRelation) ? coachRelation[0] : coachRelation;
  const levels = levelData ?? [];
  const currentLevel = levels.find((level) => level.id === gymnast.level_id);
  const charged = (charges ?? []).reduce((total, charge) => total + Number(charge.amount_cents), 0);
  const paid = (charges ?? []).reduce(
    (total, charge) => total + (charge.payment_allocations ?? []).reduce(
      (subtotal, allocation) => subtotal + Number(allocation.amount_cents), 0,
    ), 0,
  );
  const attendanceRate = attendanceCount
    ? Math.round(((presentCount ?? 0) / attendanceCount) * 100)
    : 0;
  const initials = `${gymnast.first_name?.[0] ?? ""}${gymnast.last_name?.[0] ?? ""}`.toUpperCase();

  return (
    <main className="module-page profile-page">
      <header className="profile-hero">
        <Link href="/gimnastas" className="back-link">← Volver al directorio</Link>
        <div className="profile-identity">
          <div className="profile-avatar">{initials}</div>
          <div>
            <p className="eyebrow">Ficha de deportista</p>
            <h1>{gymnast.first_name} {gymnast.last_name}</h1>
            <div className="profile-tags">
              <span className={`sport-status ${gymnast.status}`}>
                {gymnast.status === "active" ? "Activa" : gymnast.status === "suspended" ? "Pausada" : "Retirada"}
              </span>
              <span>{billingProfile?.program ?? group?.billing_program ?? "Programa pendiente"}</span>
              <span>{currentLevel?.name ?? "Nivel pendiente"}</span>
              <span>{group?.name ?? "Sin grupo"}</span>
            </div>
          </div>
        </div>
      </header>

      <section className="module-content">
        {messages.updated && <div className="success-banner">✓ Información actualizada.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}

        <div className="profile-metrics">
          <article><span>Grupo</span><strong>{group?.name ?? "Sin asignar"}</strong><small>{coach?.full_name ?? "Sin profesora"}</small></article>
          <article><span>Entrenamientos</span><strong>{group?.group_schedule_slots?.length ?? 0} días</strong><small>{billingProfile?.days_per_week ? `${billingProfile.days_per_week} por semana` : "Frecuencia automática"}</small></article>
          <article><span>Asistencia</span><strong>{attendanceRate}%</strong><small>{presentCount ?? 0} de {attendanceCount ?? 0} registros</small></article>
          <article><span>Saldo pendiente</span><strong>{money(charged - paid)}</strong><Link href={`/pagos/${id}`}>Ver estado de cuenta →</Link></article>
        </div>

        <div className="profile-layout">
          <form action={updateGymnast} className="profile-form">
            <input type="hidden" name="gymnast_id" value={gymnast.id} />
            <section>
              <div className="profile-section-heading"><span>01</span><div><h2>Información personal</h2><p>Identificación y datos deportivos.</p></div></div>
              <div className="form-grid">
                <label>Nombres *<input name="first_name" required defaultValue={gymnast.first_name} /></label>
                <label>Apellidos *<input name="last_name" required defaultValue={gymnast.last_name} /></label>
                <label>Fecha de nacimiento<input name="birth_date" type="date" defaultValue={gymnast.birth_date ?? ""} /></label>
                <label>Documento de identidad<input name="identity_document" defaultValue={gymnast.identity_document ?? ""} /></label>
                <label>Nivel<select name="level_id" defaultValue={gymnast.level_id ?? ""}><option value="">Sin asignar</option>{levels.map((level) => <option value={level.id} key={level.id}>{level.name}</option>)}</select></label>
                <label>Estado<select name="status" defaultValue={gymnast.status}><option value="active">Activa</option><option value="suspended">Pausada</option><option value="retired">Retirada</option></select></label>
                <label className="full-field">Experiencia y observaciones<textarea name="experience_notes" rows={3} defaultValue={gymnast.experience_notes ?? ""} /></label>
              </div>
            </section>

            <section>
              <div className="profile-section-heading"><span>02</span><div><h2>Responsable principal</h2><p>Persona autorizada y datos de contacto.</p></div></div>
              {!guardian && <p className="fieldset-note">Todavía no hay un responsable registrado.</p>}
              <div className="form-grid">
                <label>Nombre completo<input name="guardian_name" defaultValue={guardian?.full_name ?? ""} /></label>
                <label>Documento<input name="guardian_identity_document" defaultValue={guardian?.identity_document ?? ""} /></label>
                <label>Teléfono principal<input name="guardian_phone" type="tel" defaultValue={guardian?.phone ?? ""} /></label>
                <label>Teléfono alterno<input name="guardian_alternate_phone" type="tel" defaultValue={guardian?.alternate_phone ?? ""} /></label>
                <label>Parentesco<select name="guardian_relationship" defaultValue={guardian?.relationship ?? ""}><option value="">Seleccionar</option><option>Madre</option><option>Padre</option><option>Abuela/o</option><option>Otro</option></select></label>
                <label>Correo electrónico<input name="guardian_email" type="email" defaultValue={guardian?.email ?? ""} /></label>
                <label className="full-field">Notas del responsable<textarea name="guardian_notes" rows={2} defaultValue={guardian?.notes ?? ""} /></label>
              </div>
            </section>

            <section>
              <div className="profile-section-heading"><span>03</span><div><h2>Programa y valor del ciclo</h2><p>La tarifa individual puede diferir del tarifario general.</p></div></div>
              <div className="form-grid">
                <label>Programa<select name="billing_program" defaultValue={billingProfile?.program ?? group?.billing_program ?? ""}><option value="">Sin definir</option><option value="Minis">Minis</option><option value="Regular">Regular</option><option value="Intensivo">Integral / Intensivo</option></select></label>
                <label>Días por semana<select name="days_per_week" defaultValue={billingProfile?.days_per_week ?? ""}><option value="">Automático según grupo</option><option value="1">1 día</option><option value="2">2 días</option></select></label>
                <label className="full-field">Valor personalizado por ciclo (COP)<input name="custom_cycle_amount" inputMode="numeric" placeholder="Vacío = tarifa del grupo" defaultValue={billingProfile?.custom_cycle_amount_cents ? billingProfile.custom_cycle_amount_cents / 100 : ""} /></label>
                <label className="full-field">Razón o acuerdo especial<textarea name="pricing_notes" rows={2} placeholder="Ej. Beca 50%, descuento familiar, horario adicional..." defaultValue={billingProfile?.pricing_notes ?? ""} /></label>
              </div>
            </section>

            <section>
              <div className="profile-section-heading"><span>04</span><div><h2>Contacto y salud</h2><p>Información privada para atender emergencias.</p></div></div>
              <div className="form-grid">
                <label className="full-field">Dirección<input name="address" defaultValue={privateData?.address ?? ""} /></label>
                <label>EPS / aseguradora<input name="health_provider" defaultValue={privateData?.health_provider ?? ""} /></label>
                <label>Alergias o condiciones<input name="allergies_conditions" defaultValue={privateData?.allergies_conditions ?? ""} /></label>
                <label>Contacto de emergencia<input name="emergency_contact_name" defaultValue={privateData?.emergency_contact_name ?? ""} /></label>
                <label>Teléfono de emergencia<input name="emergency_contact_phone" type="tel" defaultValue={privateData?.emergency_contact_phone ?? ""} /></label>
                <label className="full-field">Notas médicas<textarea name="medical_notes" rows={3} defaultValue={privateData?.medical_notes ?? ""} /></label>
              </div>
            </section>
            <div className="profile-save"><Link href="/gimnastas">Cancelar</Link><button className="primary-button">Guardar toda la ficha</button></div>
          </form>

          <aside className="profile-sidebar">
            <section>
              <span className="section-kicker">Horario actual</span>
              <h2>{group?.name ?? "Sin grupo asignado"}</h2>
              {(group?.group_schedule_slots ?? []).map((slot) => (
                <div className="profile-schedule" key={`${slot.weekday}-${slot.starts_at}`}>
                  <strong>{dayNames[slot.weekday]}</strong>
                  <span>{slot.starts_at.slice(0, 5)} – {slot.ends_at.slice(0, 5)}</span>
                  <small>{slot.location || "Sede principal"}</small>
                </div>
              ))}
              {!group && <Link href="/grupos">Asignar a un grupo →</Link>}
            </section>
            <section>
              <span className="section-kicker">Datos pendientes</span>
              <ul className="profile-checklist">
                <li className={gymnast.identity_document ? "done" : ""}>Documento de la gimnasta</li>
                <li className={gymnast.birth_date ? "done" : ""}>Fecha de nacimiento</li>
                <li className={guardian?.phone && guardian.phone !== "Por completar" ? "done" : ""}>Teléfono responsable</li>
                <li className={privateData?.emergency_contact_phone ? "done" : ""}>Contacto de emergencia</li>
                <li className={group ? "done" : ""}>Grupo y horario</li>
              </ul>
            </section>
          </aside>
        </div>
      </section>
    </main>
  );
}
