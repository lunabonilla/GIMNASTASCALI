"use client";

import { endEnrollment } from "../actions";

export function RemoveEnrollmentButton({
  groupId,
  enrollmentId,
  gymnastName,
}: {
  groupId: string;
  enrollmentId: string;
  gymnastName: string;
}) {
  return (
    <form
      action={endEnrollment}
      className="member-remove-form"
      onSubmit={(event) => {
        if (!window.confirm(`¿Retirar a ${gymnastName} de este grupo? Su historial se conservará.`)) {
          event.preventDefault();
        }
      }}
    >
      <input type="hidden" name="group_id" value={groupId} />
      <input type="hidden" name="enrollment_id" value={enrollmentId} />
      <button type="submit" className="member-remove-button" aria-label={`Retirar a ${gymnastName}`} title="Retirar del grupo">
        ×
      </button>
    </form>
  );
}
