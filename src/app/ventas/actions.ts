"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) => String(formData.get(name) ?? "").trim();

export async function createSale(formData: FormData) {
  const productId = value(formData, "product_id");
  const quantity = Number(value(formData, "quantity"));
  const gymnastId = value(formData, "gymnast_id") || null;
  const customerName = value(formData, "customer_name") || null;
  if (!productId || !Number.isInteger(quantity) || quantity <= 0 || (!gymnastId && !customerName)) {
    redirect(`/ventas?error=${encodeURIComponent("Selecciona el producto y escribe quién compra")}`);
  }
  const supabase = await createClient();
  const { error } = await supabase.rpc("register_product_sale", {
    target_product_id: productId,
    sale_quantity: quantity,
    target_gymnast_id: gymnastId,
    buyer_name: customerName,
    sale_payment_status: value(formData, "payment_status"),
    sale_payment_method: value(formData, "payment_method"),
    sale_notes: value(formData, "notes") || null,
  });
  if (error) redirect(`/ventas?error=${encodeURIComponent("No hay existencias suficientes o los datos no son válidos")}`);
  revalidatePath("/");
  revalidatePath("/inventario");
  revalidatePath("/ventas");
  redirect("/ventas?created=1");
}
