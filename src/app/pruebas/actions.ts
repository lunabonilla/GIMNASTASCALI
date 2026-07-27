"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function createTrial(formData: FormData) {
  const firstName = value(formData, "first_name");
  const lastName = value(formData, "last_name");
  const birthDate = value(formData, "birth_date");
  const guardianName = value(formData, "guardian_name");
  const guardianPhone = value(formData, "guardian_phone");
  const date = value(formData, "date");
  const time = value(formData, "time");

  if (!firstName || !lastName || !birthDate || !guardianName || !guardianPhone || !date || !time) {
    redirect("/pruebas/nueva?error=Completa+los+campos+obligatorios");
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const scheduledFor = new Date(`${date}T${time}:00-05:00`).toISOString();
  const { error } = await supabase.from("trial_bookings").insert({
    prospect_first_name: firstName,
    prospect_last_name: lastName,
    birth_date: birthDate,
    guardian_name: guardianName,
    guardian_phone: guardianPhone,
    guardian_email: value(formData, "guardian_email") || null,
    experience_notes: value(formData, "experience_notes") || null,
    scheduled_for: scheduledFor,
    status: "scheduled",
    created_by: auth.claims.sub,
  });
  if (error) redirect("/pruebas/nueva?error=No+pudimos+agendar+la+clase");

  revalidatePath("/");
  revalidatePath("/pruebas");
  redirect("/pruebas?created=1");
}

export async function updateTrialStatus(formData: FormData) {
  const trialId = value(formData, "trial_id");
  const status = value(formData, "status");
  if (!trialId || !["scheduled", "attended", "no_show", "cancelled"].includes(status)) {
    redirect("/pruebas");
  }

  const supabase = await createClient();
  const { error } = await supabase
    .from("trial_bookings")
    .update({
      status,
      attended: status === "attended" ? true : status === "no_show" ? false : null,
    })
    .eq("id", trialId);
  if (error) redirect("/pruebas?error=No+pudimos+actualizar+el+estado");

  revalidatePath("/");
  revalidatePath("/pruebas");
  redirect("/pruebas?updated=1");
}
