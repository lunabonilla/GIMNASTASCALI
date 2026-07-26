import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Club | Gimnastas Cali",
  description:
    "Plataforma interna para la gestión deportiva y administrativa de Gimnastas Cali.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
