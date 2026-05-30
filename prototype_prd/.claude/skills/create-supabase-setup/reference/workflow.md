# Recommended workflow

## Daily development loop

```
supabase start                 # once per work session (idempotent)
# ...edit code, write SQL migrations...
supabase db reset              # rebuild DB whenever migrations/seed change
supabase gen types typescript --local > src/lib/database.types.ts
npm run dev                    # build the frontend against local data
supabase stop                  # end of session (keeps data unless --no-backup)
```

Keep **Studio open** at http://127.0.0.1:54323 — table editor, SQL editor, auth users, logs, and storage all live there.

## Migration strategy

The schema is **code**. Two ways to author changes, pick one and be consistent:

### A. SQL-first (recommended, AI-friendly)
1. `supabase migration new add_reviews_table`
2. Write the SQL by hand (or have Claude write it) in the new file.
3. `supabase db reset` to apply locally and verify.
4. Commit the migration file.

### B. Studio-first, then capture
1. Make changes in Studio's table editor.
2. `supabase db diff -f add_reviews_table` to capture the diff as a migration.
3. Review the generated SQL, `supabase db reset` to confirm it reproduces cleanly.
4. Commit.

**Rules:**
- Migrations are **append-only** and **immutable once pushed**. Never edit a migration that's already been applied to a shared/hosted DB — write a new one.
- One logical change per migration. Name them descriptively: `add_reviews_table`, `add_status_to_bookings`, `create_storage_avatars_bucket`.
- Always `db reset` before committing to prove the full chain replays from scratch.
- After **every** schema change, regenerate types so the frontend stays type-safe.

## Promoting changes to hosted (staging/prod)

```
supabase link --project-ref <ref>   # one-time per project
supabase db push                    # applies new local migrations to hosted
```

Never hand-edit the hosted schema in the dashboard for anything you want reproducible — drift between local and hosted is the #1 source of "works on my machine" bugs. See `deployment.md`.

## Recommended Claude Code workflow (AI-assisted full-stack)

This skill is built to make Claude an effective pair on Supabase work. Patterns that work well:

- **Schema changes:** "Add a `reviews` table (camper_id, author_id, rating 1–5, body, timestamps) with RLS so anyone can read but only the author can write. Create the migration and the RLS policies, then run `db reset` and regenerate types." Claude can write the migration, apply it, and update types in one loop.
- **Type-safe queries:** Because `database.types.ts` is generated and the client is typed (`createClient<Database>()`), Claude gets autocomplete-grade signal on table/column names and will catch mismatches.
- **RLS reasoning:** Ask Claude to "explain who can read/write each row under these policies" before shipping — RLS bugs are silent and security-critical.
- **Seed + verify:** After a schema change, have Claude update `seed.sql` and a quick query in a Server Component to confirm the data flows end to end.
- **Keep secrets out of context:** Don't paste `service_role` keys or `.env.local` contents into the chat. Reference them by name; Claude reads them from `process.env` in code, not from the conversation.
- **Commit discipline:** Ask Claude to keep each migration + its type regeneration in a focused commit so the schema history is readable.

## Common mistakes beginners make

1. **Forgetting RLS.** A table with no policies and RLS on returns *empty* — people think their query is broken when access is just denied. Conversely, RLS *off* exposes everything to the anon key.
2. **Leaking the service_role key.** Prefixing it with `NEXT_PUBLIC_` or importing the admin client into a Client Component ships a root key to the browser. Server-only, always.
3. **Editing applied migrations.** Changing a migration that already ran on hosted causes drift and failed pushes. Add a new migration instead.
4. **Not regenerating types.** The frontend silently goes stale; you get runtime errors the compiler should have caught.
5. **Developing against production.** Slow, dangerous, and pollutes real data. Develop local, push migrations up.
6. **Using `getSession()` for auth decisions on the server.** Use `getUser()` server-side — it revalidates the token with the auth server. `getSession()` reads the cookie without verifying.
7. **Putting business secrets in `NEXT_PUBLIC_` vars.** Anything `NEXT_PUBLIC_` is in the browser bundle. Only the URL and anon key belong there.
8. **Skipping `supabase db reset` before committing.** You commit a migration chain that doesn't actually replay cleanly.
