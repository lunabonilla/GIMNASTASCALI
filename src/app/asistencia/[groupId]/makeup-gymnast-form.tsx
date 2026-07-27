"use client";

import { useMemo, useState } from "react";
import { addMakeupGymnast } from "../actions";
import styles from "./attendance.module.css";

type GymnastOption = {
  id: string;
  name: string;
};

const normalize = (value: string) =>
  value
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLocaleLowerCase("es")
    .trim();

export function MakeupGymnastForm({
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
  gymnasts: GymnastOption[];
}) {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<GymnastOption | null>(null);
  const [open, setOpen] = useState(false);

  const matches = useMemo(() => {
    const term = normalize(query);
    if (term.length < 2) return [];
    return gymnasts
      .filter((gymnast) => normalize(gymnast.name).includes(term))
      .slice(0, 6);
  }, [gymnasts, query]);

  return (
    <form action={addMakeupGymnast} className={styles.makeupForm}>
      <input type="hidden" name="group_id" value={groupId} />
      <input type="hidden" name="date" value={date} />
      <input type="hidden" name="starts_at" value={startsAt} />
      <input type="hidden" name="ends_at" value={endsAt} />
      <input type="hidden" name="gymnast_id" value={selected?.id ?? ""} />

      <div className={styles.makeupCopy}>
        <strong>↻ Agregar recuperación</strong>
        <span>Busca una gimnasta de otro grupo para incluirla solo en esta clase.</span>
      </div>

      <div className={styles.makeupSearch}>
        <input
          type="search"
          value={query}
          placeholder="Escribe el nombre de la niña…"
          autoComplete="off"
          onFocus={() => setOpen(true)}
          onChange={(event) => {
            setQuery(event.target.value);
            setSelected(null);
            setOpen(true);
          }}
          aria-label="Buscar gimnasta para recuperación"
        />
        {selected && (
          <span className={styles.selectedGymnast}>✓ {selected.name}</span>
        )}
        {open && query.trim().length >= 2 && !selected && (
          <div className={styles.searchResults}>
            {matches.length ? (
              matches.map((gymnast) => (
                <button
                  type="button"
                  key={gymnast.id}
                  onClick={() => {
                    setSelected(gymnast);
                    setQuery(gymnast.name);
                    setOpen(false);
                  }}
                >
                  <span>{gymnast.name.slice(0, 1).toUpperCase()}</span>
                  {gymnast.name}
                </button>
              ))
            ) : (
              <p>No encontramos una gimnasta con ese nombre.</p>
            )}
          </div>
        )}
      </div>

      <button type="submit" className={styles.addMakeupButton} disabled={!selected}>
        ＋ Agregar
      </button>
    </form>
  );
}
