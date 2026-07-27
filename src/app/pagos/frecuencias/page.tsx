import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { saveBillingFrequency } from "./actions";

type RawRecord = Record<string, string | null>;

const months: Record<string, number> = {
  enero: 1, febrero: 2, marzo: 3, abril: 4, mayo: 5, junio: 6,
  julio: 7, agosto: 8, septiembre: 9, octubre: 10, noviembre: 11, diciembre: 12,
};

const parseSpanishDate = (raw: string | null | undefined) => {
  const match = String(raw ?? "").toLocaleLowerCase("es").match(
    /(\d{1,2}) de ([a-záéíóúñ]+) de (\d{4})/,
  );
  if (!match || !months[match[2]]) return "";
  return `${match[3]}-${String(months[match[2]]).padStart(2, "0")}-${match[1].padStart(2, "0")}`;
};

const normalize = (name: string) =>
  name.normalize("NFD").replace(/\p{Diacritic}/gu, "").trim().toLocaleLowerCase("es");

export default async function FrequenciesPage({
  searchParams,
}: {
  searchParams: Promise<{ saved?: string; error?: string; view?: string }>;
}) {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims) redirect("/login");
  const params = await searchParams;

  const [{ data: gymnasts }, { data: profiles }, { data: archive }] = await Promise.all([
    supabase.from("gymnasts").select("id, first_name, last_name, status").neq("status", "retired").order("first_name"),
    supabase.from("gymnast_billing_profiles").select("gymnast_id, program, days_per_week"),
    supabase.from("notion_financial_archive").select("person_name, raw_data").eq("record_type", "cycle"),
  ]);
  const profileMap = new Map((profiles ?? []).map((profile) => [profile.gymnast_id, profile]));
  const cycleMap = new Map(
    (archive ?? []).map((row) => [normalize(row.person_name ?? ""), row.raw_data as RawRecord]),
  );
  const rows = (gymnasts ?? []).map((gymnast) => {
    const profile = profileMap.get(gymnast.id);
    const cycle = cycleMap.get(normalize(`${gymnast.first_name} ${gymnast.last_name}`));
    const program = profile?.program ?? cycle?.Programa ?? null;
    return { gymnast, profile, cycle, program };
  }).filter((row) => ["Minis", "Regular"].includes(row.program ?? ""));
  const visibleRows = params.view === "all"
    ? rows
    : rows.filter((row) => !row.profile?.days_per_week);

  return (
    <main className="module-page">
      <header className="module-header">
        <div><Link href="/pagos" className="back-link">← Volver a cartera</Link><p className="eyebrow">Configuración de ciclos</p><h1>Frecuencia de entrenamiento</h1><p>Define 1 o 2 días para calcular correctamente Minis y Regular.</p></div>
      </header>
      <section className="module-content">
        {params.saved && <div className="success-banner">✓ Frecuencia y ciclo actualizados.</div>}
        {params.error && <div className="error-banner">{params.error}</div>}
        <div className="frequency-summary">
          <strong>{rows.filter((row) => !row.profile?.days_per_week).length}</strong>
          <span>gimnastas pendientes por configurar</span>
          <Link href={params.view === "all" ? "/pagos/frecuencias" : "/pagos/frecuencias?view=all"}>
            {params.view === "all" ? "Ver solo pendientes" : "Ver todas"}
          </Link>
        </div>
        <div className="frequency-list">
          {visibleRows.map(({ gymnast, profile, cycle, program }) => {
            const start = parseSpanishDate(cycle?.["Inicio ciclo"]);
            const end = parseSpanishDate(cycle?.["Fecha fin del ciclo"] ?? cycle?.["Próximo ciclo"]);
            const status = cycle?.["Estado del ciclo"] ?? "Sin estado";
            return (
              <form action={saveBillingFrequency} key={gymnast.id}>
                <input type="hidden" name="gymnast_id" value={gymnast.id} />
                <input type="hidden" name="program" value={program ?? ""} />
                <input type="hidden" name="cycle_start" value={start} />
                <input type="hidden" name="cycle_end" value={end} />
                <input type="hidden" name="original_status" value={status} />
                <div><strong>{gymnast.first_name} {gymnast.last_name}</strong><span>{program} · {status}</span></div>
                <select name="days_per_week" defaultValue={profile?.days_per_week ?? ""} required>
                  <option value="">Seleccionar frecuencia</option>
                  <option value="1">1 día por semana</option>
                  <option value="2">2 días por semana</option>
                </select>
                <button>Guardar y calcular</button>
              </form>
            );
          })}
          {visibleRows.length === 0 && <div className="table-empty"><h3>Todo está configurado</h3><p>No quedan frecuencias pendientes.</p></div>}
        </div>
      </section>
    </main>
  );
}
