"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const value = (formData: FormData, name: string) =>
  String(formData.get(name) ?? "").trim();
const number = (formData: FormData, name: string) =>
  Number(value(formData, name).replace(/[^\d-]/g, ""));
const errorUrl = (message: string) =>
  `/inventario?error=${encodeURIComponent(message)}`;

export async function createProduct(formData: FormData) {
  const name = value(formData, "name");
  const category = value(formData, "category");
  const price = number(formData, "sale_price");
  const stock = number(formData, "stock_quantity");
  if (!name || !category || price < 0 || stock < 0) {
    redirect(errorUrl("Revisa los datos del producto"));
  }

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { data: product, error } = await supabase
    .from("products")
    .insert({
      name,
      category,
      variant: value(formData, "variant") || null,
      sku: value(formData, "sku") || null,
      sale_price_cents: price * 100,
      cost_cents: value(formData, "cost") ? number(formData, "cost") * 100 : null,
      stock_quantity: stock,
      minimum_stock: number(formData, "minimum_stock") || 0,
    })
    .select("id")
    .single();

  if (error || !product) redirect(errorUrl("No pudimos crear el producto; revisa el código SKU"));
  if (stock > 0) {
    await supabase.from("inventory_movements").insert({
      product_id: product.id,
      movement_type: "initial",
      quantity_change: stock,
      reason: "Existencia inicial",
      created_by: auth.claims.sub,
    });
  }
  revalidatePath("/inventario");
  redirect("/inventario?created=1");
}

export async function adjustStock(formData: FormData) {
  const productId = value(formData, "product_id");
  const quantity = number(formData, "quantity");
  if (!productId || !quantity) redirect(errorUrl("Ingresa una cantidad diferente de cero"));

  const supabase = await createClient();
  const { error } = await supabase.rpc("adjust_product_stock", {
    target_product_id: productId,
    quantity_delta: quantity,
    movement_reason: value(formData, "reason") || "Ajuste manual",
  });
  if (error) redirect(errorUrl("El ajuste dejaría existencias negativas"));
  revalidatePath("/inventario");
  redirect("/inventario?adjusted=1");
}
