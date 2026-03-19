-- RLS e Políticas de Segurança (NR-32 / EBSERH)
-- Objetivo:
-- - Exigir usuário autenticado (não anon) para acessar dados
-- - "admin" (Fiscal) com acesso total via claim em JWT: auth.jwt()->'app_metadata'->>'role' = 'admin'
-- - "inspector" com acesso restrito por ownership (auth.uid())

-- ============================================================
-- Helpers (somente para leitura, usado nas policies)
-- ============================================================
-- Observação: policies não podem chamar funções SECURITY DEFINER aqui sem necessidade.

-- ============================================================
-- Ajuste de schema para ownership em reports
-- ============================================================
-- Para permitir que Inspetor veja apenas seus relatórios, precisamos de user_id.
alter table if exists public.reports
  add column if not exists user_id uuid references public.users (id) on delete cascade;

create index if not exists reports_user_id_idx on public.reports (user_id);

-- ============================================================
-- Enable RLS
-- ============================================================
alter table public.users enable row level security;
alter table public.checklist_items enable row level security;
alter table public.inspections enable row level security;
alter table public.reports enable row level security;

-- ============================================================
-- Drop policies anteriores (idempotente)
-- ============================================================
drop policy if exists "users_select_own_or_admin" on public.users;
drop policy if exists "checklist_read_authenticated" on public.checklist_items;
drop policy if exists "checklist_write_admin" on public.checklist_items;
drop policy if exists "inspections_select_own_or_admin" on public.inspections;
drop policy if exists "inspections_insert_own" on public.inspections;
drop policy if exists "reports_select_admin" on public.reports;

-- ============================================================
-- USERS
-- ============================================================
-- Regra: autenticado pode ver o próprio user; admin pode ver todos.
-- Nota: o "role admin" é lido de app_metadata no JWT.
create policy "users_select_own_or_admin"
on public.users
for select
to authenticated
using (
  auth.uid() = id
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: autenticado pode inserir seu próprio registro (normalmente via trigger no signup).
create policy "users_insert_own"
on public.users
for insert
to authenticated
with check (auth.uid() = id);

-- Regra: autenticado pode atualizar somente o próprio registro; admin pode atualizar qualquer.
create policy "users_update_own_or_admin"
on public.users
for update
to authenticated
using (
  auth.uid() = id
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  auth.uid() = id
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: delete só admin (evita remoção acidental de perfis).
create policy "users_delete_admin"
on public.users
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- ============================================================
-- CHECKLIST_ITEMS
-- ============================================================
-- Regra: autenticado (admin ou inspetor) pode ler checklist.
create policy "checklist_items_select_authenticated"
on public.checklist_items
for select
to authenticated
using (true);

-- Regra: somente admin cria itens.
create policy "checklist_items_insert_admin"
on public.checklist_items
for insert
to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Regra: somente admin atualiza itens.
create policy "checklist_items_update_admin"
on public.checklist_items
for update
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Regra: somente admin remove itens.
create policy "checklist_items_delete_admin"
on public.checklist_items
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- ============================================================
-- INSPECTIONS
-- ============================================================
-- Regra: inspetor lê só as próprias; admin lê tudo.
create policy "inspections_select_own_or_admin"
on public.inspections
for select
to authenticated
using (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: inspetor cria só com user_id = auth.uid(); admin também pode criar.
create policy "inspections_insert_own_or_admin"
on public.inspections
for insert
to authenticated
with check (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: inspetor atualiza só as próprias; admin atualiza tudo.
create policy "inspections_update_own_or_admin"
on public.inspections
for update
to authenticated
using (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: delete só admin (mantém histórico).
create policy "inspections_delete_admin"
on public.inspections
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- ============================================================
-- REPORTS
-- ============================================================
-- Regra: inspetor lê só os próprios relatórios; admin lê todos.
create policy "reports_select_own_or_admin"
on public.reports
for select
to authenticated
using (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: inspetor cria só os próprios; admin também pode criar.
create policy "reports_insert_own_or_admin"
on public.reports
for insert
to authenticated
with check (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: inspetor atualiza só os próprios (ex: marcar enviado?); admin atualiza tudo.
create policy "reports_update_own_or_admin"
on public.reports
for update
to authenticated
using (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  user_id = auth.uid()
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Regra: delete só admin (evita apagar evidências).
create policy "reports_delete_admin"
on public.reports
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

