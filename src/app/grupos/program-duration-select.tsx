"use client";

import { useEffect, useRef } from "react";

const durations: Record<string, number | null> = {
  Minis: 60,
  Regular: 90,
  Intensivo: null,
};

function addMinutes(time: string, minutes: number) {
  if (!/^\d{2}:\d{2}$/.test(time)) return "";
  const [hours, mins] = time.split(":").map(Number);
  const total = (hours * 60 + mins + minutes) % (24 * 60);
  return `${String(Math.floor(total / 60)).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;
}

export function ProgramDurationSelect({ defaultValue }: { defaultValue: string }) {
  const selectRef = useRef<HTMLSelectElement>(null);

  useEffect(() => {
    const select = selectRef.current;
    const form = select?.closest("form");
    if (!select || !form) return;

    const updateEndTimes = () => {
      const duration = durations[select.value];
      if (!duration) return;

      const starts = form.querySelectorAll<HTMLInputElement>(
        'input[name="starts_at"], input[name^="starts_at_"]',
      );
      starts.forEach((start) => {
        if (!start.value) return;
        const suffix = start.name.replace("starts_at", "");
        const end = form.querySelector<HTMLInputElement>(`input[name="ends_at${suffix}"]`);
        if (end) end.value = addMinutes(start.value, duration);
      });
    };

    const starts = Array.from(form.querySelectorAll<HTMLInputElement>(
      'input[name="starts_at"], input[name^="starts_at_"]',
    ));
    starts.forEach((input) => input.addEventListener("input", updateEndTimes));
    select.addEventListener("change", updateEndTimes);

    return () => {
      starts.forEach((input) => input.removeEventListener("input", updateEndTimes));
      select.removeEventListener("change", updateEndTimes);
    };
  }, []);

  return (
    <select ref={selectRef} name="billing_program" defaultValue={defaultValue}>
      <option value="Minis">Minis · 1 hora</option>
      <option value="Regular">Regular · 1 hora y 30 minutos</option>
      <option value="Intensivo">Integral / Intensivo · horario personalizado</option>
    </select>
  );
}
