import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createCharge } from "../actions";

export default async function NewChargePage({
  searchParams,
}: {
  searchParams: Promise<{ gymnast?: string; error?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const messages = await searchParams;

  const { data } = await supabase
    .from("gymnasts")
    .select("id, first_name, last_name, status")
    .neq("status", "retired")
    .order("first_name")
    .order("last_name");
  const gymnasts = (data ?? []) as Array<{
    id: string; first_name: string; last_name: string; status: string;
  }>;
  const today = new Date().toISOString().slice(0, 10);

  return (
    <main className="form-page">
      <div className="form-card wide-form">
        <Link href="/pagos" className="back-link">← Volver a cartera</Link>
        <p className="eyebrow">Nuevo movimiento</p>
        <h1>Crear un cargo</h1>
        <p>Registra una mensualidad, producto, clase adicional u otro cobro.</p>
        {messages.error && <div className="error-banner">{messages.error}</div>}

        <form action={createCharge} className="club-form">
          <label className="full-field">
            Deportista *
            <select name="gymnast_id" required defaultValue={messages.gymnast ?? ""}>
              <option value="">Seleccionar deportista</option>
              {gymnasts.map((gymnast) => (
                <option value={gymnast.id} key={gymnast.id}>
                  {gymnast.first_name} {gymnast.last_name}{gymnast.status === "suspended" ? " · Pausada" : ""}
                </option>
              ))}
            </select>
          </label>
          <label>
            Tipo de cargo *
            <select name="category" defaultValue="monthly_fee" required>
              <option value="monthly_fee">Mensualidad</option>
              <option value="extra_class">Clase extra</option>
              <option value="private_class">Clase personalizada</option>
              <option value="product">Artículo o uniforme</option>
              <option value="competition">Competencia</option>
              <option value="other">Otro</option>
            </select>
          </label>
          <label>
            Concepto *
            <input name="concept" placeholder="Ej. Mensualidad agosto" required />
          </label>
          <label>
            Valor en pesos *
            <input name="amount" inputMode="numeric" placeholder="Ej. 660000" required />
          </label>
          <label>
            Fecha de creación *
            <input type="date" name="issued_on" defaultValue={today} required />
          </label>
          <label>
            Fecha límite de pago *
            <input type="date" name="due_on" defaultValue={today} required />
          </label>
          <label>
            Inicio del ciclo
            <input type="date" name="period_starts_on" />
          </label>
          <label>
            Fin del ciclo
            <input type="date" name="period_ends_on" />
          </label>
          <label className="full-field">
            Observaciones
            <textarea name="description" placeholder="Información adicional del cobro" rows={3} />
          </label>
          <div className="form-actions full-field">
            <Link href="/pagos">Cancelar</Link>
            <button type="submit" className="primary-button">Guardar cargo</button>
          </div>
        </form>
      </div>
    </main>
  );
}
