"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function createGroup(formData: FormData) {
  const name = value(formData, "name");
  const capacity = Number(value(formData, "capacity"));
  const monthlyFee = Number(value(formData, "monthly_fee"));
  const weekday = Number(value(formData, "weekday"));
  const startsAt = value(formData, "starts_at");
  const endsAt = value(formData, "ends_at");

  if (!name || !Number.isInteger(capacity) || capacity < 1 || !startsAt || !endsAt || !weekday) {
    redirect("/grupos/nuevo?error=Completa+los+campos+obligatorios");
  }
  if (endsAt <= startsAt) {
    redirect("/grupos/nuevo?error=La+hora+de+finalización+debe+ser+posterior");
  }

  const supabase = await createClient();
  const { data: profile } = await supabase
    .from("staff_profiles")
    .select("role, active")
    .single();
  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect("/grupos/nuevo?error=No+tienes+permiso+para+crear+grupos");
  }

  const { data: group, error: groupError } = await supabase
    .from("training_groups")
    .insert({
      name,
      group_type: value(formData, "group_type") || "regular",
      level_id: value(formData, "level_id") || null,
      coach_profile_id: value(formData, "coach_profile_id") || null,
      minimum_age: value(formData, "minimum_age") ? Number(value(formData, "minimum_age")) : null,
      maximum_age: value(formData, "maximum_age") ? Number(value(formData, "maximum_age")) : null,
      capacity,
      monthly_fee_cents: Number.isFinite(monthlyFee) ? Math.round(monthlyFee * 100) : 0,
    })
    .select("id")
    .single();

  if (groupError || !group) {
    redirect("/grupos/nuevo?error=No+pudimos+crear+el+grupo");
  }

  const { error: scheduleError } = await supabase.from("group_schedule_slots").insert({
    group_id: group.id,
    weekday,
    starts_at: startsAt,
    ends_at: endsAt,
    location: value(formData, "location") || null,
  });
  if (scheduleError) {
    await supabase.from("training_groups").delete().eq("id", group.id);
    redirect("/grupos/nuevo?error=No+pudimos+guardar+el+horario");
  }

  revalidatePath("/");
  revalidatePath("/grupos");
  redirect("/grupos?created=1");
}
