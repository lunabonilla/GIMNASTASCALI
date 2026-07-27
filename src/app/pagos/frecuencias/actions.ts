"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

export async function saveBillingFrequency(formData: FormData) {
  const gymnastId = value(formData, "gymnast_id");
  const program = value(formData, "program");
  const daysPerWeek = Number(value(formData, "days_per_week"));
  const cycleStart = value(formData, "cycle_start");
  const cycleEnd = value(formData, "cycle_end");
  const originalStatus = value(formData, "original_status");
  const returnUrl = "/pagos/frecuencias";

  if (
    !gymnastId ||
    !["Minis", "Regular"].includes(program) ||
    ![1, 2].includes(daysPerWeek)
  ) {
    redirect(`${returnUrl}?error=${encodeURIComponent("Selecciona una frecuencia válida")}`);
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { data: rate } = await supabase
    .from("billing_rate_plans")
    .select("amount_cents")
    .eq("program", program)
    .eq("days_per_week", daysPerWeek)
    .eq("effective_year", 2026)
    .eq("active", true)
    .single();
  if (!rate) {
    redirect(`${returnUrl}?error=${encodeURIComponent("No encontramos la tarifa configurada")}`);
  }

  const { data: currentProfile } = await supabase
    .from("gymnast_billing_profiles")
    .select("custom_cycle_amount_cents")
    .eq("gymnast_id", gymnastId)
    .maybeSingle();
  const cycleAmount = Number(
    currentProfile?.custom_cycle_amount_cents ?? rate.amount_cents,
  );

  const { error: profileError } = await supabase
    .from("gymnast_billing_profiles")
    .upsert({
      gymnast_id: gymnastId,
      program,
      days_per_week: daysPerWeek,
    });
  if (profileError) {
    redirect(`${returnUrl}?error=${encodeURIComponent("No pudimos guardar la frecuencia")}`);
  }

  if (cycleStart && cycleEnd) {
    const externalId = `current-cycle:${gymnastId}:${cycleStart}`;
    const { data: existingCharge } = await supabase
      .from("billing_charges")
      .select("id")
      .eq("external_source", "notion-cycle-rate")
      .eq("external_id", externalId)
      .maybeSingle();

    let chargeId = existingCharge?.id;
    if (chargeId) {
      await supabase
        .from("billing_charges")
        .update({
          amount_cents: cycleAmount,
          concept: `Ciclo ${cycleStart} a ${cycleEnd}`,
          due_on: cycleEnd,
          period_starts_on: cycleStart,
          period_ends_on: cycleEnd,
        })
        .eq("id", chargeId);
    } else {
      const { data: charge } = await supabase
        .from("billing_charges")
        .insert({
          gymnast_id: gymnastId,
          concept: `Ciclo ${cycleStart} a ${cycleEnd}`,
          category: "monthly_fee",
          description: `Tarifa ${program}, ${daysPerWeek} día${daysPerWeek > 1 ? "s" : ""} por semana · Estado original: ${originalStatus}`,
          issued_on: cycleStart,
          due_on: cycleEnd,
          period_starts_on: cycleStart,
          period_ends_on: cycleEnd,
          amount_cents: cycleAmount,
          created_by: auth.claims.sub,
          external_source: "notion-cycle-rate",
          external_id: externalId,
        })
        .select("id")
        .single();
      chargeId = charge?.id;
    }

    if (chargeId && originalStatus.includes("AL DÍA")) {
      const { data: existingPayment } = await supabase
        .from("payments")
        .select("id")
        .eq("external_source", "notion-cycle-rate")
        .eq("external_id", externalId)
        .maybeSingle();
      let paymentId = existingPayment?.id;
      if (paymentId) {
        await supabase.from("payments").update({
          amount_cents: cycleAmount,
        }).eq("id", paymentId);
      } else {
        const { data: payment } = await supabase
          .from("payments")
          .insert({
            gymnast_id: gymnastId,
            paid_on: cycleStart,
            amount_cents: cycleAmount,
            payment_method: "other",
            notes: "Ciclo marcado Al día en Notion",
            received_by: auth.claims.sub,
            external_source: "notion-cycle-rate",
            external_id: externalId,
          })
          .select("id")
          .single();
        paymentId = payment?.id;
      }
      if (paymentId) {
        const { data: allocation } = await supabase
          .from("payment_allocations")
          .select("payment_id")
          .eq("payment_id", paymentId)
          .eq("charge_id", chargeId)
          .maybeSingle();
        if (allocation) {
          await supabase.from("payment_allocations").update({
            amount_cents: cycleAmount,
          }).eq("payment_id", paymentId).eq("charge_id", chargeId);
        } else {
          await supabase.from("payment_allocations").insert({
            payment_id: paymentId,
            charge_id: chargeId,
            amount_cents: cycleAmount,
          });
        }
      }
    }
  }

  revalidatePath("/");
  revalidatePath("/pagos");
  revalidatePath("/pagos/frecuencias");
  redirect("/pagos/frecuencias?saved=1");
}
