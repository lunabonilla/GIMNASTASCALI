import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

type SearchParams = Promise<{
  q?: string;
  status?: string;
  level?: string;
  created?: string;
  imported?: string;
  pending?: string;
}>;

export default async function GymnastsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");

  const {
    q = "",
    status = "active",
    level = "",
    created,
    imported,
    pending,
  } = await searchParams;
  let query = supabase
    .from("gymnasts")
    .select("id, first_name, last_name, birth_date, identity_document, status, levels(name), gymnast_guardians(guardian_id), gymnast_billing_profiles(program, days_per_week), enrollments(active, training_groups(name, group_schedule_slots(weekday)))")
    .order("first_name");

  if (q.trim()) {
    const safeQuery = q.trim().replaceAll(",", " ");
    query = query.or(
      `first_name.ilike.%${safeQuery}%,last_name.ilike.%${safeQuery}%,identity_document.ilike.%${safeQuery}%`,
    );
  }
  if (["active", "suspended", "retired"].includes(status)) {
    query = query.eq("status", status);
  }
  if (level) {
    query = query.eq("level_id", level);
  }

  const [{ data, error }, { data: levelData }] = await Promise.all([
    query,
    supabase
      .from("levels")
      .select("id, name")
      .eq("active", true)
      .order("sort_order"),
  ]);
  const levels = (levelData ?? []) as Array<{ id: string; name: string }>;
  const gymnasts = (data ?? []) as Array<{
    id: string;
    first_name: string;
    last_name: string;
    birth_date: string | null;
    identity_document: string | null;
    status: "active" | "suspended" | "retired";
    levels: { name: string } | Array<{ name: string }> | null;
    gymnast_guardians: Array<{ guardian_id: string }>;
    gymnast_billing_profiles:
      | { program: string | null; days_per_week: number | null }
      | Array<{ program: string | null; days_per_week: number | null }>
      | null;
    enrollments: Array<{
      active: boolean;
      training_groups:
        | { name: string; group_schedule_slots: Array<{ weekday: number }> }
        | Array<{ name: string; group_schedule_slots: Array<{ weekday: number }> }>
        | null;
    }>;
  }>;
  const dayLabels: Record<number, string> = {
    1: "Lun", 2: "Mar", 3: "Mié", 4: "Jue", 5: "Vie", 6: "Sáb", 7: "Dom",
  };
  const tagClass = (value: string | null | undefined, prefix: string) =>
    `${prefix}-${String(value ?? "none")
      .normalize("NFD").replace(/\p{Diacritic}/gu, "")
      .toLowerCase().replace(/\s+/g, "-")}`;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Gestión deportiva</p>
          <h1>Gimnastas</h1>
          <p>Consulta y administra las deportistas del club.</p>
        </div>
        <div className="module-actions">
          <Link href="/gimnastas/importar" className="outline-button">
            Importar Notion
          </Link>
          <Link href="/gimnastas/nueva" className="primary-button">
            ＋ Nueva gimnasta
          </Link>
        </div>
      </header>

      <section className="module-content">
        {created && (
          <div className="success-banner">✓ Gimnasta registrada correctamente.</div>
        )}
        {imported && (
          <div className="success-banner">
            ✓ {imported === "0" ? "La base ya estaba importada" : `${imported} gimnastas importadas`}.
            {" "}{pending ?? "0"} registros quedaron pendientes por nombre
            duplicado.
          </div>
        )}

        <form className="search-bar filter-bar">
          <input
            type="search"
            name="q"
            defaultValue={q}
            placeholder="Buscar por nombre o documento"
            aria-label="Buscar gimnastas"
          />
          <select name="status" defaultValue={status} aria-label="Filtrar por estado">
            <option value="active">Activas</option>
            <option value="suspended">Pausadas</option>
            <option value="retired">Retiradas</option>
            <option value="all">Todos los estados</option>
          </select>
          <select name="level" defaultValue={level} aria-label="Filtrar por nivel">
            <option value="">Todos los niveles</option>
            {levels.map((item) => (
              <option value={item.id} key={item.id}>{item.name}</option>
            ))}
          </select>
          <button type="submit">Aplicar</button>
          {(q || status !== "active" || level) && (
            <Link href="/gimnastas">Limpiar</Link>
          )}
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
                    <th>Programa</th>
                    <th>Nivel</th>
                    <th>Grupo y días</th>
                    <th>Estado deportivo</th>
                    <th>Información</th>
                  </tr>
                </thead>
                <tbody>
                  {gymnasts.map((gymnast) => {
                    const billing = Array.isArray(gymnast.gymnast_billing_profiles)
                      ? gymnast.gymnast_billing_profiles[0]
                      : gymnast.gymnast_billing_profiles;
                    const enrollment = gymnast.enrollments.find((item) => item.active);
                    const group = Array.isArray(enrollment?.training_groups)
                      ? enrollment?.training_groups[0]
                      : enrollment?.training_groups;
                    const days = (group?.group_schedule_slots ?? [])
                      .map((slot) => dayLabels[slot.weekday])
                      .join(", ");
                    const gymnastLevel = Array.isArray(gymnast.levels)
                      ? gymnast.levels[0]
                      : gymnast.levels;
                    return (
                    <tr key={gymnast.id}>
                      <td>
                        <Link href={`/gimnastas/${gymnast.id}`} className="row-link">
                          {gymnast.first_name} {gymnast.last_name}
                        </Link>
                        <small className="table-secondary">{gymnast.identity_document || "Documento pendiente"}</small>
                      </td>
                      <td><span className={`notion-tag ${tagClass(billing?.program, "program")}`}>{billing?.program || "Sin programa"}</span></td>
                      <td><span className={`notion-tag ${tagClass(gymnastLevel?.name, "level")}`}>{gymnastLevel?.name || "Sin asignar"}</span></td>
                      <td>
                        <strong className="table-group-name">{group?.name || "Sin grupo"}</strong>
                        <small className="table-secondary">{days || "Días pendientes"}</small>
                      </td>
                      <td>
                        <span className={`sport-status ${gymnast.status}`}>
                          {gymnast.status === "active"
                            ? "Activa"
                            : gymnast.status === "suspended"
                              ? "Pausada"
                              : "Retirada"}
                        </span>
                      </td>
                      <td>
                        {gymnast.gymnast_guardians.length ? (
                          <span className="status-chip">Completa</span>
                        ) : (
                          <span className="status-chip pending">Información pendiente</span>
                        )}
                      </td>
                    </tr>
                  );})}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </section>
    </main>
  );
}
