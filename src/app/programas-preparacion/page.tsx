import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createPreparationProgram } from "./actions";

const money = (cents: number | null) =>
  cents === null
    ? "Valor por definir"
    : new Intl.NumberFormat("es-CO", {
        style: "currency", currency: "COP", maximumFractionDigits: 0,
      }).format(cents / 100);

const statusLabels: Record<string, string> = {
  draft: "Borrador",
  open: "Inscripciones",
  active: "En curso",
  finished: "Finalizado",
  cancelled: "Cancelado",
};

export default async function PreparationProgramsPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const messages = await searchParams;
  const { data, error } = await supabase
    .from("preparation_programs")
    .select("id, name, description, coach_name, starts_on, ends_on, base_price_cents, status, preparation_program_enrollments(count)")
    .order("starts_on", { ascending: false });
  const programs = (data ?? []) as Array<{
    id: string;
    name: string;
    description: string | null;
    coach_name: string | null;
    starts_on: string | null;
    ends_on: string | null;
    base_price_cents: number | null;
    status: string;
    preparation_program_enrollments: Array<{ count: number }>;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/" className="back-link">← Volver al inicio</Link>
          <p className="eyebrow">Preparación especial</p>
          <h1>Programas de preparación</h1>
          <p>Organiza planes adicionales, concentraciones y preparación para eventos.</p>
        </div>
      </header>
      <section className="module-content preparation-layout">
        <div>
          {messages.created && <div className="success-banner">✓ Programa creado correctamente.</div>}
          {messages.error && <div className="error-banner">{messages.error}</div>}
          {error ? (
            <div className="data-panel table-empty">No pudimos cargar los programas.</div>
          ) : programs.length === 0 ? (
            <div className="data-panel table-empty">
              <span>★</span><h3>No hay programas adicionales</h3>
              <p>Crea el primero usando el formulario.</p>
            </div>
          ) : (
            <div className="preparation-list">
              {programs.map((program) => (
                <article className="preparation-card" key={program.id}>
                  <div>
                    <span className={`preparation-status ${program.status}`}>{statusLabels[program.status]}</span>
                    <h2>{program.name}</h2>
                    <p>{program.description || "Sin descripción"}</p>
                  </div>
                  <dl>
                    <div><dt>Profesora</dt><dd>{program.coach_name || "Por asignar"}</dd></div>
                    <div><dt>Fechas</dt><dd>{program.starts_on || "Por definir"} → {program.ends_on || "Por definir"}</dd></div>
                    <div><dt>Valor base</dt><dd>{money(program.base_price_cents)}</dd></div>
                    <div><dt>Inscritas</dt><dd>{program.preparation_program_enrollments?.[0]?.count ?? 0}</dd></div>
                  </dl>
                </article>
              ))}
            </div>
          )}
        </div>
        <aside className="preparation-form-card">
          <p className="eyebrow">Nuevo programa</p>
          <h2>Crear preparación</h2>
          <form action={createPreparationProgram} className="club-form">
            <label className="full-field">Nombre *<input name="name" required placeholder="Ej. Preparación Ibagué 2026" /></label>
            <label>Inicio<input type="date" name="starts_on" /></label>
            <label>Final<input type="date" name="ends_on" /></label>
            <label>Profesora<input name="coach_name" placeholder="Nombre" /></label>
            <label>Valor base<input name="base_price" inputMode="numeric" placeholder="Ej. 250000" /></label>
            <label className="full-field">Estado<select name="status" defaultValue="draft"><option value="draft">Borrador</option><option value="open">Inscripciones</option><option value="active">En curso</option></select></label>
            <label className="full-field">Descripción<textarea name="description" rows={4} placeholder="Objetivo, horarios, evento..." /></label>
            <button className="primary-button full-field">Guardar programa</button>
          </form>
        </aside>
      </section>
    </main>
  );
}
