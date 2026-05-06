-- ═══════════════════════════════════════════════════════════════════════════
-- Fleek Up Home — Add audience column to existing products table
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- (Skip if you are running setup.sql fresh — the column is already included)
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.products
  add column if not exists audience text
    not null default 'male'
    check (audience in ('male','female','home-decor'));

-- Seed audience values for existing products
update public.products set audience = 'female'    where id = 'eva-clutch';
update public.products set audience = 'home-decor' where type = 'rug';
-- Remaining bags default to 'male' (already set by column default)
