import { NextRequest, NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const cronSecret = process.env.CRON_SECRET;
  const authorization = request.headers.get("authorization");

  if (!cronSecret || authorization !== `Bearer ${cronSecret}`) {
    return NextResponse.json({ ok: false }, { status: 401 });
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const publishableKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  if (!supabaseUrl || !publishableKey) {
    return NextResponse.json(
      { ok: false, error: "Supabase no está configurado" },
      { status: 500 },
    );
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/keep_project_active`, {
    method: "POST",
    headers: {
      apikey: publishableKey,
      "Content-Type": "application/json",
    },
    body: "{}",
    cache: "no-store",
  });

  if (!response.ok) {
    return NextResponse.json(
      { ok: false, error: "No se pudo comprobar Supabase" },
      { status: 502 },
    );
  }

  return NextResponse.json({ ok: true });
}
