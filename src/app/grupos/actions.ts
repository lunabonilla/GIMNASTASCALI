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

export async function enrollGymnast(formData: FormData) {
  const groupId = value(formData, "group_id");
  const gymnastId = value(formData, "gymnast_id");
  if (!groupId || !gymnastId) {
    redirect(`/grupos/${groupId}?error=Selecciona+una+gimnasta`);
  }

  const supabase = await createClient();
  const [{ data: group }, { count }, { data: auth }] = await Promise.all([
    supabase.from("training_groups").select("capacity").eq("id", groupId).single(),
    supabase
      .from("enrollments")
      .select("*", { count: "exact", head: true })
      .eq("group_id", groupId)
      .eq("active", true),
    supabase.auth.getClaims(),
  ]);

  if (!group) redirect("/grupos?error=Grupo+no+encontrado");
  if ((count ?? 0) >= group.capacity) {
    redirect(`/grupos/${groupId}?error=El+grupo+ya+alcanzó+su+cupo+máximo`);
  }

  const { error } = await supabase.from("enrollments").insert({
    gymnast_id: gymnastId,
    group_id: groupId,
    starts_on: new Date().toISOString().slice(0, 10),
    active: true,
    created_by: auth?.claims?.sub ?? null,
  });

  if (error) {
    const message =
      error.code === "23505"
        ? "La gimnasta ya pertenece a un grupo activo"
        : "No pudimos asignar la gimnasta";
    redirect(`/grupos/${groupId}?error=${encodeURIComponent(message)}`);
  }

  revalidatePath("/");
  revalidatePath("/grupos");
  revalidatePath(`/grupos/${groupId}`);
  redirect(`/grupos/${groupId}?assigned=1`);
}

export async function endEnrollment(formData: FormData) {
  const groupId = value(formData, "group_id");
  const enrollmentId = value(formData, "enrollment_id");
  if (!groupId || !enrollmentId) redirect("/grupos");

  const supabase = await createClient();
  const { error } = await supabase
    .from("enrollments")
    .update({
      active: false,
      ends_on: new Date().toISOString().slice(0, 10),
    })
    .eq("id", enrollmentId)
    .eq("group_id", groupId);

  if (error) {
    redirect(`/grupos/${groupId}?error=No+pudimos+retirar+la+gimnasta`);
  }

  revalidatePath("/");
  revalidatePath("/grupos");
  revalidatePath(`/grupos/${groupId}`);
  redirect(`/grupos/${groupId}?removed=1`);
}
