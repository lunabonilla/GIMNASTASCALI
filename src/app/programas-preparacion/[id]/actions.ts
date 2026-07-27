"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

const pathFor = (programId: string) => `/programas-preparacion/${programId}`;

export async function enrollGymnast(formData: FormData) {
  const programId = value(formData, "program_id");
  const gymnastId = value(formData, "gymnast_id");
  if (!programId || !gymnastId) redirect("/programas-preparacion");
  const supabase = await createClient();
  const { error } = await supabase.from("preparation_program_enrollments").upsert({
    program_id: programId,
    gymnast_id: gymnastId,
    status: "active",
  });
  if (error) redirect(`${pathFor(programId)}?error=No+pudimos+agregar+la+deportista`);
  revalidatePath(pathFor(programId));
  redirect(`${pathFor(programId)}?enrolled=1`);
}

export async function savePreparationAttendance(formData: FormData) {
  const programId = value(formData, "program_id");
  const sessionOn = value(formData, "session_on");
  if (!programId || !sessionOn) redirect("/programas-preparacion");
  const supabase = await createClient();
  const { data: session, error: sessionError } = await supabase
    .from("preparation_sessions")
    .upsert({ program_id: programId, session_on: sessionOn }, { onConflict: "program_id,session_on" })
    .select("id")
    .single();
  if (sessionError || !session) {
    redirect(`${pathFor(programId)}?error=No+pudimos+crear+la+fecha`);
  }

  const rows = [...formData.entries()]
    .filter(([key, status]) =>
      key.startsWith("status:") &&
      ["attended", "absent", "double_class"].includes(String(status)),
    )
    .map(([key, status]) => ({
      session_id: session.id,
      gymnast_id: key.slice(7),
      status: String(status),
      updated_at: new Date().toISOString(),
    }));
  if (rows.length) {
    const { error } = await supabase
      .from("preparation_attendance")
      .upsert(rows, { onConflict: "session_id,gymnast_id" });
    if (error) redirect(`${pathFor(programId)}?error=No+pudimos+guardar+la+asistencia`);
  }
  revalidatePath(pathFor(programId));
  redirect(`${pathFor(programId)}?session=${sessionOn}&saved=1`);
}
