"use client";

import { useRef, useState } from "react";
import { updateGymnastInline } from "./actions";
import styles from "./page.module.css";

type Option = { value: string; label: string };

export function InlineSelect({
  gymnastId,
  field,
  value,
  options,
  returnQuery,
  label,
  tone,
}: {
  gymnastId: string;
  field: "program" | "level_id" | "status";
  value: string;
  options: Option[];
  returnQuery: string;
  label: string;
  tone: string;
}) {
  const formRef = useRef<HTMLFormElement>(null);
  const [saving, setSaving] = useState(false);

  return (
    <form ref={formRef} action={updateGymnastInline} className={styles.inlineForm}>
      <input type="hidden" name="gymnast_id" value={gymnastId} />
      <input type="hidden" name="field" value={field} />
      <input type="hidden" name="return_query" value={returnQuery} />
      <select
        name="value"
        defaultValue={value}
        aria-label={label}
        className={`${styles.inlineSelect} ${styles[tone] ?? ""}`}
        disabled={saving}
        onChange={() => {
          setSaving(true);
          formRef.current?.requestSubmit();
        }}
      >
        {options.map((option) => (
          <option key={option.value || "empty"} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      <span className={styles.saving} aria-live="polite">
        {saving ? "Guardando…" : ""}
      </span>
    </form>
  );
}
