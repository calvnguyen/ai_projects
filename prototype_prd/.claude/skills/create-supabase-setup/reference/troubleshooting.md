# Troubleshooting (Docker + Supabase)

## Quick diagnostics

```bash
docker info                 # is Docker actually running?
supabase status             # are the local services up? what are the URLs/keys?
docker ps                   # list running containers (supabase_* names)
supabase stop && supabase start   # the "turn it off and on again" reset
```

---

## Docker issues

**`Cannot connect to the Docker daemon` / `docker: command not found`**
Docker Desktop isn't running (or isn't installed). Launch it: `open -a Docker`, wait for the whale icon to stop animating, then retry. Install with `brew install --cask docker`.

**`supabase start` hangs or times out on first run**
It's pulling several GB of images. Give it time on first run; check progress with `docker ps`. If it stalls, ensure Docker Desktop has enough resources (Settings → Resources → at least 4 GB RAM, ideally 8) and a stable network.

**Port already in use (`54321/54322/54323` bind error)**
Another process (or a previous Supabase run) holds the port. `supabase stop`, or find it: `lsof -i :54322`. You can also change ports in `supabase/config.toml`.

**Apple Silicon image / platform warnings**
Recent Supabase images are multi-arch; update the CLI (`brew upgrade supabase`) and Docker Desktop. If a single image refuses to run, `supabase stop --no-backup` then `supabase start` to re-pull.

**Out of disk space / weird container state**
Reclaim space: `docker system prune` (removes stopped containers and dangling images — safe) or `docker volume prune` (deletes volumes — **destroys local DB data**; only when you mean it).

---

## Supabase CLI / database issues

**`supabase: command not found`**
Install it: `brew install supabase/tap/supabase`. Don't `npm install -g supabase` (unsupported) — use Homebrew or `npx supabase`.

**`supabase db reset` fails midway**
A migration has a SQL error, or migrations are out of order. Read the error — it names the file and line. Fix the offending migration, then reset again. Remember reset runs the **whole chain** from scratch, so an earlier broken migration blocks everything after it.

**`seed.sql` errors on reset**
Often because it references an auth user that doesn't exist yet. The provided `seed.sql` guards against an empty `auth.users`. Create a user first (Studio → Authentication, or the admin API curl in `seed.sql`), then reset.

**Migration applied locally but `db push` says "already exists" on hosted**
Local and hosted have drifted. Compare with `supabase migration list`. Don't edit old migrations — write a new one that reconciles, or repair the migration history with `supabase migration repair` (read the docs first).

---

## App / query issues

**Queries return empty arrays but data exists in Studio**
Almost always **RLS**. With RLS on and no matching policy, reads return `[]` (not an error). Check: is RLS on? Is there a `select` policy that matches the current user? Is the user even authenticated (`auth.uid()` is null when logged out)? Test by temporarily querying in Studio's SQL editor (runs as service_role and ignores RLS) to confirm the data is there.

**`new row violates row-level security policy`**
Your `insert`/`update` has no matching `with check` policy, or the row's `owner_id`/`uid` doesn't equal `auth.uid()`. Make sure you're authenticated and that the inserted ownership column matches the logged-in user.

**Auth works then user gets logged out randomly**
The session cookie isn't being refreshed. Confirm `middleware.ts` exists at the right location and its `matcher` covers your routes, and that you call `getUser()` (not `getSession()`) inside it.

**`Invalid API key` / 401 from the client**
Wrong or stale env values. Re-run `supabase status`, copy the current `anon key` into `.env.local`, and restart `npm run dev` (Next.js only reads env at boot).

**Types are out of date / TS errors on real columns**
Regenerate after every schema change: `supabase gen types typescript --local > src/lib/database.types.ts`. Make sure the client is created with the generic: `createClient<Database>()`.

**OAuth / email redirect fails**
The redirect URL isn't allow-listed. Locally, add it to `supabase/config.toml` (`additional_redirect_urls`); on hosted, add it under Authentication → URL Configuration. Confirmation emails locally land in **Inbucket** at http://127.0.0.1:54324, not a real inbox.

---

## When stuck, gather this before asking for help

```bash
supabase --version
docker --version
supabase status
docker ps
```

Plus the exact error text and the migration/file it points to. For local
service logs, open Studio (http://127.0.0.1:54323) → Logs, or `docker logs <container>`.
