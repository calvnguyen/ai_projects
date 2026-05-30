-- =============================================================================
-- schema.sql — EXAMPLE schema for an MVP (adapt to your domain)
-- -----------------------------------------------------------------------------
-- This is a reference, not a fixed schema. It shows the patterns you want in
-- every Supabase project:
--   1. A `profiles` table mirroring auth.users (1:1), populated by a trigger.
--   2. A domain table (`campers`) owned by a user.
--   3. A join/transaction table (`bookings`).
--   4. updated_at maintained by a trigger.
--   5. RLS enabled on every table (policies live in the RLS migration).
--
-- Conventions used:
--   - snake_case table & column names, plural table names.
--   - uuid primary keys with gen_random_uuid().
--   - timestamptz for all timestamps, default now().
--   - foreign keys to auth.users(id) for ownership.
-- =============================================================================

-- Reusable trigger function: keep updated_at fresh on UPDATE.
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- profiles: public user data, 1:1 with auth.users.
-- NEVER expose auth.users directly; mirror the bits you need here.
-- -----------------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique,
  full_name   text,
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.handle_updated_at();

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- campers: example domain table, owned by a user.
-- -----------------------------------------------------------------------------
create table public.campers (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  price_per_night numeric(10,2) not null default 0 check (price_per_night >= 0),
  is_published boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index campers_owner_id_idx on public.campers (owner_id);
create index campers_is_published_idx on public.campers (is_published) where is_published;

create trigger campers_updated_at
  before update on public.campers
  for each row execute function public.handle_updated_at();

-- -----------------------------------------------------------------------------
-- bookings: example transaction table linking a guest to a camper.
-- -----------------------------------------------------------------------------
create table public.bookings (
  id          uuid primary key default gen_random_uuid(),
  camper_id   uuid not null references public.campers(id) on delete cascade,
  guest_id    uuid not null references auth.users(id) on delete cascade,
  start_date  date not null,
  end_date    date not null,
  status      text not null default 'pending'
                check (status in ('pending', 'confirmed', 'cancelled')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  check (end_date > start_date)
);

create index bookings_camper_id_idx on public.bookings (camper_id);
create index bookings_guest_id_idx on public.bookings (guest_id);

create trigger bookings_updated_at
  before update on public.bookings
  for each row execute function public.handle_updated_at();

-- Enable RLS on everything. Policies are defined in the RLS migration.
alter table public.profiles enable row level security;
alter table public.campers  enable row level security;
alter table public.bookings enable row level security;
