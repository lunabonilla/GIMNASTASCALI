import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { adjustStock, createProduct } from "./actions";

const money = (cents: number) =>
  new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(cents / 100);
const labels: Record<string, string> = {
  training_leotard: "Trusa de entreno", gala_leotard: "Trusa de gala",
  grips: "Guantes de barra", wristbands: "Muñequeras", shirt: "Camiseta", other: "Otro",
};

export default async function InventoryPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; adjusted?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const messages = await searchParams;
  const { data, error } = await supabase.from("products").select("*").eq("active", true).order("name").order("variant");
  const products = (data ?? []) as Array<{
    id: string; name: string; category: string; variant: string | null; sku: string | null;
    sale_price_cents: number; stock_quantity: number; minimum_stock: number;
  }>;

  return (
    <main className="module-page">
      <header className="module-header">
        <div><Link href="/" className="back-link">← Volver al inicio</Link><p className="eyebrow">Tienda del club</p><h1>Inventario</h1><p>Controla artículos, tallas, precios y existencias.</p></div>
        <Link href="/ventas" className="primary-button">Registrar venta →</Link>
      </header>
      <section className="module-content">
        {messages.created && <div className="success-banner">✓ Producto creado.</div>}
        {messages.adjusted && <div className="success-banner">✓ Existencias actualizadas.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}

        <details className="create-product-box">
          <summary>＋ Agregar producto o talla</summary>
          <form action={createProduct} className="club-form compact-form">
            <label>Producto *<input name="name" placeholder="Ej. Trusa morada" required /></label>
            <label>Tipo *<select name="category" required><option value="training_leotard">Trusa de entreno</option><option value="gala_leotard">Trusa de gala</option><option value="grips">Guantes de barra</option><option value="wristbands">Muñequeras</option><option value="shirt">Camiseta</option><option value="other">Otro</option></select></label>
            <label>Talla o variante<input name="variant" placeholder="Ej. Talla 8 / Morado" /></label>
            <label>Código SKU<input name="sku" placeholder="Opcional" /></label>
            <label>Precio de venta *<input name="sale_price" inputMode="numeric" required /></label>
            <label>Costo<input name="cost" inputMode="numeric" /></label>
            <label>Existencia inicial *<input name="stock_quantity" type="number" min="0" defaultValue="0" required /></label>
            <label>Alerta de stock<input name="minimum_stock" type="number" min="0" defaultValue="2" /></label>
            <button type="submit" className="primary-button">Guardar producto</button>
          </form>
        </details>

        {error ? <div className="data-panel table-empty">No pudimos cargar el inventario.</div> : products.length === 0 ? (
          <div className="data-panel table-empty"><span>□</span><h3>Inventario vacío</h3><p>Abre “Agregar producto o talla” para comenzar.</p></div>
        ) : (
          <div className="product-grid">
            {products.map((product) => {
              const low = product.stock_quantity <= product.minimum_stock;
              return (
                <article className="product-card" key={product.id}>
                  <div><span className="section-kicker">{labels[product.category] ?? "Artículo"}</span><h2>{product.name}</h2><p>{product.variant || "Sin variante"}{product.sku ? ` · ${product.sku}` : ""}</p></div>
                  <strong className="product-price">{money(product.sale_price_cents)}</strong>
                  <div className={`stock-count ${low ? "low" : ""}`}><span>Existencias</span><strong>{product.stock_quantity}</strong><small>{low ? "Stock bajo" : "Disponible"}</small></div>
                  <details className="stock-adjust"><summary>Ajustar existencias</summary><form action={adjustStock}><input type="hidden" name="product_id" value={product.id} /><input name="quantity" type="number" placeholder="+5 o -2" required /><input name="reason" placeholder="Motivo" /><button>Guardar</button></form></details>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
