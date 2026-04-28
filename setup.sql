-- ═══════════════════════════════════════════════════════════════════════════
-- FLEEK UP HOME — Supabase Database Setup
-- Run this entire file in: Supabase Dashboard → SQL Editor → New Query → Run
-- ═══════════════════════════════════════════════════════════════════════════


-- ── 1. TABLES ──────────────────────────────────────────────────────────────

create table if not exists public.products (
  id          text primary key,
  name        text not null,
  category    text not null,
  badge       text default 'Handcrafted',
  price       numeric,                          -- null = "Contact for price"
  type        text not null default 'bag' check (type in ('bag','rug')),
  description text,
  long_desc   text,
  features    jsonb default '[]'::jsonb,
  details     jsonb default '{}'::jsonb,
  images      jsonb default '[]'::jsonb,        -- array of URL strings
  active      boolean default true,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table if not exists public.reviews (
  id            uuid primary key default gen_random_uuid(),
  product_id    text references public.products(id) on delete cascade,
  reviewer_name text not null,
  rating        integer not null check (rating between 1 and 5),
  body          text not null,
  created_at    timestamptz default now()
);

create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  name       text,
  role       text default 'Admin',
  created_at timestamptz default now()
);

create table if not exists public.orders (
  id           serial primary key,
  product_id   text references public.products(id),
  product_name text,
  customer_name text,
  amount       numeric,
  status       text default 'completed',
  created_at   timestamptz default now()
);


-- ── 2. AUTO-CREATE PROFILE ON SIGNUP ──────────────────────────────────────

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1)),
    coalesce(new.raw_user_meta_data->>'role', 'Admin')
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ── 3. ROW LEVEL SECURITY ──────────────────────────────────────────────────

alter table public.products enable row level security;
alter table public.reviews  enable row level security;
alter table public.profiles enable row level security;
alter table public.orders   enable row level security;

-- Products: everyone can read; only logged-in admins can write
drop policy if exists "products_select" on public.products;
drop policy if exists "products_write"  on public.products;
create policy "products_select" on public.products for select using (true);
create policy "products_write"  on public.products for all   using (auth.role() = 'authenticated');

-- Reviews: everyone can read and submit; only admins can delete
drop policy if exists "reviews_select" on public.reviews;
drop policy if exists "reviews_insert" on public.reviews;
drop policy if exists "reviews_delete" on public.reviews;
create policy "reviews_select" on public.reviews for select using (true);
create policy "reviews_insert" on public.reviews for insert with check (true);
create policy "reviews_delete" on public.reviews for delete using (auth.role() = 'authenticated');

-- Profiles: only admins can see and edit
drop policy if exists "profiles_select" on public.profiles;
drop policy if exists "profiles_write"  on public.profiles;
create policy "profiles_select" on public.profiles for select using (auth.role() = 'authenticated');
create policy "profiles_write"  on public.profiles for all   using (auth.role() = 'authenticated');

-- Orders: admins only
drop policy if exists "orders_all" on public.orders;
create policy "orders_all" on public.orders for all using (auth.role() = 'authenticated');


-- ── 4. STORAGE BUCKET ──────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

drop policy if exists "pi_select" on storage.objects;
drop policy if exists "pi_write"  on storage.objects;
create policy "pi_select" on storage.objects for select using (bucket_id = 'product-images');
create policy "pi_write"  on storage.objects for all
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');


-- ── 5. SEED PRODUCTS ───────────────────────────────────────────────────────

insert into public.products
  (id, name, category, badge, price, type, description, long_desc, features, details, images, active)
