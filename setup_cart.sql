-- ═══════════════════════════════════════════════════════════════════════════
-- Fleek Up Home — Cart / Orders extension
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists public.customer_orders (
  id                  text primary key,          -- e.g. 'FU-1714000000000'
  customer_name       text,
  customer_email      text,
  customer_phone      text,
  items               jsonb,                     -- full cart snapshot
  subtotal            numeric,
  total               numeric,
  status              text default 'pending',    -- pending | paid | shipped | cancelled
  payfast_payment_id  text,                      -- pf_payment_id returned by PayFast
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- Anyone can insert (guest checkout), only admins can read/update
alter table public.customer_orders enable row level security;

drop policy if exists "orders_insert" on public.customer_orders;
drop policy if exists "orders_admin"  on public.customer_orders;

create policy "orders_insert" on public.customer_orders
  for insert with check (true);

create policy "orders_admin" on public.customer_orders
  for all using (auth.role() = 'authenticated');
