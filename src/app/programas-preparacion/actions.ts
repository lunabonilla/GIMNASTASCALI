"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function createPreparationProgram(formData: FormData) {
  const name = value(formData, "name");
  const rawPrice = value(formData, "base_price").replace(/[^\d]/g, "");
  const status = value(formData, "status");
  if (!name || !["draft", "open", "active"].includes(status)) {
    redirect("/programas-preparacion?error=Completa+los+campos+obligatorios");
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { error } = await supabase.from("preparation_programs").insert({
    name,
    description: value(formData, "description") || null,
    coach_name: value(formData, "coach_name") || null,
    starts_on: value(formData, "starts_on") || null,
    ends_on: value(formData, "ends_on") || null,
    base_price_cents: rawPrice ? Number(rawPrice) * 100 : null,
    status,
    created_by: auth.claims.sub,
  });
  if (error) {
    redirect("/programas-preparacion?error=No+pudimos+crear+el+programa");
  }

  revalidatePath("/");
  revalidatePath("/programas-preparacion");
  redirect("/programas-preparacion?created=1");
}
