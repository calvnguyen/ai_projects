-- =============================================================================
-- Migration: 20240101000001_rls_policies
-- Row Level Security policies.
-- -----------------------------------------------------------------------------
-- KEY MENTAL MODEL:
--   * RLS is enabled per-table (done in the init migration).
--   * With RLS ON and NO policy, the table denies all access to anon/auth roles.
--   * Each policy grants access for a specific command (select/insert/update/delete).
--   * `auth.uid()` returns the id of the currently authenticated user (or null).
--   * `to authenticated` / `to anon` scope a policy to a role.
--   * USING (...)  → which existing rows the user may read/affect.
--   * WITH CHECK (...) → which new/updated row values are allowed to be written.
--   * The service_role key BYPASSES all of this — server-side only.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- profiles
-- -----------------------------------------------------------------------------
-- Anyone (even logged-out) can read profiles (public directory).
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

-- A user can insert their own profile row (id must equal their uid).
create policy "Users can insert their own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- A user can update only their own profile.
create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- -----------------------------------------------------------------------------
-- campers
-- -----------------------------------------------------------------------------
-- Published campers are visible to everyone; owners always see their own.
create policy "Published campers are viewable by everyone"
  on public.campers for select
  using (is_published = true or auth.uid() = owner_id);

-- Owners can create campers they own.
create policy "Owners can insert their own campers"
  on public.campers for insert
  to authenticated
  with check (auth.uid() = owner_id);

-- Owners can update their own campers.
create policy "Owners can update their own campers"
  on public.campers for update
  to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- Owners can delete their own campers.
create policy "Owners can delete their own campers"
  on public.campers for delete
  to authenticated
  using (auth.uid() = owner_id);

-- -----------------------------------------------------------------------------
-- bookings
-- -----------------------------------------------------------------------------
-- A booking is visible to the guest who made it OR the owner of the camper.
create policy "Bookings visible to guest and camper owner"
  on public.bookings for select
  to authenticated
  using (
    auth.uid() = guest_id
    or auth.uid() = (select owner_id from public.campers where id = camper_id)
  );

-- Guests can create bookings for themselves.
create policy "Guests can create their own bookings"
  on public.bookings for insert
  to authenticated
  with check (auth.uid() = guest_id);

-- Guests can update (e.g. cancel) their own bookings;
-- camper owners can update bookings on their campers (e.g. confirm).
create policy "Guest or owner can update a booking"
  on public.bookings for update
  to authenticated
  using (
    auth.uid() = guest_id
    or auth.uid() = (select owner_id from public.campers where id = camper_id)
  )
  with check (
    auth.uid() = guest_id
    or auth.uid() = (select owner_id from public.campers where id = camper_id)
  );
