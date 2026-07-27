"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();

const pesosToCents = (raw: string) => {
  const normalized = raw.replace(/[^\d]/g, "");
  return normalized ? Number(normalized) * 100 : 0;
};

const errorUrl = (path: string, message: string) =>
  `${path}?error=${encodeURIComponent(message)}`;

export async function createCharge(formData: FormData) {
  const gymnastId = value(formData, "gymnast_id");
  const concept = value(formData, "concept");
  const category = value(formData, "category");
  const dueOn = value(formData, "due_on");
  const amountCents = pesosToCents(value(formData, "amount"));
  const allowedCategories = [
    "monthly_fee",
    "extra_class",
    "private_class",
    "product",
    "competition",
    "other",
  ];

  if (!gymnastId || !concept || !dueOn || amountCents <= 0) {
    redirect(errorUrl("/pagos/nuevo", "Completa los campos obligatorios"));
  }
  if (!allowedCategories.includes(category)) {
    redirect(errorUrl("/pagos/nuevo", "Selecciona un tipo de cargo válido"));
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { error } = await supabase.from("billing_charges").insert({
    gymnast_id: gymnastId,
    concept,
    category,
    description: value(formData, "description") || null,
    issued_on: value(formData, "issued_on") || new Date().toISOString().slice(0, 10),
    due_on: dueOn,
    period_starts_on: value(formData, "period_starts_on") || null,
    period_ends_on: value(formData, "period_ends_on") || null,
    amount_cents: amountCents,
    created_by: auth.claims.sub,
  });

  if (error) {
    redirect(errorUrl("/pagos/nuevo", "No pudimos crear el cargo"));
  }

  revalidatePath("/");
  revalidatePath("/pagos");
  revalidatePath(`/pagos/${gymnastId}`);
  redirect(`/pagos/${gymnastId}?created=1`);
}

export async function registerPayment(formData: FormData) {
  const gymnastId = value(formData, "gymnast_id");
  const chargeId = value(formData, "charge_id");
  const amountCents = pesosToCents(value(formData, "amount"));
  const paymentMethod = value(formData, "payment_method");
  const returnPath = `/pagos/${gymnastId}`;

  if (!gymnastId || !chargeId || amountCents <= 0) {
    redirect(errorUrl(returnPath, "Ingresa un valor de pago válido"));
  }
  if (!["cash", "transfer", "card", "other"].includes(paymentMethod)) {
    redirect(errorUrl(returnPath, "Selecciona un medio de pago válido"));
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { data: charge } = await supabase
    .from("billing_charges")
    .select("amount_cents, gymnast_id, voided_at, payment_allocations(amount_cents)")
    .eq("id", chargeId)
    .eq("gymnast_id", gymnastId)
    .single();

  const allocations = (charge?.payment_allocations ?? []) as Array<{
    amount_cents: number;
  }>;
  const paidCents = allocations.reduce(
    (total, allocation) => total + Number(allocation.amount_cents),
    0,
  );
  const balanceCents = Number(charge?.amount_cents ?? 0) - paidCents;

  if (!charge || charge.voided_at || amountCents > balanceCents) {
    redirect(errorUrl(returnPath, "El pago supera el saldo pendiente"));
  }

  const { data: payment, error: paymentError } = await supabase
    .from("payments")
    .insert({
      gymnast_id: gymnastId,
      paid_on: value(formData, "paid_on") || new Date().toISOString().slice(0, 10),
      amount_cents: amountCents,
      payment_method: paymentMethod,
      reference: value(formData, "reference") || null,
      notes: value(formData, "notes") || null,
      received_by: auth.claims.sub,
    })
    .select("id")
    .single();

  if (paymentError || !payment) {
    redirect(errorUrl(returnPath, "No pudimos registrar el pago"));
  }

  const { error: allocationError } = await supabase
    .from("payment_allocations")
    .insert({
      payment_id: payment.id,
      charge_id: chargeId,
      amount_cents: amountCents,
    });

  if (allocationError) {
    await supabase.from("payments").delete().eq("id", payment.id);
    redirect(errorUrl(returnPath, "No pudimos aplicar el abono al cargo"));
  }

  revalidatePath("/");
  revalidatePath("/pagos");
  revalidatePath(returnPath);
  redirect(`${returnPath}?paid=1`);
}
