"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function createCommunicationTemplate(formData: FormData) {
  const name = value(formData, "name");
  const body = value(formData, "body");
  const channel = value(formData, "channel");
  if (!name || !body || !["whatsapp", "instagram", "general"].includes(channel)) {
    redirect("/pagos/mensajes?error=Completa+el+nombre+y+el+texto+original");
  }
  const supabase = await createClient();
  const { error } = await supabase.from("communication_templates").insert({
    name,
    body,
    channel,
    purpose: "cycle_collection",
  });
  if (error) redirect("/pagos/mensajes?error=No+pudimos+guardar+la+plantilla");
  revalidatePath("/pagos/mensajes");
  redirect("/pagos/mensajes?created=1");
}