values
(
  'ostrich-backpack', 'Ostrich Leather Backpack', 'Ostrich Leather',
  'Bestseller', 4850, 'bag',
  'A masterwork of artisan craft — this backpack is fashioned from premium ostrich leather sourced from the Karoo region.',
  'Ostrich leather is among the most durable and supple leathers in the world. This backpack features a padded laptop sleeve, two interior pockets, and adjustable shoulder straps lined with nubuck.',
  '["Padded 15\" laptop sleeve","Exterior zip pocket","Brass hardware","Water-resistant treatment","Lifetime craftsman guarantee"]',
  '{"Material":"Full-grain ostrich leather","Lining":"Suede microfibre","Dimensions":"38 × 28 × 14 cm","Closure":"YKK brass zip","Origin":"Handcrafted in South Africa"}',
  '["images/Ostrich Leather Backpack.jpeg","images/Ostrich Leather Bag.jpeg","images/Ostrich Bag.jpeg"]',
  true
),(
  'ostrich-tan', 'Classic Tan Ostrich Bag', 'Ostrich Leather',
  'Handcrafted', 3200, 'bag',
  'A classic structured tote in warm tan ostrich leather.',
  'Hand-stitched by master leather artisans, this tote showcases the full beauty of ostrich hide. The warm tan tone complements a wide range of outfits.',
  '["Detachable wrist strap","Interior zip pocket","Antique gold hardware","Dust bag included","Certificate of authenticity"]',
  '{"Material":"Ostrich leg leather","Lining":"Cotton sateen","Dimensions":"34 × 24 × 12 cm","Closure":"Magnetic snap","Origin":"Handcrafted in South Africa"}',
  '["images/Ostrich Bag.jpeg","images/Ostrich Leather Backpack.jpeg","images/Ladies Ostrich Bag.jpeg"]',
  true
),(
  'eva-clutch', 'Eva Ladies Clutch', 'Ostrich Leather',
  'Limited Edition', 1950, 'bag',
  'The Eva clutch is a statement piece crafted from lustrous ostrich leather.',
  'Part of our limited Eva collection, finished by hand with silk lining and a polished turn-lock clasp.',
  '["Chain strap included","Silk lining","Limited edition number stamped inside","Gift box packaging","Artisan signature tag"]',
  '{"Material":"Full-grain ostrich leather","Lining":"Silk charmeuse","Dimensions":"28 × 14 × 3 cm","Closure":"Turn-lock clasp","Origin":"Handcrafted in South Africa"}',
  '["images/Ladies Ostrich Bag.jpeg","images/Ostrich Bag.jpeg","images/Ostrich Leather Bag.jpeg"]',
  true
),(
  'ostrich-navy', 'Navy Structured Tote', 'Ostrich Leather',
  'Handcrafted', 2750, 'bag',
  'The deep navy finish gives this structured tote an understated luxury.',
  'Custom-dyed in a proprietary navy tone that maintains the natural texture of the ostrich quill pattern.',
  '["Base structure insert","Interior card slots","Sterling silver hardware","Shoulder strap + handles","Protective leather feet"]',
  '{"Material":"Dyed ostrich leather","Lining":"Alcantara microsuede","Dimensions":"36 × 26 × 14 cm","Closure":"Top zip with tassel","Origin":"Handcrafted in South Africa"}',
  '["images/Ostrich Leather Bag.jpeg","images/Ostrich Leather Backpack.jpeg","images/Ostrich Bag.jpeg"]',
  true
),(
  'wildebeest-rug', 'Black Wildebeest Hide Rug', 'Animal Hide Rugs',
  'Contact for Price', null, 'rug',
  'A magnificent black wildebeest hide, ethically sourced from game reserves during regulated conservation culling.',
  'Each hide is individually selected for quality. The deep black and brown tones bring drama and warmth to any space.',
  '["Unique one-of-a-kind piece","Professionally tanned & finished","Naturally hypoallergenic","Suitable for floors & walls","Pest-resistant treatment"]',
  '{"Hide Type":"Black wildebeest","Average Size":"180 × 140 cm","Treatment":"Chrome-tanned & hand-finished","Backing":"Optional felt backing","Sourcing":"Ethical game management"}',
  '["images/black-wildebeest-rug.png","images/Eland-Rug.png"]',
  true
),(
  'eland-rug', 'Eland Hide Rug', 'Animal Hide Rugs',
  'Contact for Price', null, 'rug',
  'The eland is the largest antelope on earth, and its hide is correspondingly grand.',
  'Larger than most bovine hides, an eland rug fills a room with presence. Our artisans treat every hide with traditional methods that preserve its natural character.',
  '["One of the largest hide rugs available","Natural tawny & ochre tones","Tannin-cured for longevity","Suitable for high-traffic areas","Can be custom-trimmed to shape"]',
  '{"Hide Type":"Common eland","Average Size":"220 × 160 cm","Treatment":"Vegetable-tanned & oil-dressed","Backing":"Optional felt backing","Sourcing":"Ethical game management"}',
  '["images/Eland-Rug.png","images/black-wildebeest-rug.png"]',
  true
)
on conflict (id) do nothing;


-- ── 6. SEED SAMPLE ORDERS (for dashboard charts) ──────────────────────────

insert into public.orders (product_id, product_name, customer_name, amount, status, created_at) values
('ostrich-backpack','Ostrich Leather Backpack','Nomvula Dlamini',  4850,'completed','2025-04-27'),
('eva-clutch',      'Eva Ladies Clutch',       'Lerato Sithole',   1950,'completed','2025-04-26'),
('wildebeest-rug',  'Black Wildebeest Rug',    'James Kruger',     6200,'completed','2025-04-25'),
('ostrich-navy',    'Navy Structured Tote',    'Ayesha Patel',     2750,'pending',  '2025-04-24'),
('ostrich-tan',     'Classic Tan Ostrich Bag', 'Thabo Mokoena',    3200,'completed','2025-04-23'),
('ostrich-backpack','Ostrich Leather Backpack','Sarah van Wyk',    4850,'completed','2025-03-28'),
('eva-clutch',      'Eva Ladies Clutch',       'Priya Naidoo',     1950,'completed','2025-03-20'),
('eland-rug',       'Eland Hide Rug',          'Brendan Jacobs',   7375,'completed','2025-03-15'),
('ostrich-tan',     'Classic Tan Ostrich Bag', 'Zanele Khumalo',   3200,'completed','2025-02-18'),
('ostrich-navy',    'Navy Structured Tote',    'Marc Liebenberg',  2750,'completed','2025-02-10'),
('ostrich-backpack','Ostrich Leather Backpack','Fatima Adams',     4850,'completed','2025-01-22'),
('wildebeest-rug',  'Black Wildebeest Rug',    'David Steenkamp',  6200,'completed','2025-01-14')
on conflict do nothing;


-- ═══════════════════════════════════════════════════════════════════════════
-- DONE! Next steps:
-- 1. Go to Authentication → Settings → disable "Confirm email" (for local admin invites)
-- 2. Go to Authentication → Users → Add User → set your email + password
-- 3. Update supabase-config.js with your Project URL and anon key
-- ═══════════════════════════════════════════════════════════════════════════
