-- Multi-tenant schema base (NR-32 / SaaS futuro)
-- Cria organizations + sectors + inspection_photos
-- Adiciona organization_id nas tabelas existentes
-- Ajusta roles: owner/admin/inspector (coluna users.role)

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('hospital_ebserh', 'empresa_construcao')),
  plan text not null default 'gratuito',
  cnpj_or_code text,
  owner_id uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now()
);

create index if not exists organizations_owner_id_idx on public.organizations (owner_id);
create index if not exists organizations_code_idx on public.organizations (cnpj_or_code);

-- ============================================================
-- USERS (extensões)
-- ============================================================
alter table if exists public.users
  add column if not exists organization_id uuid references public.organizations (id) on delete restrict;

alter table if exists public.users
  add column if not exists full_name text;

alter table if exists public.users
  add column if not exists siape text;

-- Ajusta constraint de role para 3 roles.
do $$
begin
  alter table public.users drop constraint if exists users_role_check;
exception when undefined_object then
  null;
end $$;

alter table public.users
  add constraint users_role_check check (role in ('owner','admin','inspector'));

-- ============================================================
-- SECTORS
-- ============================================================
create table if not exists public.sectors (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create index if not exists sectors_org_idx on public.sectors (organization_id);

-- ============================================================
-- CHECKLIST_ITEMS (multi-tenant + sector opcional)
-- ============================================================
alter table if exists public.checklist_items
  add column if not exists organization_id uuid references public.organizations (id) on delete cascade;

alter table if exists public.checklist_items
  add column if not exists sector_id uuid references public.sectors (id) on delete set null;

create index if not exists checklist_items_org_idx on public.checklist_items (organization_id);
create index if not exists checklist_items_sector_idx on public.checklist_items (sector_id);

-- ============================================================
-- INSPECTIONS (multi-tenant + sector)
-- ============================================================
alter table if exists public.inspections
  add column if not exists organization_id uuid references public.organizations (id) on delete cascade;

alter table if exists public.inspections
  add column if not exists sector_id uuid references public.sectors (id) on delete set null;

create index if not exists inspections_org_idx on public.inspections (organization_id);
create index if not exists inspections_sector_idx on public.inspections (sector_id);

-- ============================================================
-- REPORTS (multi-tenant)
-- ============================================================
alter table if exists public.reports
  add column if not exists organization_id uuid references public.organizations (id) on delete cascade;

create index if not exists reports_org_idx on public.reports (organization_id);

-- ============================================================
-- INSPECTION_PHOTOS (metadata de fotos e paths)
-- ============================================================
create table if not exists public.inspection_photos (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  inspection_id uuid not null references public.inspections (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  storage_path text not null,
  public_url text,
  created_at timestamptz not null default now()
);

create index if not exists inspection_photos_org_idx on public.inspection_photos (organization_id);
create index if not exists inspection_photos_inspection_idx on public.inspection_photos (inspection_id);

