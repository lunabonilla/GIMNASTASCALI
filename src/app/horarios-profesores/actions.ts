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
  const assistantProfileId = text(formData, "assistant_profile_id");
  const notes = text(formData, "notes");
  const returnUrl = `/horarios-profesores?date=${encodeURIComponent(workDate)}`;

  if (!workDate || !groupId || !scheduleSlotId) {
    redirect(`${returnUrl}&error=No+pudimos+identificar+el+bloque`);
  }
  if (coachProfileId && coachProfileId === assistantProfileId) {
    redirect(`${returnUrl}&error=El+profesor+principal+y+el+apoyo+deben+ser+personas+distintas`);
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
      assistant_profile_id: assistantProfileId || null,
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

type SlotRow = {
  id: string;
  group_id: string;
  starts_at: string;
  ends_at: string;
  training_groups: { coach_profile_id: string | null; levels: { name: string } | Array<{ name: string }> | null }
    | Array<{ coach_profile_id: string | null; levels: { name: string } | Array<{ name: string }> | null }>
    | null;
};

const overlaps = (a: { starts_at: string; ends_at: string }, b: { starts_at: string; ends_at: string }) =>
  a.starts_at < b.ends_at && b.starts_at < a.ends_at;

export async function autoOrganizeDay(formData: FormData) {
  const workDate = text(formData, "work_date");
  const absentIds = new Set(formData.getAll("absent_staff").map(String));
  const returnUrl = `/horarios-profesores?date=${encodeURIComponent(workDate)}`;
  if (!/^\d{4}-\d{2}-\d{2}$/.test(workDate)) redirect("/horarios-profesores?error=Selecciona+una+fecha+válida");

  const profile = await getCurrentStaffProfile();
  if (!profile?.active || !["superadmin", "administration"].includes(profile.role)) {
    redirect(`${returnUrl}&error=No+tienes+permiso+para+reorganizar+la+jornada`);
  }

  const weekday = new Date(`${workDate}T12:00:00Z`).getUTCDay() || 7;
  const supabase = await createClient();
  const [{ data: slotsData }, { data: staffData }, { data: capabilitiesData }] = await Promise.all([
    supabase
      .from("group_schedule_slots")
      .select("id, group_id, starts_at, ends_at, training_groups!inner(coach_profile_id, active, levels(name))")
      .eq("weekday", weekday)
      .eq("training_groups.active", true)
      .order("starts_at"),
    supabase.from("staff_profiles").select("id, full_name").eq("active", true),
    supabase.from("staff_coaching_capabilities").select("staff_profile_id, level_name, assignment_role, requires_support"),
  ]);

  const slots = (slotsData ?? []) as SlotRow[];
  const available = (staffData ?? []).filter((person) => !absentIds.has(person.id));
  if (available.length === 0) redirect(`${returnUrl}&error=No+quedaron+profesores+disponibles`);

  const capabilities = capabilitiesData ?? [];
  const assigned = new Map<string, SlotRow[]>();
  const load = new Map<string, number>();
  const canTake = (staffId: string, slot: SlotRow) =>
    !(assigned.get(staffId) ?? []).some((other) => overlaps(slot, other));
  const candidates = (level: string, role: "lead" | "support") =>
    available.filter((person) => capabilities.some((capability) =>
      capability.staff_profile_id === person.id
      && capability.level_name === level
      && capability.assignment_role === role,
    ));
  const pick = (people: typeof available, slot: SlotRow, preferred?: string | null) => {
    const possible = people.filter((person) => canTake(person.id, slot));
    const preferredPerson = preferred
      ? possible.find((person) => person.id === preferred) ?? null
      : null;
    return preferredPerson ?? possible.sort((a, b) => (load.get(a.id) ?? 0) - (load.get(b.id) ?? 0))[0] ?? null;
  };
  const reserve = (staffId: string, slot: SlotRow) => {
    assigned.set(staffId, [...(assigned.get(staffId) ?? []), slot]);
    load.set(staffId, (load.get(staffId) ?? 0) + 1);
  };

  const rows = slots.map((slot) => {
    const group = Array.isArray(slot.training_groups) ? slot.training_groups[0] : slot.training_groups;
    const levelRelation = group?.levels;
    const level = Array.isArray(levelRelation) ? levelRelation[0]?.name ?? "" : levelRelation?.name ?? "";
    const leadOptions = candidates(level, "lead");
    const lead = pick(leadOptions.length ? leadOptions : available, slot, group?.coach_profile_id);
    if (lead) reserve(lead.id, slot);

    const leadCapability = capabilities.find((capability) =>
      capability.staff_profile_id === lead?.id && capability.level_name === level && capability.assignment_role === "lead",
    );
    let assistant = null as (typeof available)[number] | null;
    if (leadCapability?.requires_support) {
      const supportOptions = candidates(level, "support").filter((person) => person.id !== lead?.id);
      const fallback = available.filter((person) => person.id !== lead?.id);
      assistant = pick(supportOptions.length ? supportOptions : fallback, slot);
      if (assistant) reserve(assistant.id, slot);
    }

    return {
      work_date: workDate,
      group_id: slot.group_id,
      schedule_slot_id: slot.id,
      coach_profile_id: lead?.id ?? null,
      assistant_profile_id: assistant?.id ?? null,
      notes: lead ? "Jornada reorganizada automáticamente" : "Requiere asignación manual",
      created_by: profile.id,
    };
  });

  const { error } = await supabase.from("daily_staff_assignments").upsert(rows, {
    onConflict: "work_date,schedule_slot_id",
  });
  if (error) redirect(`${returnUrl}&error=No+pudimos+reorganizar+la+jornada`);

  revalidatePath("/horarios-profesores");
  revalidatePath("/");
  redirect(`${returnUrl}&organized=1`);
}
