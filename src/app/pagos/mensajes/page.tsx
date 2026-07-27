import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CopyMessage } from "./copy-message";
import { createCommunicationTemplate } from "./actions";

export default async function CollectionMessagesPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const messages = await searchParams;
  const { data } = await supabase.from("communication_templates")
    .select("id, name, channel, body, meta_template_name")
    .eq("active", true)
    .eq("purpose", "cycle_collection")
    .order("name");
  const templates = data ?? [];

  return (
    <main className="module-page">
      <header className="module-header">
        <div>
          <Link href="/pagos" className="back-link">← Volver a cartera</Link>
          <p className="eyebrow">Textos originales del club</p>
          <h1>Plantillas de cobro</h1>
          <p>Guarda una sola vez los mensajes que ya utilizas y cópialos sin modificarlos.</p>
        </div>
      </header>
      <section className="module-content message-template-layout">
        <div className="collection-message-list">
          {messages.created && <div className="success-banner">✓ Plantilla original guardada.</div>}
          {messages.error && <div className="error-banner">{messages.error}</div>}
          {templates.length === 0 ? (
            <div className="data-panel table-empty">
              <span>⌘</span><h3>La exportación no incluyó las plantillas</h3>
              <p>Pega a la derecha cada texto original de Notion. No será reescrito.</p>
            </div>
          ) : templates.map((template) => (
            <article className="collection-message-card" key={template.id}>
              <div className="collection-message-heading">
                <div><span className="notion-tag program-intensivo">{template.channel}</span><h2>{template.name}</h2></div>
              </div>
              <textarea readOnly value={template.body} aria-label={template.name} />
              <div>
                <small>{template.meta_template_name ? `Meta: ${template.meta_template_name}` : "Copia manual · aún no conectada con Meta"}</small>
                <CopyMessage message={template.body} />
              </div>
            </article>
          ))}
        </div>
        <aside className="preparation-form-card">
          <p className="eyebrow">Importar texto original</p>
          <h2>Nueva plantilla</h2>
          <form action={createCommunicationTemplate} className="club-form">
            <label className="full-field">Nombre *<input name="name" required placeholder="Ej. Cobro ciclo vencido" /></label>
            <label className="full-field">Canal<select name="channel" defaultValue="whatsapp"><option value="whatsapp">WhatsApp</option><option value="instagram">Instagram</option><option value="general">General</option></select></label>
            <label className="full-field">Texto exacto *<textarea name="body" rows={12} required placeholder="Pega aquí la plantilla tal como está en Notion..." /></label>
            <button className="primary-button full-field">Guardar sin modificar</button>
          </form>
        </aside>
      </section>
    </main>
  );
}
