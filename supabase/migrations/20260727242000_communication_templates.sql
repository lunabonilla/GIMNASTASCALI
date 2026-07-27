create table public.communication_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  channel text not null default 'whatsapp'
    check (channel in ('whatsapp', 'instagram', 'general')),
  purpose text not null default 'cycle_collection',
  body text not null,
  active boolean not null default true,
  meta_template_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.outbound_message_log (
  id uuid primary key default gen_random_uuid(),
  gymnast_id uuid references public.gymnasts(id) on delete set null,
  guardian_id uuid references public.guardians(id) on delete set null,
  charge_id uuid references public.billing_charges(id) on delete set null,
  template_id uuid references public.communication_templates(id) on delete set null,
  channel text not null,
  recipient text,
  rendered_body text not null,
  provider_message_id text,
  status text not null default 'queued'
    check (status in ('queued', 'sent', 'delivered', 'read', 'failed', 'cancelled')),
  error_message text,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index outbound_cycle_reminder_once
on public.outbound_message_log(charge_id, template_id, channel)
where charge_id is not null and status <> 'cancelled';

create trigger communication_templates_updated_at
before update on public.communication_templates
for each row execute function public.set_updated_at();

alter table public.communication_templates enable row level security;
alter table public.outbound_message_log enable row level security;

create policy "management manages communication templates"
on public.communication_templates for all to authenticated
using (public.is_management())
with check (public.is_management());

create policy "management manages outbound messages"
on public.outbound_message_log for all to authenticated
using (public.is_management())
with check (public.is_management());

grant select, insert, update, delete on public.communication_templates to authenticated;
grant select, insert, update, delete on public.outbound_message_log to authenticated;
