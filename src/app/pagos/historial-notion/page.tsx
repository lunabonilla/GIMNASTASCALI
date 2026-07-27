import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const PAGE_SIZE = 50;

type RawRecord = Record<string, string | number | null>;

const field = (record: RawRecord, ...names: string[]) => {
  for (const name of names) {
    if (record[name] !== undefined && record[name] !== null && record[name] !== "") {
      return String(record[name]);
    }
  }
  return "Sin registrar";
};

export default async function NotionHistoryPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string; type?: string; q?: string; view?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const params = await searchParams;
  const page = Math.max(1, Number(params.page) || 1);
  const type = params.type === "cycle" || params.type === "movement" ? params.type : "";
  const query = params.q?.trim() ?? "";
  const exceptionsOnly = params.view === "exceptions";

  if (exceptionsOnly) {
    const { data, count } = await supabase
      .from("notion_import_exceptions")
      .select("id, person_name, reason, raw_data", { count: "exact" })
      .order("person_name")
      .range((page - 1) * PAGE_SIZE, page * PAGE_SIZE - 1);
    const rows = (data ?? []) as Array<{
      id: number; person_name: string | null; reason: string; raw_data: RawRecord;
    }>;
    return (
      <ArchiveShell title="Pendientes de asociación" subtitle={`${count ?? 0} registros requieren revisión manual`}>
        <ArchiveTabs active="exceptions" />
        <div className="archive-list">
          {rows.map((row) => (
            <article key={row.id}>
              <div><strong>{row.person_name || "Nombre vacío"}</strong><span>{row.reason}</span></div>
              <div><span>{field(row.raw_data, "concept")}</span><strong>{field(row.raw_data, "amount_cents")}</strong></div>
            </article>
          ))}
        </div>
        <Pagination page={page} count={count ?? 0} href="/pagos/historial-notion?view=exceptions" />
      </ArchiveShell>
    );
  }

  let archiveQuery = supabase
    .from("notion_financial_archive")
    .select("id, record_type, person_name, raw_data", { count: "exact" })
    .order("id")
    .range((page - 1) * PAGE_SIZE, page * PAGE_SIZE - 1);
  if (type) archiveQuery = archiveQuery.eq("record_type", type);
  if (query) archiveQuery = archiveQuery.ilike("person_name", `%${query}%`);
  const { data, count } = await archiveQuery;
  const rows = (data ?? []) as Array<{
    id: number; record_type: "movement" | "cycle"; person_name: string | null; raw_data: RawRecord;
  }>;

  const suffix = new URLSearchParams();
  if (type) suffix.set("type", type);
  if (query) suffix.set("q", query);
  const paginationHref = `/pagos/historial-notion?${suffix.toString()}`;

  return (
    <ArchiveShell title="Archivo financiero de Notion" subtitle={`${count ?? 0} registros originales encontrados`}>
      <ArchiveTabs active="archive" />
      <form className="archive-filters">
        <input name="q" defaultValue={query} placeholder="Buscar deportista" />
        <select name="type" defaultValue={type}>
          <option value="">Todos los registros</option>
          <option value="movement">Movimientos</option>
          <option value="cycle">Ciclos</option>
        </select>
        <button>Filtrar</button>
      </form>
      <div className="archive-list">
        {rows.map((row) => (
          <article key={row.id}>
            <div>
              <span className="section-kicker">{row.record_type === "cycle" ? "Ciclo" : field(row.raw_data, "Concepto", "Tipo")}</span>
              <strong>{row.person_name || "Sin deportista"}</strong>
              <span>{field(row.raw_data, "Fecha", "Inicio ciclo")}</span>
            </div>
            <div>
              <strong>{field(row.raw_data, "Valor", "Valor pagado")}</strong>
              <span>{field(row.raw_data, "Estado", "Estado del ciclo")}</span>
              <small>{field(row.raw_data, "Observaciones", "Profesor", "Programa")}</small>
            </div>
          </article>
        ))}
      </div>
      <Pagination page={page} count={count ?? 0} href={paginationHref} />
    </ArchiveShell>
  );
}

function ArchiveShell({
  title, subtitle, children,
}: {
  title: string; subtitle: string; children: React.ReactNode;
}) {
  return (
    <main className="module-page">
      <header className="module-header">
        <div><Link href="/pagos" className="back-link">← Volver a cartera</Link><p className="eyebrow">Migración histórica</p><h1>{title}</h1><p>{subtitle}</p></div>
      </header>
      <section className="module-content">{children}</section>
    </main>
  );
}

function ArchiveTabs({ active }: { active: "archive" | "exceptions" }) {
  return (
    <div className="archive-tabs">
      <Link className={active === "archive" ? "active" : ""} href="/pagos/historial-notion">Todos los datos originales</Link>
      <Link className={active === "exceptions" ? "active" : ""} href="/pagos/historial-notion?view=exceptions">Pendientes de asociación</Link>
    </div>
  );
}

function Pagination({ page, count, href }: { page: number; count: number; href: string }) {
  const separator = href.includes("?") && !href.endsWith("?") ? "&" : "";
  return (
    <nav className="archive-pagination">
      {page > 1 ? <Link href={`${href}${separator}page=${page - 1}`}>← Anterior</Link> : <span />}
      <span>Página {page} de {Math.max(1, Math.ceil(count / PAGE_SIZE))}</span>
      {page * PAGE_SIZE < count ? <Link href={`${href}${separator}page=${page + 1}`}>Siguiente →</Link> : <span />}
    </nav>
  );
}
