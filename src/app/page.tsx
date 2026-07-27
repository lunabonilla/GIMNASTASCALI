import Image from "next/image";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

type StaffProfile = {
  full_name: string;
  role: "superadmin" | "administration" | "coach";
  active: boolean;
};

const navigation = [
  { label: "Inicio", icon: "⌂", active: true, href: "/" },
  { label: "Clases de prueba", icon: "◇", href: "/pruebas" },
  { label: "Gimnastas", icon: "○", href: "/gimnastas" },
  { label: "Grupos y horarios", icon: "▦", href: "/grupos" },
  { label: "Asistencia", icon: "✓", href: "/asistencia" },
  { label: "Cartera y pagos", icon: "$", href: "/pagos" },
  { label: "Inventario", icon: "□", href: "/inventario" },
  { label: "Ventas", icon: "↗", href: "/ventas" },
];

const modules = [
  {
    title: "Agendar clase de prueba",
    description: "Registra una nueva familia y programa su primera visita.",
    action: "Nueva prueba",
    icon: "◇",
    href: "/pruebas/nueva",
  },
  {
    title: "Crear grupo",
    description: "Organiza niveles, horarios, cupos y profesora asignada.",
    action: "Crear grupo",
    icon: "▦",
    href: "/grupos/nuevo",
  },
  {
    title: "Registrar pago",
    description: "Aplica mensualidades, abonos o compras de artículos.",
    action: "Nuevo pago",
    icon: "$",
    href: "/pagos/nuevo",
  },
];

