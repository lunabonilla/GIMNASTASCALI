import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createSale } from "./actions";

const money = (cents: number) => new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(cents / 100);

export default async function SalesPage({ searchParams }: { searchParams: Promise<{ created?: string; error?: string }> }) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const messages = await searchParams;
  const [{ data: products }, { data: gymnasts }, { data: sales }] = await Promise.all([
    supabase.from("products").select("id, name, variant, sale_price_cents, stock_quantity").eq("active", true).gt("stock_quantity", 0).order("name"),
    supabase.from("gymnasts").select("id, first_name, last_name").neq("status", "retired").order("first_name"),
    supabase.from("sales").select("id, sold_on, customer_name, total_cents, payment_status, gymnasts(first_name, last_name), sale_items(quantity, products(name, variant))").order("created_at", { ascending: false }).limit(50),
  ]);
  const saleRows = (sales ?? []) as Array<{ id: string; sold_on: string; customer_name: string | null; total_cents: number; payment_status: string; gymnasts: Array<{ first_name: string; last_name: string }> | null; sale_items: Array<{ quantity: number; products: Array<{ name: string; variant: string | null }> | null }> }>;

  return (
    <main className="module-page">
      <header className="module-header"><div><Link href="/" className="back-link">← Volver al inicio</Link><p className="eyebrow">Tienda del club</p><h1>Ventas</h1><p>Registra compras y descuenta automáticamente las existencias.</p></div><Link href="/inventario" className="secondary-button">Ver inventario</Link></header>
      <section className="module-content">
        {messages.created && <div className="success-banner">✓ Venta registrada y existencias descontadas.</div>}
        {messages.error && <div className="error-banner">{messages.error}</div>}
        <div className="sales-layout">
          <form action={createSale} className="sale-form">
            <h2>Nueva venta</h2>
            <label>Producto *<select name="product_id" required defaultValue=""><option value="">Seleccionar</option>{(products ?? []).map((p) => <option value={p.id} key={p.id}>{p.name}{p.variant ? ` · ${p.variant}` : ""} — {money(p.sale_price_cents)} ({p.stock_quantity})</option>)}</select></label>
            <label>Cantidad *<input type="number" name="quantity" min="1" defaultValue="1" required /></label>
            <label>Gimnasta<select name="gymnast_id" defaultValue=""><option value="">No aplica / comprador externo</option>{(gymnasts ?? []).map((g) => <option value={g.id} key={g.id}>{g.first_name} {g.last_name}</option>)}</select></label>
            <label>Nombre del comprador<input name="customer_name" placeholder="Si no seleccionaste gimnasta" /></label>
            <label>Estado<select name="payment_status" defaultValue="paid"><option value="paid">Pagada</option><option value="pending">Pendiente</option></select></label>
            <label>Medio de pago<select name="payment_method" defaultValue="transfer"><option value="transfer">Transferencia</option><option value="cash">Efectivo</option><option value="card">Tarjeta</option><option value="other">Otro</option></select></label>
            <label>Notas<input name="notes" /></label>
            <button className="primary-button">Registrar venta</button>
          </form>
          <div className="sales-history"><h2>Ventas recientes</h2>{saleRows.length === 0 ? <p className="muted">Aún no hay ventas registradas.</p> : saleRows.map((sale) => { const item = sale.sale_items[0]; const buyer = sale.gymnasts?.[0] ? `${sale.gymnasts[0].first_name} ${sale.gymnasts[0].last_name}` : sale.customer_name || "Cliente"; return <article key={sale.id}><div><strong>{item?.products?.[0]?.name ?? "Artículo"}{item?.products?.[0]?.variant ? ` · ${item.products[0].variant}` : ""}</strong><span>{buyer} · {sale.sold_on}</span></div><div><strong>{money(sale.total_cents)}</strong><span className={`finance-status ${sale.payment_status === "paid" ? "paid" : "pending"}`}>{sale.payment_status === "paid" ? "Pagada" : "Pendiente"}</span></div></article>; })}</div>
        </div>
      </section>
    </main>
  );
}
