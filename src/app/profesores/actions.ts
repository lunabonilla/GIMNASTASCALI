"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentStaffProfile } from "@/lib/current-staff";

const field = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

async function requireAdministrator() {
  const profile = await getCurrentStaffProfile();
  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect("/profesores?error=No+tienes+permiso+para+administrar+el+equipo");
  }
  return profile;
}

export async function createCoach(formData: FormData) {
  const fullName = field(formData, "full_name");
  const phone = field(formData, "phone");
  if (!fullName) redirect("/profesores?error=Escribe+el+nombre+del+profesor");

  await requireAdministrator();
  const supabase = await createClient();
  const { data: existing } = await supabase
    .from("staff_profiles")
    .select("id")
    .ilike("full_name", fullName)
    .maybeSingle();
  if (existing) redirect("/profesores?error=Ese+profesor+ya+está+registrado");

  const { error } = await supabase.from("staff_profiles").insert({
    full_name: fullName,
    phone: phone || null,
    role: "coach",
    active: true,
  });
  if (error) redirect("/profesores?error=No+pudimos+crear+el+profesor");

  revalidatePath("/profesores");
  revalidatePath("/grupos/nuevo");
  revalidatePath("/horarios-profesores");
  redirect("/profesores?created=1");
}

export async function updateCoach(formData: FormData) {
  const id = field(formData, "id");
  const fullName = field(formData, "full_name");
  const phone = field(formData, "phone");
  if (!id || !fullName) redirect("/profesores?error=Completa+el+nombre");

  const current = await requireAdministrator();
  const active = id === current.id ? true : formData.get("active") === "on";
  const supabase = await createClient();
  const { error } = await supabase
    .from("staff_profiles")
    .update({ full_name: fullName, phone: phone || null, active })
    .eq("id", id);
  if (error) redirect("/profesores?error=No+pudimos+guardar+los+cambios");

  revalidatePath("/");
  revalidatePath("/profesores");
  revalidatePath("/grupos");
  revalidatePath("/horarios-profesores");
  redirect("/profesores?updated=1");
}