export default async function Home() {
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getClaims();

  if (error || !data?.claims) {
    redirect("/login");
  }

  const { data: profileData } = await supabase
    .from("staff_profiles")
    .select("full_name, role, active")
    .single();
  const profile = profileData as StaffProfile | null;

  if (!profile?.active) {
    redirect("/login?error=Tu+usuario+no+tiene+acceso+activo");
  }

  async function signOut() {
    "use server";

    const serverSupabase = await createClient();
    await serverSupabase.auth.signOut();
    redirect("/login");
  }

  const displayRole =
    profile.role === "superadmin"
      ? "Superadministradora"
      : profile.role === "administration"
        ? "Administración"
        : "Profesora";

  const initials = profile.full_name
    .split(" ")
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase();

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const tomorrowStart = new Date(todayStart);
  tomorrowStart.setDate(tomorrowStart.getDate() + 1);

  const [
    { count: activeGymnasts },
    { count: pausedGymnasts },
    { count: todayTrials },
    { count: activeGroups },
    { data: billingCharges },
  ] = await Promise.all([
    supabase
      .from("gymnasts")
      .select("*", { count: "exact", head: true })
      .eq("status", "active"),
    supabase
      .from("gymnasts")
      .select("*", { count: "exact", head: true })
      .eq("status", "suspended"),
    supabase
      .from("trial_bookings")
      .select("*", { count: "exact", head: true })
      .gte("scheduled_for", todayStart.toISOString())
      .lt("scheduled_for", tomorrowStart.toISOString()),
    supabase
      .from("training_groups")
      .select("*", { count: "exact", head: true })
      .eq("active", true),
    supabase
      .from("billing_charges")
      .select("amount_cents, payment_allocations(amount_cents)")
      .is("voided_at", null),
  ]);

  const pendingBalance = (billingCharges ?? []).reduce((total, charge) => {
    const paid = (charge.payment_allocations ?? []).reduce(
      (subtotal: number, allocation: { amount_cents: number }) =>
        subtotal + Number(allocation.amount_cents),
      0,
    );
    return total + Number(charge.amount_cents) - paid;
  }, 0);

  const metrics = [
    {
      label: "Gimnastas activas",
      value: String(activeGymnasts ?? 0),
      note: `${pausedGymnasts ?? 0} pausadas actualmente`,
      tone: "lilac",
      icon: "○",
    },
    {
      label: "Clases de prueba",
      value: String(todayTrials ?? 0),
      note: "Programadas para hoy",
      tone: "peach",
      icon: "◇",
    },
    {
      label: "Cartera pendiente",
      value: new Intl.NumberFormat("es-CO", {
        style: "currency",
        currency: "COP",
        maximumFractionDigits: 0,
      }).format(pendingBalance / 100),
      note: "Saldo total por recaudar",
      tone: "mint",
      icon: "$",
    },
    {
      label: "Grupos activos",
      value: String(activeGroups ?? 0),
      note: activeGroups ? "Con horarios configurados" : "Crea el primer grupo",
      tone: "sky",
      icon: "▦",
    },
  ];

  const currentDate = new Intl.DateTimeFormat("es-CO", {
    weekday: "long",
    day: "numeric",
    month: "long",
  }).format(new Date());

  return (
    <main className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <Image
            src="/gimnastas-logo.png"
            alt="Gimnastas"
            width={190}
            height={170}
            priority
          />
          <span>Gestión del club</span>
        </div>

        <nav aria-label="Navegación principal">
          {navigation.map((item) => (
            <Link
              href={item.href ?? "#"}
              className={`nav-item ${item.active ? "active" : ""}`}
              key={item.label}
            >
              <span className="nav-icon" aria-hidden="true">
                {item.icon}
              </span>
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="avatar">{initials}</div>
          <div>
            <strong>{profile.full_name}</strong>
            <span>{displayRole}</span>
          </div>
          <form action={signOut}>
            <button aria-label="Cerrar sesión" title="Cerrar sesión">
              ↪
            </button>
          </form>
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="eyebrow">{currentDate}</p>
            <h1>Hola, {profile.full_name.split(" ")[0]}</h1>
          </div>
          <div className="topbar-actions">
            <button className="icon-button" aria-label="Notificaciones">
              ♢
              <span />
            </button>
            <Link href="/pruebas/nueva" className="primary-button">
              <span>＋</span> Nueva clase de prueba
            </Link>
          </div>
        </header>

        <div className="content">
          <section className="welcome-card">
            <div>
              <span className="pill">Tu plataforma está lista</span>
              <h2>Todo el club, en un solo lugar.</h2>
              <p>
                Empieza configurando los grupos y horarios de Gimnastas Cali.
                Desde aquí podrás acompañar cada clase, pago y proceso.
              </p>
              <Link href="/grupos/nuevo" className="welcome-action">
                Configurar mi club →
              </Link>
            </div>
            <div className="welcome-mark" aria-hidden="true">
              <Image
                src="/gimnastas-logo.png"
                alt=""
                width={260}
                height={230}
              />
            </div>
          </section>

          <section className="metrics-grid" aria-label="Resumen del club">
            {metrics.map((metric) => (
              <article className="metric-card" key={metric.label}>
                <div className={`metric-icon ${metric.tone}`}>{metric.icon}</div>
                <div className="metric-copy">
                  <span>{metric.label}</span>
                  <strong>{metric.value}</strong>
                  <small>{metric.note}</small>
                </div>
              </article>
            ))}
          </section>

          <div className="dashboard-grid">
            <section className="panel schedule-panel">
              <div className="panel-heading">
                <div>
                  <span className="section-kicker">Agenda</span>
                  <h2>Hoy en el gimnasio</h2>
                </div>
                <button className="text-button">Ver calendario →</button>
              </div>
              <div className="empty-state">
                <div className="empty-illustration">
                  <span>15:00</span>
                  <span>20:30</span>
                  <i />
                </div>
                <h3>Aún no hay clases programadas</h3>
                <p>
                  Cuando configures tus grupos, el horario de cada día aparecerá
                  aquí.
                </p>
                <Link href="/grupos/nuevo" className="secondary-button">
                  Crear primer grupo
                </Link>
              </div>
            </section>

            <section className="panel alerts-panel">
              <div className="panel-heading">
                <div>
                  <span className="section-kicker">Atención</span>
                  <h2>Alertas del club</h2>
                </div>
                <span className="counter">0</span>
              </div>
              <div className="alert-empty">
                <span>✓</span>
                <div>
                  <h3>Todo bajo control</h3>
                  <p>No tienes alertas pendientes por ahora.</p>
                </div>
              </div>
              <div className="alert-list">
                <div>
                  <span className="dot purple" />
                  <p>Pagos próximos a vencer</p>
                  <strong>0</strong>
                </div>
                <div>
                  <span className="dot orange" />
                  <p>Inventario bajo</p>
                  <strong>0</strong>
                </div>
                <div>
                  <span className="dot blue" />
                  <p>Pruebas por confirmar</p>
                  <strong>0</strong>
                </div>
              </div>
            </section>
          </div>

          <section className="quick-section">
            <div className="section-heading">
              <div>
                <span className="section-kicker">Primeros pasos</span>
                <h2>¿Qué quieres hacer?</h2>
              </div>
            </div>
            <div className="quick-grid">
              {modules.map((module) => (
                <article className="quick-card" key={module.title}>
                  <span className="quick-icon">{module.icon}</span>
                  <div>
                    <h3>{module.title}</h3>
                    <p>{module.description}</p>
                  </div>
                  <Link href={module.href}>{module.action} →</Link>
                </article>
              ))}
            </div>
          </section>
        </div>
      </section>
    </main>
  );
}
