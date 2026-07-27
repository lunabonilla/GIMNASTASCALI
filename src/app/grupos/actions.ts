"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function createGroup(formData: FormData) {
  const name = value(formData, "name");
  const capacity = Number(value(formData, "capacity"));
  const billingProgram = value(formData, "billing_program");
  const weekdays = formData
    .getAll("weekdays")
    .map(Number)
    .filter((day) => Number.isInteger(day) && day >= 1 && day <= 7);
  const startsAt = value(formData, "starts_at");
  const endsAt = value(formData, "ends_at");

  if (
    !name ||
    !Number.isInteger(capacity) ||
    capacity < 1 ||
    !startsAt ||
    !endsAt ||
    weekdays.length === 0 ||
    !["Minis", "Regular", "Intensivo"].includes(billingProgram)
  ) {
    redirect("/grupos/nuevo?error=Completa+los+campos+obligatorios");
  }
  if (billingProgram !== "Intensivo" && weekdays.length > 2) {
    redirect("/grupos/nuevo?error=Minis+y+Regular+admiten+máximo+2+días+semanales");
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

  let rateQuery = supabase
    .from("billing_rate_plans")
    .select("amount_cents")
    .eq("program", billingProgram)
    .eq("effective_year", 2026)
    .eq("active", true);
  rateQuery = billingProgram === "Intensivo"
    ? rateQuery.is("days_per_week", null)
    : rateQuery.eq("days_per_week", weekdays.length);
  const { data: rate } = await rateQuery.single();
  if (!rate) {
    redirect("/grupos/nuevo?error=No+encontramos+la+tarifa+para+este+programa+y+frecuencia");
  }

  const { data: group, error: groupError } = await supabase
    .from("training_groups")
    .insert({
      name,
      group_type: billingProgram === "Intensivo" ? "integral" : "regular",
      billing_program: billingProgram,
      level_id: value(formData, "level_id") || null,
      coach_profile_id: value(formData, "coach_profile_id") || null,
      minimum_age: value(formData, "minimum_age") ? Number(value(formData, "minimum_age")) : null,
      maximum_age: value(formData, "maximum_age") ? Number(value(formData, "maximum_age")) : null,
      capacity,
      monthly_fee_cents: rate.amount_cents,
    })
    .select("id")
    .single();

  if (groupError || !group) {
    redirect("/grupos/nuevo?error=No+pudimos+crear+el+grupo");
  }

  const { error: scheduleError } = await supabase
    .from("group_schedule_slots")
    .insert(weekdays.map((weekday) => ({
      group_id: group.id,
      weekday,
      starts_at: startsAt,
      ends_at: endsAt,
      location: value(formData, "location") || null,
    })));
  if (scheduleError) {
    await supabase.from("training_groups").delete().eq("id", group.id);
    redirect("/grupos/nuevo?error=No+pudimos+guardar+el+horario");
  }

  revalidatePath("/");
  revalidatePath("/grupos");
  redirect("/grupos?created=1");
}

