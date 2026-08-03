import Image from "next/image";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { formatClubTime } from "@/lib/format";
import { getCurrentStaffProfile } from "@/lib/current-staff";
import styles from "./page.module.css";

type StaffProfile = {
  full_name: string;
  role: "superadmin" | "administration" | "coach";
  active: boolean;
};

const navigation = [
  {
    label: "General",
    items: [{ label: "Inicio", icon: "⌂", active: true, href: "/" }],
  },
  {
    label: "Gestión deportiva",
    items: [
      { label: "Gimnastas", icon: "○", href: "/gimnastas" },
      { label: "Grupos y horarios", icon: "▦", href: "/grupos" },
      { label: "Jornada de profesores", icon: "◷", href: "/horarios-profesores" },
      { label: "Profesores", icon: "◎", href: "/profesores" },
      { label: "Asistencia", icon: "✓", href: "/asistencia" },
      { label: "Clases de prueba", icon: "◇", href: "/pruebas" },
    ],
  },
  {
    label: "Competencias",
    items: [
      { label: "Calendario", icon: "🏆", href: "/competencias" },
      { label: "Preparación", icon: "★", href: "/programas-preparacion" },
    ],
  },
  {
    label: "Finanzas",
    items: [
      { label: "Cartera y pagos", icon: "$", href: "/pagos" },
      { label: "Mensajes de cobro", icon: "✉", href: "/pagos/mensajes" },
    ],
  },
  {
    label: "Tienda",
    items: [
      { label: "Inventario", icon: "□", href: "/inventario" },
      { label: "Ventas", icon: "↗", href: "/ventas" },
    ],
  },
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
    title: "Tomar asistencia",
    description: "Abre un grupo y registra la asistencia o las recuperaciones.",
    action: "Ver grupos",
    icon: "✓",
    href: "/asistencia",
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

  const profile = await getCurrentStaffProfile() as StaffProfile | null;

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
  const today = todayStart.toISOString().slice(0, 10);
  const weekday = todayStart.getDay() || 7;

  const [
    { count: activeGymnasts },
    { count: pausedGymnasts },
    { count: todayTrials },
    { count: activeGroups },
    { data: billingCharges },
    { data: todaySchedule },
    { data: products },
    { count: pendingTrials },
    { data: upcomingCompetitions },
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
      .select("amount_cents, due_on, payment_allocations(amount_cents)")
      .is("voided_at", null),
    supabase
      .from("group_schedule_slots")
      .select("id, starts_at, ends_at, location, training_groups(id, name, active, staff_profiles(full_name), enrollments(id))")
      .eq("weekday", weekday)
      .order("starts_at"),
    supabase
      .from("products")
      .select("id, stock_quantity, minimum_stock")
      .eq("active", true),
    supabase
      .from("trial_bookings")
      .select("*", { count: "exact", head: true })
      .eq("status", "scheduled")
      .gte("scheduled_for", todayStart.toISOString()),
    supabase
      .from("competitions")
      .select("id, name, starts_on, city, country, status")
      .neq("status", "cancelled")
      .gte("starts_on", today)
      .order("starts_on")
      .limit(3),
  ]);

  const outstandingCharges = (billingCharges ?? []).map((charge) => {
    const paid = (charge.payment_allocations ?? []).reduce(
      (subtotal: number, allocation: { amount_cents: number }) =>
        subtotal + Number(allocation.amount_cents),
      0,
    );
    return {
      balance: Number(charge.amount_cents) - paid,
      dueOn: charge.due_on,
    };
  });

  const pendingBalance = outstandingCharges.reduce(
    (total, charge) => total + Math.max(0, charge.balance),
    0,
  );
  const overdueCharges = outstandingCharges.filter(
    (charge) => charge.balance > 0 && charge.dueOn < today,
  ).length;
  const lowStock = (products ?? []).filter(
    (product) => product.stock_quantity <= product.minimum_stock,
  ).length;
  const schedule = (todaySchedule ?? []).filter((slot) => {
    const relation = slot.training_groups;
    const group = Array.isArray(relation) ? relation[0] : relation;
    return group?.active;
  });
  const alertCount = overdueCharges + lowStock + (pendingTrials ?? 0);

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
          {navigation.map((section) => (
            <div className="nav-section" key={section.label}>
              <span className="nav-section-label">{section.label}</span>
              {section.items.map((item) => (
                <Link
                  href={item.href}
                  className={`nav-item ${"active" in item && item.active ? "active" : ""}`}
                  key={item.label}
                >
                  <span className="nav-icon" aria-hidden="true">
                    {item.icon}
                  </span>
                  {item.label}
                </Link>
              ))}
            </div>
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
              <span className="pill">Resumen de hoy</span>
              <h2>El club organizado, en un solo lugar.</h2>
              <p>
                Consulta las gimnastas, entrenamientos, competencias, cartera y
                tienda desde un mismo espacio.
              </p>
              <Link href="/gimnastas" className="welcome-action">
                Ver directorio de gimnastas →
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
                <Link href="/grupos" className="text-button">Ver horarios →</Link>
              </div>
              {schedule.length ? (
                <div className={styles.todaySchedule}>
                  {schedule.map((slot) => {
                    const relation = slot.training_groups;
                    const group = Array.isArray(relation) ? relation[0] : relation;
                    const coachRelation = group?.staff_profiles;
                    const coach = Array.isArray(coachRelation)
                      ? coachRelation[0]
                      : coachRelation;
                    return (
                      <Link href={`/asistencia/${group?.id}`} className={styles.scheduleRow} key={slot.id}>
                        <span className={styles.scheduleTime}>{formatClubTime(slot.starts_at)}</span>
                        <span>
                          <strong>{group?.name}</strong>
                          <small>
                            {coach?.full_name ?? "Profesora por asignar"}
                            {slot.location ? ` · ${slot.location}` : ""}
                          </small>
                        </span>
                        <span className={styles.scheduleCount}>
                          {group?.enrollments?.length ?? 0} gimnastas
                        </span>
                      </Link>
                    );
                  })}
                </div>
              ) : (
                <div className="empty-state">
                  <div className="empty-illustration">
                    <span>15:00</span><span>20:30</span><i />
                  </div>
                  <h3>No hay clases programadas para hoy</h3>
                  <p>Consulta los demás días o crea un nuevo horario.</p>
                  <Link href="/grupos" className="secondary-button">Ver horarios</Link>
                </div>
              )}
            </section>

            <section className="panel alerts-panel">
              <div className="panel-heading">
                <div>
                  <span className="section-kicker">Atención</span>
                  <h2>Alertas del club</h2>
                </div>
                <span className="counter">{alertCount}</span>
              </div>
              {alertCount === 0 && (
                <div className="alert-empty">
                  <span>✓</span>
                  <div><h3>Todo bajo control</h3><p>No tienes alertas pendientes por ahora.</p></div>
                </div>
              )}
              <div className={styles.alertList}>
                <Link href="/pagos">
                  <span className="dot purple" />
                  <p>Cobros vencidos</p>
                  <strong>{overdueCharges}</strong>
                </Link>
                <Link href="/inventario">
                  <span className="dot orange" />
                  <p>Inventario bajo</p>
                  <strong>{lowStock}</strong>
                </Link>
                <Link href="/pruebas">
                  <span className="dot blue" />
                  <p>Pruebas programadas</p>
                  <strong>{pendingTrials ?? 0}</strong>
                </Link>
              </div>
            </section>
          </div>

          <section className={styles.upcomingSection}>
            <div className="section-heading">
              <div>
                <span className="section-kicker">Calendario deportivo</span>
                <h2>Próximas competencias</h2>
              </div>
              <Link href="/competencias" className="text-button">Ver calendario completo →</Link>
            </div>
            <div className={styles.competitionStrip}>
              {(upcomingCompetitions ?? []).map((competition) => (
                <Link href="/competencias" className={styles.competitionSummary} key={competition.id}>
                  <span className={`${styles.competitionStatus} ${competition.status === "confirmed" ? styles.confirmed : ""}`}>
                    {competition.status === "confirmed" ? "Confirmada" : "En definición"}
                  </span>
                  <strong>{competition.name}</strong>
                  <small>
                    {new Intl.DateTimeFormat("es-CO", { day: "numeric", month: "long" }).format(
                      new Date(`${competition.starts_on}T12:00:00`),
                    )}
                    {" · "}
                    {[competition.city, competition.country].filter(Boolean).join(", ") || "Lugar por definir"}
                  </small>
                </Link>
              ))}
              {!upcomingCompetitions?.length && (
                <p className={styles.noCompetitions}>No hay competencias próximas con fecha confirmada.</p>
              )}
            </div>
          </section>

          <section className="quick-section">
            <div className="section-heading">
              <div>
                <span className="section-kicker">Accesos rápidos</span>
                <h2>Acciones frecuentes</h2>
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
