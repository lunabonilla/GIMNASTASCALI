"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function saveAttendance(formData: FormData) {
  const groupId = String(formData.get("group_id") ?? "");
  const date = String(formData.get("date") ?? "");
  const startsAt = String(formData.get("starts_at") ?? "");
  const endsAt = String(formData.get("ends_at") ?? "");

  if (!groupId || !date || !startsAt || !endsAt) {
    redirect("/asistencia?error=Falta+información+de+la+clase");
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  const userId = auth?.claims?.sub;
  if (!userId) redirect("/login");

  const startIso = new Date(`${date}T${startsAt}-05:00`).toISOString();
  const endIso = new Date(`${date}T${endsAt}-05:00`).toISOString();
  const { data: session, error: sessionError } = await supabase
    .from("class_sessions")
    .upsert(
      { group_id: groupId, starts_at: startIso, ends_at: endIso },
      { onConflict: "group_id,starts_at" },
    )
    .select("id")
    .single();

  if (sessionError || !session) {
    redirect(`/asistencia/${groupId}?date=${date}&error=No+pudimos+crear+la+clase`);
  }

  const records = Array.from(formData.entries()).flatMap(([key, rawStatus]) => {
    if (!key.startsWith("attendance_")) return [];
    const gymnastId = key.replace("attendance_", "");
    const status = String(rawStatus);
    if (!["present", "absent", "excused", "makeup"].includes(status)) return [];
    return [{
      session_id: session.id,
      gymnast_id: gymnastId,
      status,
      recorded_by: userId,
      recorded_at: new Date().toISOString(),
    }];
  });

  if (records.length) {
    const { error } = await supabase
      .from("attendance_records")
      .upsert(records, { onConflict: "session_id,gymnast_id" });
    if (error) {
      redirect(`/asistencia/${groupId}?date=${date}&error=No+pudimos+guardar+la+asistencia`);
    }
  }

  revalidatePath("/");
  revalidatePath("/asistencia");
  revalidatePath(`/asistencia/${groupId}`);
  redirect(`/asistencia/${groupId}?date=${date}&saved=1`);
}

export async function addMakeupGymnast(formData: FormData) {
  const groupId = String(formData.get("group_id") ?? "");
  const gymnastId = String(formData.get("gymnast_id") ?? "");
  const date = String(formData.get("date") ?? "");
  const startsAt = String(formData.get("starts_at") ?? "");
  const endsAt = String(formData.get("ends_at") ?? "");
  if (!groupId || !gymnastId || !date || !startsAt || !endsAt) {
    redirect(`/asistencia/${groupId}?date=${date}&error=Selecciona+una+gimnasta`);
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  const userId = auth?.claims?.sub;
  if (!userId) redirect("/login");

  const startIso = new Date(`${date}T${startsAt}-05:00`).toISOString();
  const endIso = new Date(`${date}T${endsAt}-05:00`).toISOString();
  const { data: session, error: sessionError } = await supabase
    .from("class_sessions")
    .upsert(
      { group_id: groupId, starts_at: startIso, ends_at: endIso },
      { onConflict: "group_id,starts_at" },
    )
    .select("id")
    .single();
  if (sessionError || !session) {
    redirect(`/asistencia/${groupId}?date=${date}&error=No+pudimos+abrir+la+clase`);
  }

  const { error } = await supabase.from("attendance_records").upsert(
    {
      session_id: session.id,
      gymnast_id: gymnastId,
      status: "makeup",
      recorded_by: userId,
      recorded_at: new Date().toISOString(),
    },
    { onConflict: "session_id,gymnast_id" },
  );
  if (error) {
    redirect(`/asistencia/${groupId}?date=${date}&error=No+pudimos+agregar+la+recuperación`);
  }

  revalidatePath(`/asistencia/${groupId}`);
  redirect(`/asistencia/${groupId}?date=${date}&makeup=1`);
}
