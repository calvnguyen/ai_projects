-- =============================================================================
-- seed.sql — local development seed data
-- -----------------------------------------------------------------------------
-- Runs automatically after migrations on `supabase db reset` and `supabase start`.
-- Use ONLY for local/dev data. Never put real or sensitive data here, and never
-- run seed against production.
--
-- NOTE on auth users: you generally can't insert into auth.users with plain SQL
-- and get a working password. For seeded *logins*, create users via the CLI/API
-- after start (see below) OR use Studio → Authentication → Add user.
--
-- Quick way to create a confirmed test user from the terminal:
--   curl -s http://127.0.0.1:54321/auth/v1/admin/users \
--     -H "apikey: <service_role_key>" \
--     -H "Authorization: Bearer <service_role_key>" \
--     -H "Content-Type: application/json" \
--     -d '{"email":"demo@example.com","password":"password123","email_confirm":true}'
-- =============================================================================

-- The block below seeds domain data tied to whatever auth users exist.
-- It is written defensively so `db reset` won't fail on an empty auth.users.

do $$
declare
  demo_user uuid;
  camper_id uuid;
begin
  -- Grab the first existing auth user, if any.
  select id into demo_user from auth.users limit 1;

  if demo_user is null then
    raise notice 'No auth users found — skipping domain seed. Create a user, then re-run db reset.';
    return;
  end if;

  -- Ensure a profile exists (the trigger normally handles this).
  insert into public.profiles (id, username, full_name)
  values (demo_user, 'demo', 'Demo User')
  on conflict (id) do nothing;

  -- Seed a couple of campers.
  insert into public.campers (owner_id, name, description, price_per_night, is_published)
  values
    (demo_user, 'Aspen Glamper', 'Cozy off-grid camper near the lake.', 120.00, true),
    (demo_user, 'Desert Rover',  'Solar-powered van for desert trips.', 95.50, true)
  returning id into camper_id;

  raise notice 'Seeded profile + campers for user %', demo_user;
end $$;
