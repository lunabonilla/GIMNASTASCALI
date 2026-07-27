import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { updateGymnast } from "../actions";

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ error?: string; updated?: string }>;
};

export default async function GymnastProfilePage({
  params,
  searchParams,
}: PageProps) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { id } = await params;
  const { error, updated } = await searchParams;
  const [{ data: gymnast }, { data: links }, { data: levelData }] =
    await Promise.all([
      supabase
        .from("gymnasts")
        .select("id, first_name, last_name, birth_date, identity_document, level_id")
        .eq("id", id)
        .single(),
      supabase
        .from("gymnast_guardians")
        .select("guardians(full_name, phone, relationship, email)")
        .eq("gymnast_id", id)
        .eq("is_primary", true)
        .maybeSingle(),
      supabase
        .from("levels")
        .select("id, name")
        .eq("active", true)
        .order("sort_order"),
    ]);

  if (!gymnast) notFound();

  const profile = gymnast as {
    id: string;
    first_name: string;
    last_name: string;
    birth_date: string | null;
    identity_document: string | null;
    level_id: string | null;
  };
  const guardianLink = links as {
    guardians: Array<{
      full_name: string;
      phone: string;
      relationship: string | null;
      email: string | null;
    }> | null;
  } | null;
  const guardian = guardianLink?.guardians?.[0];
  const levels = (levelData ?? []) as Array<{ id: string; name: string }>;

  return (
    <main className="form-page">
      <div className="form-card">
        <Link href="/gimnastas" className="back-link">← Volver a gimnastas</Link>
        <div className="form-heading">
          <span className="section-kicker">Ficha de deportista</span>
          <h1>{profile.first_name} {profile.last_name}</h1>
          <p>Edita la información disponible cuando la vayas obteniendo.</p>
        </div>

        {updated && <div className="success-banner">✓ Información actualizada.</div>}
        {error && <div className="error-banner">{error}</div>}

        <form action={updateGymnast} className="gymnast-form">
          <input type="hidden" name="gymnast_id" value={profile.id} />
          <fieldset>
            <legend>Información de la gimnasta</legend>
            <div className="form-grid">
              <label>
                Nombres *
                <input name="first_name" required defaultValue={profile.first_name} />
              </label>
              <label>
                Apellidos *
                <input name="last_name" required defaultValue={profile.last_name} />
              </label>
              <label>
                Fecha de nacimiento
                <input name="birth_date" type="date" defaultValue={profile.birth_date ?? ""} />
              </label>
              <label>
                Documento de identidad
                <input name="identity_document" defaultValue={profile.identity_document ?? ""} />
              </label>
              <label className="full-field">
                Nivel
                <select name="level_id" defaultValue={profile.level_id ?? ""}>
                  <option value="">Sin asignar</option>
                  {levels.map((level) => (
                    <option value={level.id} key={level.id}>{level.name}</option>
                  ))}
                </select>
              </label>
            </div>
          </fieldset>

          <fieldset>
            <legend>Responsable principal</legend>
            {!guardian && (
              <p className="fieldset-note">Todavía no hay un responsable registrado.</p>
            )}
            <div className="form-grid">
              <label>
                Nombre completo
                <input name="guardian_name" defaultValue={guardian?.full_name ?? ""} />
              </label>
              <label>
                Número de contacto
                <input name="guardian_phone" type="tel" defaultValue={guardian?.phone ?? ""} />
              </label>
              <label>
                Parentesco
                <select name="guardian_relationship" defaultValue={guardian?.relationship ?? ""}>
                  <option value="">Seleccionar</option>
                  <option>Madre</option>
                  <option>Padre</option>
                  <option>Abuela/o</option>
                  <option>Otro</option>
                </select>
              </label>
              <label>
                Correo electrónico
                <input name="guardian_email" type="email" defaultValue={guardian?.email ?? ""} />
              </label>
            </div>
          </fieldset>

          <div className="form-actions">
            <Link href="/gimnastas">Cancelar</Link>
            <button type="submit" className="primary-button">Guardar cambios</button>
          </div>
        </form>
      </div>
    </main>
  );
}
