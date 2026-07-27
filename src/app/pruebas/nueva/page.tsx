import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createTrial } from "../actions";

export default async function NewTrialPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const { error } = await searchParams;

  return (
    <main className="form-page">
      <div className="form-card">
        <Link href="/pruebas" className="back-link">← Volver a clases de prueba</Link>
        <div className="form-heading">
          <span className="section-kicker">Nueva visita</span>
          <h1>Agendar clase de prueba</h1>
          <p className="form-price-note">Tarifa vigente: <strong>$60.000</strong></p>
          <p>Registra a la niña, su responsable y el momento de la visita.</p>
        </div>
        {error && <div className="error-banner">{error}</div>}
        <form action={createTrial} className="gymnast-form">
          <fieldset>
            <legend>Información de la niña</legend>
            <div className="form-grid">
              <label>Nombres *<input name="first_name" required /></label>
              <label>Apellidos *<input name="last_name" required /></label>
              <label>Fecha de nacimiento *<input name="birth_date" type="date" required /></label>
              <label>Experiencia previa<input name="experience_notes" placeholder="Opcional" /></label>
            </div>
          </fieldset>
          <fieldset>
            <legend>Responsable</legend>
            <div className="form-grid">
              <label>Nombre completo *<input name="guardian_name" required /></label>
              <label>Teléfono *<input name="guardian_phone" type="tel" required /></label>
              <label className="full-field">Correo electrónico<input name="guardian_email" type="email" /></label>
            </div>
          </fieldset>
          <fieldset>
            <legend>Agenda</legend>
            <div className="form-grid">
              <label>Fecha *<input name="date" type="date" required /></label>
              <label>Hora *<input name="time" type="time" required /></label>
            </div>
          </fieldset>
          <div className="form-actions">
            <Link href="/pruebas">Cancelar</Link>
            <button type="submit" className="primary-button">Agendar prueba</button>
          </div>
        </form>
      </div>
    </main>
  );
}
