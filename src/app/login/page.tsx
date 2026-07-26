import Image from "next/image";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { login } from "./actions";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();

  if (data?.claims) {
    redirect("/");
  }

  const { error } = await searchParams;

  return (
    <main className="login-shell">
      <section className="login-brand-panel">
        <div className="login-brand-copy">
          <Image
            src="/gimnastas-logo.png"
            alt="Gimnastas"
            width={260}
            height={230}
            priority
          />
          <span>Plataforma interna</span>
          <h1>El corazón operativo de Gimnastas Cali.</h1>
          <p>
            Grupos, asistencia, pagos e inventario organizados en un mismo
            lugar.
          </p>
        </div>
        <div className="login-orbit" aria-hidden="true" />
      </section>

      <section className="login-form-panel">
        <div className="login-card">
          <span className="login-kicker">Bienvenida</span>
          <h2>Ingresa a Club</h2>
          <p className="login-intro">
            Usa el correo y la contraseña asignados por la superadministradora.
          </p>

          {error ? (
            <div className="login-error" role="alert">
              {error}
            </div>
          ) : null}

          <form action={login}>
            <label htmlFor="email">Correo electrónico</label>
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              placeholder="nombre@gimnastascali.com"
              required
            />

            <div className="password-label">
              <label htmlFor="password">Contraseña</label>
            </div>
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              placeholder="••••••••"
              minLength={8}
              required
            />

            <button type="submit">Ingresar a Club</button>
          </form>

          <small>
            El acceso es exclusivo para el personal autorizado de Gimnastas
            Cali.
          </small>
        </div>
      </section>
    </main>
  );
}
