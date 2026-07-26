"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function createGymnast(formData: FormData) {
  const value = (name: string) => String(formData.get(name) ?? "").trim();
  const firstName = value("first_name");
  const lastName = value("last_name");
  const birthDate = value("birth_date");
  const guardianName = value("guardian_name");
  const guardianPhone = value("guardian_phone");

  if (!firstName || !lastName || !birthDate || !guardianName || !guardianPhone) {
    redirect(
      "/gimnastas/nueva?error=Completa+todos+los+campos+obligatorios",
    );
  }

  const supabase = await createClient();
  const { error } = await supabase.rpc("register_gymnast", {
    p_first_name: firstName,
    p_last_name: lastName,
    p_birth_date: birthDate,
    p_identity_document: value("identity_document"),
    p_level_id: value("level_id") || null,
    p_guardian_name: guardianName,
    p_guardian_phone: guardianPhone,
    p_guardian_relationship: value("guardian_relationship"),
    p_guardian_email: value("guardian_email"),
  });

  if (error) {
    const message =
      error.code === "23505"
        ? "Ya existe una gimnasta con ese documento"
        : "No pudimos guardar la gimnasta";
    redirect(`/gimnastas/nueva?error=${encodeURIComponent(message)}`);
  }

  revalidatePath("/");
  revalidatePath("/gimnastas");
  redirect("/gimnastas?created=1");
}
