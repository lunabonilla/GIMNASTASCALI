import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createGymnast } from "../actions";

type SearchParams = Promise<{ error?: string }>;

export default async function NewGymnastPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { data } = await supabase
    .from("levels")
    .select("id, name")
    .eq("active", true)
    .order("sort_order");
  const levels = (data ?? []) as Array<{ id: string; name: string }>;
  const { error } = await searchParams;

  return (
    <main className="form-page">
      <div className="form-card">
        <Link href="/gimnastas" className="back-link">← Volver a gimnastas</Link>
        <div className="form-heading">
          <span className="section-kicker">Nueva deportista</span>
          <h1>Registrar gimnasta</h1>
          <p>Los campos marcados con * son obligatorios.</p>
        </div>

        {error && <div className="error-banner">{error}</div>}

        <form action={createGymnast} className="gymnast-form">
          <fieldset>
            <legend>Información de la gimnasta</legend>
            <div className="form-grid">
              <label>
                Nombres *
                <input name="first_name" required autoComplete="given-name" />
              </label>
              <label>
                Apellidos *
                <input name="last_name" required autoComplete="family-name" />
              </label>
              <label>
                Fecha de nacimiento *
                <input name="birth_date" type="date" required />
              </label>
              <label>
                Documento de identidad
                <input name="identity_document" inputMode="numeric" />
              </label>
              <label className="full-field">
                Nivel
                <select name="level_id" defaultValue="">
                  <option value="">Sin asignar</option>
                  {levels.map((level) => (
                    <option value={level.id} key={level.id}>{level.name}</option>
                  ))}
                </select>
                {levels.length === 0 && (
                  <small>Podrás asignar el nivel cuando configuremos los niveles del club.</small>
                )}
              </label>
            </div>
          </fieldset>

          <fieldset>
            <legend>Responsable principal</legend>
            <div className="form-grid">
              <label>
                Nombre completo *
                <input name="guardian_name" required autoComplete="name" />
              </label>
              <label>
                Número de contacto *
                <input name="guardian_phone" required type="tel" autoComplete="tel" />
              </label>
              <label>
                Parentesco
                <select name="guardian_relationship" defaultValue="">
                  <option value="">Seleccionar</option>
                  <option>Madre</option>
                  <option>Padre</option>
                  <option>Abuela/o</option>
                  <option>Otro</option>
                </select>
              </label>
              <label>
                Correo electrónico
                <input name="guardian_email" type="email" autoComplete="email" />
              </label>
            </div>
          </fieldset>

          <div className="form-actions">
            <Link href="/gimnastas">Cancelar</Link>
            <button type="submit" className="primary-button">Guardar gimnasta</button>
          </div>
        </form>
      </div>
    </main>
  );
}
