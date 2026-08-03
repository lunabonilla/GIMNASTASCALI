"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentStaffProfile } from "@/lib/current-staff";

const text = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function saveDailyAssignment(formData: FormData) {
  const workDate = text(formData, "work_date");
  const groupId = text(formData, "group_id");
  const scheduleSlotId = text(formData, "schedule_slot_id");
  const coachProfileId = text(formData, "coach_profile_id");
  const notes = text(formData, "notes");
  const returnUrl = `/horarios-profesores?date=${encodeURIComponent(workDate)}`;

  if (!workDate || !groupId || !scheduleSlotId) {
    redirect(`${returnUrl}&error=No+pudimos+identificar+el+bloque`);
  }

  const supabase = await createClient();
  const [profile, { data: slot }] = await Promise.all([
    getCurrentStaffProfile(),
    supabase
      .from("group_schedule_slots")
      .select("id, group_id")
      .eq("id", scheduleSlotId)
      .eq("group_id", groupId)
      .single(),
  ]);

  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect(`${returnUrl}&error=No+tienes+permiso+para+organizar+la+jornada`);
  }
  if (!slot) redirect(`${returnUrl}&error=El+bloque+de+horario+ya+no+existe`);

  const { data: auth } = await supabase.auth.getClaims();
  const { error } = await supabase.from("daily_staff_assignments").upsert(
    {
      work_date: workDate,
      group_id: groupId,
      schedule_slot_id: scheduleSlotId,
      coach_profile_id: coachProfileId || null,
      notes: notes || null,
      created_by: auth?.claims?.sub ?? null,
    },
    { onConflict: "work_date,schedule_slot_id" },
  );

  if (error) redirect(`${returnUrl}&error=No+pudimos+guardar+la+asignación`);
  revalidatePath("/horarios-profesores");
  revalidatePath("/");
  redirect(`${returnUrl}&saved=1`);
}
