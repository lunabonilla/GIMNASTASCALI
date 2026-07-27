alter table public.enrollments
  add column participation_status text not null default 'active'
  check (participation_status in ('active', 'vacation', 'paused', 'injured', 'pending'));

alter table public.enrollments
  add column status_note text;

create index enrollments_group_participation_status_idx
  on public.enrollments(group_id, participation_status)
  where active = true;

