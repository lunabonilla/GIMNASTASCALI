"use client";

import { endEnrollment, updateEnrollmentStatus } from "./actions";
import { GymnastPicker } from "./[id]/gymnast-picker";
import styles from "./page.module.css";

type Participant = {
  id: string;
  name: string;
  status: "active" | "vacation" | "paused" | "injured" | "pending";
  statusNote: string | null;
};

export function QuickParticipants({
  groupId,
  day,
  participants,
  availableGymnasts,
}: {
  groupId: string;
  day: number;
  participants: Participant[];
  availableGymnasts: Array<{ id: string; name: string; status: "active" | "suspended" }>;
}) {
  return (
    <details className={styles.participantEditor}>
      <summary>Participantes <span>{participants.length}</span></summary>
      <div className={styles.participantPanel}>
        <div className={styles.quickRoster}>
          {participants.map((participant) => (
            <div className={styles.quickParticipant} key={participant.id}>
              <strong>{participant.name}</strong>
              <form action={updateEnrollmentStatus}>
                <input type="hidden" name="group_id" value={groupId} />
                <input type="hidden" name="enrollment_id" value={participant.id} />
                <input type="hidden" name="return_day" value={day} />
                <input type="hidden" name="status_note" value={participant.statusNote ?? ""} />
                <select
                  name="participation_status"
                  defaultValue={participant.status}
                  aria-label={`Estado de ${participant.name}`}
                  onChange={(event) => event.currentTarget.form?.requestSubmit()}
                >
                  <option value="active">Entrenando</option>
                  <option value="vacation">Vacaciones</option>
                  <option value="paused">Pausada</option>
                  <option value="injured">Lesión</option>
                  <option value="pending">Pendiente</option>
                </select>
              </form>
              <form
                action={endEnrollment}
                onSubmit={(event) => {
                  if (!window.confirm(`¿Retirar a ${participant.name} de este grupo?`)) event.preventDefault();
                }}
              >
                <input type="hidden" name="group_id" value={groupId} />
                <input type="hidden" name="enrollment_id" value={participant.id} />
                <input type="hidden" name="return_day" value={day} />
                <button type="submit" aria-label={`Retirar a ${participant.name}`} title="Retirar del grupo">×</button>
              </form>
            </div>
          ))}
        </div>
        <div className={styles.quickAdd}>
          <strong>Agregar otra niña</strong>
          <GymnastPicker groupId={groupId} returnDay={day} gymnasts={availableGymnasts} />
        </div>
      </div>
    </details>
  );
}
