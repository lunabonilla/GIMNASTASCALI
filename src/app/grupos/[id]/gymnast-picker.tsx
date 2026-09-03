"use client";

import { useMemo, useState } from "react";
import { enrollGymnast } from "../actions";

type GymnastOption = {
  id: string;
  name: string;
  status: "active" | "suspended";
};

const normalize = (value: string) =>
  value
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLocaleLowerCase("es")
    .trim();

export function GymnastPicker({
  groupId,
  gymnasts,
  returnDay,
}: {
  groupId: string;
  gymnasts: GymnastOption[];
  returnDay?: number;
}) {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<GymnastOption | null>(null);

  const matches = useMemo(() => {
    const term = normalize(query);
    if (term.length < 2) return [];
    return gymnasts
      .filter((gymnast) => normalize(gymnast.name).includes(term))
      .slice(0, 7);
  }, [gymnasts, query]);

  return (
    <form action={enrollGymnast} className="group-gymnast-picker">
      <input type="hidden" name="group_id" value={groupId} />
      <input type="hidden" name="gymnast_id" value={selected?.id ?? ""} />
      {returnDay && <input type="hidden" name="return_day" value={returnDay} />}
      <label>
        Escribe el nombre de la niña
        <input
          type="search"
          value={query}
          placeholder="Ej. Abigail Giraldo"
          autoComplete="off"
          onChange={(event) => {
            setQuery(event.target.value);
            setSelected(null);
          }}
        />
      </label>
      {query.trim().length >= 2 && !selected && (
        <div className="group-gymnast-results">
          {matches.length ? matches.map((gymnast) => (
            <button
              type="button"
              key={gymnast.id}
              onClick={() => {
                setSelected(gymnast);
                setQuery(gymnast.name);
              }}
            >
              <i>{gymnast.name.charAt(0)}</i>
              <span>
                {gymnast.name}
                {gymnast.status === "suspended" && <small>Pausada</small>}
              </span>
            </button>
          )) : <p>No encontramos una gimnasta con ese nombre.</p>}
        </div>
      )}
      {selected && <div className="selected-group-gymnast">✓ {selected.name}</div>}
      <button type="submit" className="primary-button" disabled={!selected}>
        Agregar al grupo
      </button>
    </form>
  );
}
