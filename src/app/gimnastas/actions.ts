"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { parse } from "csv-parse/sync";
import { createClient } from "@/lib/supabase/server";

export async function createGymnast(formData: FormData) {
  const value = (name: string) => String(formData.get(name) ?? "").trim();
  const firstName = value("first_name");
  const lastName = value("last_name");
  const birthDate = value("birth_date");

  if (!firstName || !lastName) {
    redirect(
      "/gimnastas/nueva?error=Completa+todos+los+campos+obligatorios",
    );
  }

  const supabase = await createClient();
  const { error } = await supabase.rpc("register_gymnast", {
    p_first_name: firstName,
    p_last_name: lastName,
    p_birth_date: birthDate || null,
    p_identity_document: value("identity_document"),
    p_level_id: value("level_id") || null,
    p_guardian_name: value("guardian_name"),
    p_guardian_phone: value("guardian_phone"),
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

export async function updateGymnast(formData: FormData) {
  const value = (name: string) => String(formData.get(name) ?? "").trim();
  const gymnastId = value("gymnast_id");
  const firstName = value("first_name");
  const lastName = value("last_name");
  const birthDate = value("birth_date");

  if (!gymnastId || !firstName || !lastName) {
    redirect(`/gimnastas/${gymnastId}?error=Completa+los+campos+obligatorios`);
  }

  const supabase = await createClient();
  const { data: staff } = await supabase
    .from("staff_profiles")
    .select("role, active")
    .single();
  if (!staff?.active || staff.role !== "superadmin") {
    redirect(`/gimnastas/${gymnastId}?error=No+tienes+permiso+para+editar`);
  }

  const { error } = await supabase
    .from("gymnasts")
    .update({
      first_name: firstName,
      last_name: lastName,
      birth_date: birthDate || null,
      identity_document: value("identity_document") || null,
      level_id: value("level_id") || null,
      status: value("status") || "active",
      experience_notes: value("experience_notes") || null,
    })
    .eq("id", gymnastId);

  if (error) {
    const message =
      error.code === "23505"
        ? "Ya existe una gimnasta con ese documento"
        : "No pudimos actualizar la información";
    redirect(`/gimnastas/${gymnastId}?error=${encodeURIComponent(message)}`);
  }

  const { error: privateError } = await supabase
    .from("gymnast_private_details")
    .upsert({
      gymnast_id: gymnastId,
      address: value("address") || null,
      health_provider: value("health_provider") || null,
      allergies_conditions: value("allergies_conditions") || null,
      emergency_contact_name: value("emergency_contact_name") || null,
      emergency_contact_phone: value("emergency_contact_phone") || null,
      medical_notes: value("medical_notes") || null,
    });
  if (privateError) {
    redirect(`/gimnastas/${gymnastId}?error=No+pudimos+guardar+los+datos+de+salud`);
  }

  const { data: guardianLink } = await supabase
    .from("gymnast_guardians")
    .select("guardian_id")
    .eq("gymnast_id", gymnastId)
    .eq("is_primary", true)
    .maybeSingle();
  const guardianData = {
    full_name: value("guardian_name") || "Responsable por completar",
    identity_document: value("guardian_identity_document") || null,
    phone: value("guardian_phone") || "Por completar",
    alternate_phone: value("guardian_alternate_phone") || null,
    relationship: value("guardian_relationship") || null,
    email: value("guardian_email") || null,
    notes: value("guardian_notes") || null,
  };
  if (guardianLink?.guardian_id) {
    await supabase.from("guardians").update(guardianData).eq("id", guardianLink.guardian_id);
  } else if (value("guardian_name") || value("guardian_phone")) {
    const { data: guardian } = await supabase
      .from("guardians")
      .insert(guardianData)
      .select("id")
      .single();
    if (guardian) {
      await supabase.from("gymnast_guardians").insert({
        gymnast_id: gymnastId,
        guardian_id: guardian.id,
        is_primary: true,
      });
    }
  }

  const customCycleAmount = Number(
    value("custom_cycle_amount").replace(/[^\d]/g, ""),
  );
  await supabase.from("gymnast_billing_profiles").upsert({
    gymnast_id: gymnastId,
    program: value("billing_program") || null,
    days_per_week: value("days_per_week")
      ? Number(value("days_per_week"))
      : null,
    custom_cycle_amount_cents:
      Number.isFinite(customCycleAmount) && customCycleAmount > 0
        ? customCycleAmount * 100
        : null,
    pricing_notes: value("pricing_notes") || null,
  });

  revalidatePath("/");
  revalidatePath("/gimnastas");
  revalidatePath(`/gimnastas/${gymnastId}`);
  redirect(`/gimnastas/${gymnastId}?updated=1`);
}

type NotionGymnastRow = {
  "Nombre de la deportista"?: string;
  "Fecha de nacimiento"?: string;
  Nivel?: string;
  Estado?: string;
};

export async function importGymnasts(formData: FormData) {
  const file = formData.get("notion_csv");

  if (!(file instanceof File) || file.size === 0) {
    redirect("/gimnastas/importar?error=Selecciona+el+archivo+CSV");
  }

  if (file.size > 5_000_000) {
    redirect("/gimnastas/importar?error=El+archivo+es+demasiado+grande");
  }

  let rows: NotionGymnastRow[];
  try {
    rows = parse(await file.text(), {
      bom: true,
      columns: true,
      skip_empty_lines: true,
      trim: true,
    }) as NotionGymnastRow[];
  } catch {
    redirect("/gimnastas/importar?error=No+pudimos+leer+el+archivo+CSV");
  }

  const names = rows
    .map((row) => row["Nombre de la deportista"]?.trim() ?? "")
    .filter(Boolean);

  if (names.length === 0) {
    redirect(
      "/gimnastas/importar?error=El+archivo+no+contiene+la+columna+de+deportistas",
    );
  }

  const nameCounts = new Map<string, number>();
  for (const name of names) {
    const key = name.toLocaleLowerCase("es");
    nameCounts.set(key, (nameCounts.get(key) ?? 0) + 1);
  }

  const unambiguousRows = rows.filter((row) => {
    const name = row["Nombre de la deportista"]?.trim();
    return name && nameCounts.get(name.toLocaleLowerCase("es")) === 1;
  });

  const supabase = await createClient();
  const { data: profile } = await supabase
    .from("staff_profiles")
    .select("role, active")
    .single();

  if (!profile?.active || profile.role !== "superadmin") {
    redirect("/gimnastas/importar?error=No+tienes+permiso+para+importar");
  }

  const levelNames = Array.from(
    new Set(
      unambiguousRows
        .map((row) => row.Nivel?.trim().toUpperCase() ?? "")
        .filter(Boolean),
    ),
  );

  if (levelNames.length) {
    const { error: levelError } = await supabase.from("levels").upsert(
      levelNames.map((name, index) => ({
        name,
        sort_order: index + 1,
        active: true,
      })),
      { onConflict: "name" },
    );
    if (levelError) {
      redirect("/gimnastas/importar?error=No+pudimos+preparar+los+niveles");
    }
  }

  const { data: levels } = await supabase.from("levels").select("id, name");
  const levelByName = new Map(
    (levels ?? []).map((level) => [
      String(level.name).toUpperCase(),
      String(level.id),
    ]),
  );

  const { data: existing } = await supabase
    .from("gymnasts")
    .select("first_name, last_name");
  const existingNames = new Set(
    (existing ?? []).map((gymnast) =>
      `${gymnast.first_name} ${gymnast.last_name}`.trim().toLocaleLowerCase("es"),
    ),
  );

  const newGymnasts = unambiguousRows.flatMap((row) => {
    const fullName = row["Nombre de la deportista"]?.trim() ?? "";
    if (existingNames.has(fullName.toLocaleLowerCase("es"))) return [];

    const parts = fullName.split(/\s+/);
    const lastName = parts.length > 1 ? parts.pop() ?? "" : "";
    const firstName = parts.join(" ") || fullName;
    const rawStatus = row.Estado?.trim().toUpperCase();
    const status =
      rawStatus === "RETIRADO"
        ? "retired"
        : rawStatus === "PAUSADO"
          ? "suspended"
          : "active";
    const birthDate = row["Fecha de nacimiento"]?.trim().slice(0, 10) || null;
    const levelName = row.Nivel?.trim().toUpperCase();

    return [
      {
        first_name: firstName,
        last_name: lastName,
        birth_date: birthDate,
        level_id: levelName ? levelByName.get(levelName) ?? null : null,
        status,
        joined_on: null,
        experience_notes: `Importada desde Notion. Nombre original: ${fullName}`,
      },
    ];
  });

  let imported = 0;
  for (let index = 0; index < newGymnasts.length; index += 100) {
    const chunk = newGymnasts.slice(index, index + 100);
    const { error } = await supabase.from("gymnasts").insert(chunk);
    if (error) {
      redirect(
        `/gimnastas/importar?error=${encodeURIComponent(
          `La importación se detuvo después de ${imported} registros`,
        )}`,
      );
    }
    imported += chunk.length;
  }

  if (formData.get("automatic") !== "1") {
    revalidatePath("/");
    revalidatePath("/gimnastas");
  }
  redirect(
    `/gimnastas?imported=${imported}&pending=${rows.length - unambiguousRows.length}`,
  );
}
