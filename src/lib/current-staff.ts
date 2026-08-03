import { createClient } from "@/lib/supabase/server";

export async function getCurrentStaffProfile() {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  const userId = auth?.claims?.sub;
  if (!userId) return null;

  const { data } = await supabase
    .from("staff_profiles")
    .select("id, full_name, role, phone, active")
    .eq("id", userId)
    .maybeSingle();

  return data;
}
