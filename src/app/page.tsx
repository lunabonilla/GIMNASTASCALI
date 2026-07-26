import Image from "next/image";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

type StaffProfile = {
  full_name: string;
  role: "superadmin" | "administration" | "coach";
  active: boolean;
};

const navigation = [
  { label: "Inicio", icon: "⌂", active: true },
  { label: "Clases de prueba", icon: "◇" },
  { label: "Gimnastas", icon: "○" },
  { label: "Grupos y horarios", icon: "▦" },
  { label: "Asistencia", icon: "✓" },
  { label: "Cartera y pagos", icon: "$" },
  { label: "Inventario", icon: "□" },
  { label: "Ventas", icon: "↗" },
];

const metrics = [
  {
    label: "Gimnastas activas",
    value: "—",
    note: "Registra la primera gimnasta",
    tone: "lilac",
    icon: "○",
  },
  {
    label: "Clases de prueba",
    value: "—",
    note: "Sin pruebas para hoy",
    tone: "peach",
    icon: "◇",
  },
  {
    label: "Cartera pendiente",
    value: "$ 0",
    note: "Todo está al día",
    tone: "mint",
    icon: "$",
  },
  {
    label: "Grupos activos",
    value: "—",
    note: "Crea el primer grupo",
    tone: "sky",
    icon: "▦",
  },
];

const modules = [
  {
    title: "Agendar clase de prueba",
    description: "Registra una nueva familia y programa su primera visita.",
    action: "Nueva prueba",
    icon: "◇",
  },
  {
    title: "Crear grupo",
    description: "Organiza niveles, horarios, cupos y profesora asignada.",
    action: "Crear grupo",
    icon: "▦",
  },
  {
    title: "Registrar pago",
    description: "Aplica mensualidades, abonos o compras de artículos.",
    action: "Nuevo pago",
    icon: "$",
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
            <a
              href="#"
              className={`nav-item ${item.active ? "active" : ""}`}
              key={item.label}
            >
              <span className="nav-icon" aria-hidden="true">
                {item.icon}
              </span>
              {item.label}
            </a>
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
            <p className="eyebrow">Domingo, 26 de julio</p>
            <h1>Hola, {profile.full_name.split(" ")[0]}</h1>
          </div>
          <div className="topbar-actions">
            <button className="icon-button" aria-label="Notificaciones">
              ♢
              <span />
            </button>
            <button className="primary-button">
              <span>＋</span> Nueva clase de prueba
            </button>
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
              <button className="welcome-action">Configurar mi club →</button>
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
                <button className="secondary-button">Crear primer grupo</button>
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
                  <button>{module.action} →</button>
                </article>
              ))}
            </div>
          </section>
        </div>
      </section>
    </main>
  );
}
