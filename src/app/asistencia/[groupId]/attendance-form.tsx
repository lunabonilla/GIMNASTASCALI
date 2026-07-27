"use client";

import { useState } from "react";
import { saveAttendance } from "../actions";
import styles from "./attendance.module.css";

type AttendanceStatus = "present" | "absent" | "excused" | "makeup";

type Gymnast = {
  id: string;
  name: string;
  initialStatus: AttendanceStatus;
  isMakeup: boolean;
};

const options: Array<{
  value: AttendanceStatus;
  icon: string;
  shortLabel: string;
  label: string;
}> = [
  { value: "present", icon: "✓", shortLabel: "Presente", label: "Presente" },
  { value: "absent", icon: "×", shortLabel: "No asistió", label: "No asistió" },
  { value: "excused", icon: "!", shortLabel: "Excusa", label: "Con excusa" },
  { value: "makeup", icon: "↻", shortLabel: "Recupera", label: "Recuperación" },
];

export function AttendanceForm({
  groupId,
  date,
  startsAt,
  endsAt,
  gymnasts,
}: {
  groupId: string;
  date: string;
  startsAt: string;
  endsAt: string;
  gymnasts: Gymnast[];
}) {
  const [statuses, setStatuses] = useState<Record<string, AttendanceStatus>>(
    Object.fromEntries(gymnasts.map((gymnast) => [gymnast.id, gymnast.initialStatus])),
  );

  const markAllPresent = () => {
    setStatuses(
      Object.fromEntries(
        gymnasts.map((gymnast) => [
          gymnast.id,
          gymnast.isMakeup ? "makeup" : "present",
        ]),
      ),
    );
  };

  const presentCount = Object.values(statuses).filter(
    (status) => status === "present" || status === "makeup",
  ).length;

  return (
    <form action={saveAttendance} className={styles.form}>
      <input type="hidden" name="group_id" value={groupId} />
      <input type="hidden" name="date" value={date} />
      <input type="hidden" name="starts_at" value={startsAt} />
      <input type="hidden" name="ends_at" value={endsAt} />

      <div className={styles.toolbar}>
        <div>
          <strong>{gymnasts.length} gimnastas</strong>
          <span>{presentCount} marcadas como asistentes</span>
        </div>
        <button type="button" onClick={markAllPresent}>
          ✓ Todas presentes
        </button>
      </div>

      <div className={styles.list}>
        {gymnasts.map((gymnast, index) => {
          const selected = statuses[gymnast.id];
          return (
            <article
              className={`${styles.row} ${gymnast.isMakeup ? styles.makeupRow : ""}`}
              key={gymnast.id}
            >
              <input
                type="hidden"
                name={`attendance_${gymnast.id}`}
                value={selected}
              />
              <div className={styles.identity}>
                <span>{index + 1}</span>
                <div>
                  <strong>{gymnast.name}</strong>
                  {gymnast.isMakeup && <small>Viene a recuperar</small>}
                </div>
              </div>
              <div className={styles.options} role="group" aria-label={`Asistencia de ${gymnast.name}`}>
                {options.map((option) => (
                  <button
                    type="button"
                    key={option.value}
                    className={`${styles.option} ${styles[option.value]} ${
                      selected === option.value ? styles.selected : ""
                    }`}
                    onClick={() =>
                      setStatuses((current) => ({
                        ...current,
                        [gymnast.id]: option.value,
                      }))
                    }
                    aria-pressed={selected === option.value}
                    title={option.label}
                  >
                    <span>{option.icon}</span>
                    <small>{option.shortLabel}</small>
                  </button>
                ))}
              </div>
            </article>
          );
        })}
      </div>

      <div className={styles.footer}>
        <span>
          <strong>{presentCount}</strong> asistirán ·{" "}
          <strong>{gymnasts.length - presentCount}</strong> no asistirán
        </span>
        <button type="submit">Guardar asistencia</button>
      </div>
    </form>
  );
}
