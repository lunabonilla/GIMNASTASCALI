"use client";

import { useState } from "react";

export function CopyMessage({ message }: { message: string }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    await navigator.clipboard.writeText(message);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  }

  return (
    <button type="button" className="copy-message-button" onClick={copy}>
      {copied ? "✓ Copiado" : "Copiar mensaje"}
    </button>
  );
}
