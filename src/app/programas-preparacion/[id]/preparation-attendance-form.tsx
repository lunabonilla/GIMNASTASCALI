"use client";

import { useState } from "react";
import { savePreparationAttendance } from "./actions";
import styles from "./page.module.css";

type Status = "attended" | "absent" | "double_class";

const options: Array<{ value: Status; label: string; icon: string }> = [
  { value: "attended", label: "Asistió", icon: "✓" },
  { value: "absent", label: "No asistió", icon: "×" },
  { value: "double_class", label: "Clase doble", icon: "↻" },
];

export function PreparationAttendanceForm({
  programId,
  sessionOn,
  participants,
}: {
  programId: string;
  sessionOn: string;
  participants: Array<{ id: string; name: string; status: Status }>;
}) {
  const [statuses, setStatuses] = useState<Record<string, Status>>(
    Object.fromEntries(participants.map((participant) => [participant.id, participant.status])),
  );

  return (
    <form action={savePreparationAttendance} className={styles.roll}>
      <input type="hidden" name="program_id" value={programId} />
      <input type="hidden" name="session_on" value={sessionOn} />
      <div className={styles.rollHeading}>
        <div><span>Tomar asistencia</span><h2>{sessionOn}</h2></div>
        <button>Guardar asistencia</button>
      </div>
      <div className={styles.rollList}>
        {participants.map((participant, index) => (
          <div className={styles.rollRow} key={participant.id}>
            <input type="hidden" name={`status:${participant.id}`} value={statuses[participant.id]} />
            <div className={styles.person}>
              <span>{index + 1}</span><strong>{participant.name}</strong>
            </div>
            <div className={styles.statusOptions}>
              {options.map((option) => (
                <button
                  type="button"
                  key={option.value}
                  className={`${styles.statusButton} ${styles[option.value]} ${statuses[participant.id] === option.value ? styles.selected : ""}`}
                  onClick={() => setStatuses((current) => ({ ...current, [participant.id]: option.value }))}
                >
                  <span>{option.icon}</span>{option.label}
                </button>
              ))}
            </div>
          </div>
        ))}
      </div>
    </form>
  );
}
