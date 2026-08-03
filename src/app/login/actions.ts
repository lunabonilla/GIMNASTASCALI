"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function login(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    redirect("/login?error=Completa+tu+correo+y+contraseña");
  }

  const supabase = await createClient();
  const { data: signIn, error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    redirect("/login?error=Correo+o+contraseña+incorrectos");
  }

  const { data: profile } = await supabase
    .from("staff_profiles")
    .select("active")
    .eq("id", signIn.user.id)
    .maybeSingle();

  if (!profile?.active) {
    await supabase.auth.signOut();
    redirect("/login?error=Tu+usuario+no+tiene+acceso+activo");
  }

  redirect("/");
}