export async function updateGroup(formData: FormData) {
  const groupId = value(formData, "group_id");
  const name = value(formData, "name");
  const capacity = Number(value(formData, "capacity"));
  const billingProgram = value(formData, "billing_program");
  const weekdays = formData
    .getAll("weekdays")
    .map(Number)
    .filter((day) => Number.isInteger(day) && day >= 1 && day <= 7);
  const startsAt = value(formData, "starts_at");
  const endsAt = value(formData, "ends_at");

  const editUrl = `/grupos/${groupId}/editar`;
  if (
    !groupId ||
    !name ||
    !Number.isInteger(capacity) ||
    capacity < 1 ||
    !startsAt ||
    !endsAt ||
    weekdays.length === 0 ||
    !["Minis", "Regular", "Intensivo"].includes(billingProgram)
  ) {
    redirect(`${editUrl}?error=Completa+los+campos+obligatorios`);
  }
  if (billingProgram !== "Intensivo" && weekdays.length > 2) {
    redirect(`${editUrl}?error=Minis+y+Regular+admiten+máximo+2+días+semanales`);
  }
  if (endsAt <= startsAt) {
    redirect(`${editUrl}?error=La+hora+de+finalización+debe+ser+posterior`);
  }

  const supabase = await createClient();
  const [{ data: profile }, { count: occupied }] = await Promise.all([
    supabase.from("staff_profiles").select("role, active").single(),
    supabase
      .from("enrollments")
      .select("*", { count: "exact", head: true })
      .eq("group_id", groupId)
      .eq("active", true),
  ]);
  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect(`${editUrl}?error=No+tienes+permiso+para+editar+grupos`);
  }
  if (capacity < (occupied ?? 0)) {
    redirect(`${editUrl}?error=El+cupo+no+puede+ser+menor+a+las+gimnastas+actuales`);
  }

  let rateQuery = supabase
    .from("billing_rate_plans")
    .select("amount_cents")
    .eq("program", billingProgram)
    .eq("effective_year", 2026)
    .eq("active", true);
  rateQuery = billingProgram === "Intensivo"
    ? rateQuery.is("days_per_week", null)
    : rateQuery.eq("days_per_week", weekdays.length);
  const { data: rate } = await rateQuery.single();
  if (!rate) {
    redirect(`${editUrl}?error=No+encontramos+la+tarifa+para+este+programa+y+frecuencia`);
  }

  const { error: groupError } = await supabase
    .from("training_groups")
    .update({
      name,
      group_type: billingProgram === "Intensivo" ? "integral" : "regular",
      billing_program: billingProgram,
      level_id: value(formData, "level_id") || null,
      coach_profile_id: value(formData, "coach_profile_id") || null,
      minimum_age: value(formData, "minimum_age") ? Number(value(formData, "minimum_age")) : null,
      maximum_age: value(formData, "maximum_age") ? Number(value(formData, "maximum_age")) : null,
      capacity,
      monthly_fee_cents: rate.amount_cents,
      active: formData.get("active") === "on",
    })
    .eq("id", groupId);
  if (groupError) redirect(`${editUrl}?error=No+pudimos+actualizar+el+grupo`);

  const { error: deleteScheduleError } = await supabase
    .from("group_schedule_slots")
    .delete()
    .eq("group_id", groupId);
  if (deleteScheduleError) {
    redirect(`${editUrl}?error=No+pudimos+actualizar+el+horario`);
  }

  const { error: scheduleError } = await supabase
    .from("group_schedule_slots")
    .insert(weekdays.map((weekday) => ({
      group_id: groupId,
      weekday,
      starts_at: startsAt,
      ends_at: endsAt,
      location: value(formData, "location") || null,
    })));
  if (scheduleError) redirect(`${editUrl}?error=No+pudimos+guardar+el+nuevo+horario`);

  revalidatePath("/");
  revalidatePath("/grupos");
  revalidatePath(`/grupos/${groupId}`);
  redirect(`/grupos/${groupId}?updated=1`);
}

export async function deleteGroup(formData: FormData) {
  const groupId = value(formData, "group_id");
  if (!groupId) redirect("/grupos");

  const supabase = await createClient();
  const [{ data: profile }, { count: enrollments }, { count: sessions }] =
    await Promise.all([
      supabase.from("staff_profiles").select("role, active").single(),
      supabase
        .from("enrollments")
        .select("*", { count: "exact", head: true })
        .eq("group_id", groupId),
      supabase
        .from("class_sessions")
        .select("*", { count: "exact", head: true })
        .eq("group_id", groupId),
    ]);
  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect(`/grupos/${groupId}?error=No+tienes+permiso+para+eliminar+grupos`);
  }

  if ((enrollments ?? 0) > 0 || (sessions ?? 0) > 0) {
    const { error } = await supabase
      .from("training_groups")
      .update({ active: false })
      .eq("id", groupId);
    if (error) redirect(`/grupos/${groupId}?error=No+pudimos+desactivar+el+grupo`);
    revalidatePath("/");
    revalidatePath("/grupos");
    redirect("/grupos?archived=1");
  }

  const { error } = await supabase
    .from("training_groups")
    .delete()
    .eq("id", groupId);
  if (error) redirect(`/grupos/${groupId}?error=No+pudimos+eliminar+el+grupo`);

  revalidatePath("/");
  revalidatePath("/grupos");
  redirect("/grupos?deleted=1");
}

export async function enrollGymnast(formData: FormData) {
  const groupId = value(formData, "group_id");
  const gymnastId = value(formData, "gymnast_id");
  if (!groupId || !gymnastId) {
    redirect(`/grupos/${groupId}?error=Selecciona+una+gimnasta`);
  }

  const supabase = await createClient();
  const [{ data: group }, { count }, { data: auth }] = await Promise.all([
    supabase
      .from("training_groups")
      .select("capacity, billing_program, group_schedule_slots(weekday)")
      .eq("id", groupId)
      .single(),
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

  const weeklyDays = new Set(
    (group.group_schedule_slots ?? []).map((slot: { weekday: number }) => slot.weekday),
  ).size;
  if (group.billing_program) {
    await supabase.from("gymnast_billing_profiles").upsert({
      gymnast_id: gymnastId,
      program: group.billing_program,
      days_per_week:
        group.billing_program === "Intensivo"
          ? null
          : Math.min(2, Math.max(1, weeklyDays)),
    });
  }

  revalidatePath("/");
  revalidatePath("/grupos");
  revalidatePath("/pagos/frecuencias");
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
