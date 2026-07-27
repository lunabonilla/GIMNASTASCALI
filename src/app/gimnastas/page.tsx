import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

type SearchParams = Promise<{ q?: string; created?: string }>;

export default async function GymnastsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const { q = "", created } = await searchParams;
  let query = supabase
    .from("gymnasts")
    .select("id, first_name, last_name, birth_date, identity_document, status, levels(name), gymnast_guardians(guardian_id)")
    .order("first_name");

  if (q.trim()) {
    const safeQuery = q.trim().replaceAll(",", " ");
    query = query.or(
      `first_name.ilike.%${safeQuery}%,last_name.ilike.%${safeQuery}%,identity_document.ilike.%${safeQuery}%`,
    );
  }

  const { data, error } = await query;
  const gymnasts = (data ?? []) as Array<{
    id: string;
    first_name: string;
    last_name: string;
    birth_date: string | null;
    identity_document: string | null;
    status: "active" | "suspended" | "retired";
    levels: Array<{ name: string }> | null;
    gymnast_guardians: Array<{ guardian_id: string }>;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Gestión deportiva</p>
          <h1>Gimnastas</h1>
          <p>Consulta y administra las deportistas del club.</p>
        </div>
        <Link href="/gimnastas/nueva" className="primary-button">
          ＋ Nueva gimnasta
        </Link>
      </header>

      <section className="module-content">
        {created && (
          <div className="success-banner">✓ Gimnasta registrada correctamente.</div>
        )}

        <form className="search-bar">
          <input
            type="search"
            name="q"
            defaultValue={q}
            placeholder="Buscar por nombre o documento"
            aria-label="Buscar gimnastas"
          />
          <button type="submit">Buscar</button>
          {q && <Link href="/gimnastas">Limpiar</Link>}
        </form>

        <section className="data-panel">
          <div className="data-panel-heading">
            <div>
              <span className="section-kicker">Directorio</span>
              <h2>{gymnasts.length} gimnastas</h2>
            </div>
          </div>

          {error ? (
            <div className="table-empty">No pudimos cargar la información.</div>
          ) : gymnasts.length === 0 ? (
            <div className="table-empty">
              <span>○</span>
              <h3>{q ? "No encontramos coincidencias" : "Aún no hay gimnastas"}</h3>
              <p>
                {q
                  ? "Intenta con otro nombre o documento."
                  : "Registra la primera deportista para comenzar."}
              </p>
              {!q && <Link href="/gimnastas/nueva">Registrar gimnasta</Link>}
            </div>
          ) : (
            <div className="table-scroll">
              <table>
                <thead>
                  <tr>
                    <th>Gimnasta</th>
                    <th>Documento</th>
                    <th>Fecha de nacimiento</th>
                    <th>Nivel</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {gymnasts.map((gymnast) => (
                    <tr key={gymnast.id}>
                      <td>
                        <Link href={`/gimnastas/${gymnast.id}`} className="row-link">
                          {gymnast.first_name} {gymnast.last_name}
                        </Link>
                      </td>
                      <td>{gymnast.identity_document || "Sin registrar"}</td>
                      <td>
                        {gymnast.birth_date
                          ? new Intl.DateTimeFormat("es-CO", {
                              dateStyle: "medium",
                              timeZone: "UTC",
                            }).format(new Date(gymnast.birth_date))
                          : "Sin registrar"}
                      </td>
                      <td>{gymnast.levels?.[0]?.name || "Sin asignar"}</td>
                      <td>
                        {gymnast.gymnast_guardians.length ? (
                          <span className="status-chip">Completa</span>
                        ) : (
                          <span className="status-chip pending">Información pendiente</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </section>
    </main>
  );
}
