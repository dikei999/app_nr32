-- Multi-tenant RLS e policies (Owner/Admin/Inspector)
-- Regras gerais:
-- - Apenas usuários autenticados (role authenticated)
-- - Tudo é filtrado por organization_id do usuário logado
-- - Owner/Admin têm acesso total dentro da organização
-- - Inspector: acesso restrito e inspeções só próprias
--
-- Como identificamos a organização do usuário:
-- - Tabela public.users (id = auth.uid()) contém organization_id e role
--
-- Como identificamos admin/owner via JWT:
-- - (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
--   (o app também grava role na public.users)

-- ============================================================
-- Helpers (views inline em policies via subquery)
-- ============================================================
-- Função utilitária (STABLE) para obter organization_id do usuário atual.
create or replace function public.current_organization_id()
returns uuid
language sql
stable
as $$
  select u.organization_id
  from public.users u
  where u.id = auth.uid()
$$;

create or replace function public.current_user_role()
returns text
language sql
stable
as $$
  select u.role
  from public.users u
  where u.id = auth.uid()
$$;

-- ============================================================
-- Enable RLS em todas as tabelas do app
-- ============================================================
alter table public.organizations enable row level security;
alter table public.users enable row level security;
alter table public.sectors enable row level security;
alter table public.checklist_items enable row level security;
alter table public.inspections enable row level security;
alter table public.reports enable row level security;
alter table public.inspection_photos enable row level security;

-- ============================================================
-- Drop policies (idempotente)
-- ============================================================
do $$
declare
  r record;
begin
  for r in (
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in (
        'organizations','users','sectors','checklist_items','inspections','reports','inspection_photos'
      )
  ) loop
    execute format('drop policy if exists %I on public.%I', r.policyname, r.tablename);
  end loop;
end $$;

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
-- SELECT: usuário vê apenas sua organização (por organization_id em public.users)
create policy "org_select_own"
on public.organizations
for select
to authenticated
using (id = public.current_organization_id());

-- INSERT: autenticado pode criar organização apenas se owner_id = auth.uid()
create policy "org_insert_owner"
on public.organizations
for insert
to authenticated
with check (owner_id = auth.uid());

-- UPDATE/DELETE: somente owner (da própria org) ou admin/owner via claim
create policy "org_update_owner"
on public.organizations
for update
to authenticated
using (
  id = public.current_organization_id()
  and (
    owner_id = auth.uid()
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
)
with check (
  id = public.current_organization_id()
  and (
    owner_id = auth.uid()
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

create policy "org_delete_owner"
on public.organizations
for delete
to authenticated
using (
  id = public.current_organization_id()
  and owner_id = auth.uid()
);

-- ============================================================
-- USERS
-- ============================================================
-- SELECT: owner/admin da org veem todos; inspector vê só a si mesmo
create policy "users_select_scoped"
on public.users
for select
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    id = auth.uid()
    or public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- INSERT: permitir inserir o próprio registro (id = auth.uid()) já com org definida
create policy "users_insert_self"
on public.users
for insert
to authenticated
with check (id = auth.uid());

-- UPDATE: usuário pode atualizar seus próprios campos; owner/admin podem atualizar qualquer usuário da org
create policy "users_update_scoped"
on public.users
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    id = auth.uid()
    or public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
)
with check (
  organization_id = public.current_organization_id()
);

-- DELETE: somente owner/admin da org
create policy "users_delete_admin"
on public.users
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- ============================================================
-- SECTORS
-- ============================================================
-- SELECT: qualquer autenticado da org
create policy "sectors_select_org"
on public.sectors
for select
to authenticated
using (organization_id = public.current_organization_id());

-- INSERT/UPDATE/DELETE: somente owner/admin da org
create policy "sectors_insert_admin"
on public.sectors
for insert
to authenticated
with check (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

create policy "sectors_update_admin"
on public.sectors
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
)
with check (organization_id = public.current_organization_id());

create policy "sectors_delete_admin"
on public.sectors
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- ============================================================
-- CHECKLIST_ITEMS
-- ============================================================
-- SELECT: qualquer autenticado da org
create policy "checklist_select_org"
on public.checklist_items
for select
to authenticated
using (organization_id = public.current_organization_id());

-- INSERT/UPDATE/DELETE: somente owner/admin
create policy "checklist_insert_admin"
on public.checklist_items
for insert
to authenticated
with check (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

create policy "checklist_update_admin"
on public.checklist_items
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
)
with check (organization_id = public.current_organization_id());

create policy "checklist_delete_admin"
on public.checklist_items
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- ============================================================
-- INSPECTIONS
-- ============================================================
-- SELECT: owner/admin vê tudo da org; inspector vê apenas as próprias
create policy "inspections_select_scoped"
on public.inspections
for select
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
    or user_id = auth.uid()
  )
);

-- INSERT: inspector cria só com user_id/auth.uid e org correta; admin/owner também
create policy "inspections_insert_scoped"
on public.inspections
for insert
to authenticated
with check (
  organization_id = public.current_organization_id()
  and (
    (user_id = auth.uid() and public.current_user_role() = 'inspector')
    or public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- UPDATE: inspector só atualiza a própria; admin/owner qualquer da org
create policy "inspections_update_scoped"
on public.inspections
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
    or user_id = auth.uid()
  )
)
with check (organization_id = public.current_organization_id());

-- DELETE: somente owner/admin
create policy "inspections_delete_admin"
on public.inspections
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- ============================================================
-- REPORTS
-- ============================================================
-- SELECT: owner/admin vê todos da org; inspector vê apenas seus
create policy "reports_select_scoped"
on public.reports
for select
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
    or user_id = auth.uid()
  )
);

-- INSERT/UPDATE: inspector só próprios; owner/admin qualquer
create policy "reports_insert_scoped"
on public.reports
for insert
to authenticated
with check (
  organization_id = public.current_organization_id()
  and (
    (user_id = auth.uid() and public.current_user_role() = 'inspector')
    or public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

create policy "reports_update_scoped"
on public.reports
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
    or user_id = auth.uid()
  )
)
with check (organization_id = public.current_organization_id());

-- DELETE: somente owner/admin
create policy "reports_delete_admin"
on public.reports
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- ============================================================
-- INSPECTION_PHOTOS
-- ============================================================
-- SELECT: owner/admin vê todas; inspector vê as próprias
create policy "photos_select_scoped"
on public.inspection_photos
for select
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
    or user_id = auth.uid()
  )
);

-- INSERT: inspector só próprias; owner/admin qualquer (mas sempre na org)
create policy "photos_insert_scoped"
on public.inspection_photos
for insert
to authenticated
with check (
  organization_id = public.current_organization_id()
  and (
    user_id = auth.uid()
    or public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

-- UPDATE/DELETE: somente owner/admin (evita adulteração)
create policy "photos_update_admin"
on public.inspection_photos
for update
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
)
with check (organization_id = public.current_organization_id());

create policy "photos_delete_admin"
on public.inspection_photos
for delete
to authenticated
using (
  organization_id = public.current_organization_id()
  and (
    public.current_user_role() in ('owner','admin')
    or (auth.jwt() -> 'app_metadata' ->> 'role') in ('owner','admin')
  )
);

