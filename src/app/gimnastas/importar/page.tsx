import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { importGymnasts } from "../actions";

export default async function ImportGymnastsPage({
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
      <div className="form-card import-card">
        <Link href="/gimnastas" className="back-link">← Volver a gimnastas</Link>
        <div className="form-heading">
          <span className="section-kicker">Importación privada</span>
          <h1>Importar desde Notion</h1>
          <p>
            Selecciona la base “Control de pagos”. Los responsables podrán
            completarse después desde cada ficha.
          </p>
        </div>

        {error && <div className="error-banner">{error}</div>}

        <div className="import-summary">
          <strong>Configuración preparada</strong>
          <ul>
            <li>Conserva el estado activo, pausado o retirado.</li>
            <li>Crea automáticamente los niveles encontrados.</li>
            <li>Omite nombres repetidos para revisión manual.</li>
            <li>No envía el archivo a GitHub.</li>
          </ul>
        </div>

        <form action={importGymnasts} className="import-form">
          <label>
            Archivo CSV de Notion
            <input
              type="file"
              name="notion_csv"
              accept=".csv,text/csv"
              required
            />
          </label>
          <div className="form-actions">
            <Link href="/gimnastas">Cancelar</Link>
            <button className="primary-button" type="submit">
              Importar gimnastas
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
