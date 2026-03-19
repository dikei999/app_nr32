-- Projeto: Gestão de Conformidade NR-32 (EBSERH)
-- Observação: execute via Supabase CLI (db push) ou SQL Editor.

create table if not exists public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  email text unique,
  role text not null check (role in ('inspector', 'admin')) default 'inspector',
  hospital_id text,
  created_at timestamptz not null default now()
);

create table if not exists public.checklist_items (
  id uuid primary key default gen_random_uuid(),
  nr32_section text not null,
  item_description text not null,
  is_required_photo boolean not null default false,
  "order" int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  date date not null default current_date,
  checklist_data jsonb not null default '{}'::jsonb,
  photos text[] not null default '{}'::text[],
  status text not null default 'finalizada',
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  period text not null check (period in ('daily','weekly','monthly','semestral')),
  generated_at timestamptz not null default now(),
  pdf_url text,
  sent_to_engineer boolean not null default false,
  created_at timestamptz not null default now()
);

-- RLS (mínimo recomendado; ajuste conforme política)
alter table public.users enable row level security;
alter table public.checklist_items enable row level security;
alter table public.inspections enable row level security;
alter table public.reports enable row level security;

-- users: cada usuário vê seu próprio registro; admin vê todos
create policy "users_select_own_or_admin"
on public.users
for select
using (
  auth.uid() = id
  or exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  )
);

-- checklist_items: leitura para autenticados; escrita só admin
create policy "checklist_read_authenticated"
on public.checklist_items
for select
using (auth.role() = 'authenticated');

create policy "checklist_write_admin"
on public.checklist_items
for all
using (
  exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  )
);

-- inspections: inspetor vê as próprias; admin vê todas
create policy "inspections_select_own_or_admin"
on public.inspections
for select
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  )
);

create policy "inspections_insert_own"
on public.inspections
for insert
with check (user_id = auth.uid());

-- reports: admin vê todas; (opcional) inspetor não vê
create policy "reports_select_admin"
on public.reports
for select
using (
  exists (
    select 1 from public.users u
    where u.id = auth.uid() and u.role = 'admin'
  )
);

