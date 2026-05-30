# Best practices — architecture, structure, conventions

## Architecture patterns for MVPs

- **Default to "thin server, fat database."** Push data rules into Postgres: constraints, foreign keys, `check`s, and RLS. The DB is the last line of defense and works no matter which client calls it.
- **Two trust tiers:**
  - *User-scoped* (anon key + RLS) for anything triggered by a logged-in user. This is 90% of your code.
  - *Privileged* (service_role, RLS-bypassing) only in trusted server code: webhooks, cron, admin tools. Keep it in one clearly-named module.
- **Server Components read; Server Actions / Route Handlers write.** Fetch data in Server Components for speed and to keep keys off the client; mutate via Server Actions so validation runs server-side.
- **Edge functions / Postgres functions** for logic that must run close to the data or be callable from SQL (e.g. an RPC that does a transactional booking). Expose via `supabase.rpc('fn_name', args)`.
- **Realtime** for live updates (presence, chat, dashboards): subscribe on the client with `supabase.channel(...)`. Don't reach for it until you actually need push.

## When to use hosted vs local (recap)

Develop on **local Docker** (fast, offline, resettable). Use **hosted** for staging,
production, and anything teammates/clients need to reach. Promote via migrations.
See `deployment.md`.

## Recommended folder structure (Next.js + Supabase MVP)

```
your-app/
├── supabase/
│   ├── config.toml
│   ├── migrations/          # timestamped SQL — the source of truth for schema
│   └── seed.sql             # local-only seed data
├── src/
│   ├── app/                 # App Router routes
│   │   ├── (auth)/login/    # auth route group
│   │   ├── auth/callback/route.ts
│   │   ├── dashboard/
│   │   └── ...
│   ├── components/          # UI components (presentational)
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts    # browser client
│   │   │   ├── server.ts    # server client (+ admin client)
│   │   │   └── auth-actions.ts
│   │   ├── database.types.ts # GENERATED — do not hand-edit
│   │   └── queries/         # data-access layer (see below)
│   └── middleware.ts        # session refresh (project root or src/)
├── .env.local               # git-ignored
└── .env.example             # committed, documented
```

### Data-access layer for MVP startups

Keep Supabase queries out of components. Put typed functions in `src/lib/queries/`:

```ts
// src/lib/queries/campers.ts
import { createClient } from '@/lib/supabase/server'
import type { Database } from '@/lib/database.types'

export type Camper = Database['public']['Tables']['campers']['Row']

export async function getPublishedCampers(): Promise<Camper[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('campers')
    .select('*')
    .eq('is_published', true)
    .order('created_at', { ascending: false })
  if (error) throw error
  return data
}
```

Benefits: one place to change a query, easy to test, and Claude can reason about
your data access without scanning every component. This is a lightweight
"repository" pattern — enough structure for an MVP without over-engineering.

## Naming conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Tables | `snake_case`, plural | `bookings`, `camper_reviews` |
| Columns | `snake_case` | `price_per_night`, `created_at` |
| Primary key | `id` (uuid) | `id uuid primary key` |
| Foreign key | `<singular>_id` | `owner_id`, `camper_id` |
| Timestamps | `created_at`, `updated_at` (timestamptz) | |
| Booleans | `is_`/`has_` prefix | `is_published` |
| Indexes | `<table>_<cols>_idx` | `campers_owner_id_idx` |
| Migrations | `<timestamp>_<verb>_<thing>` | `..._add_reviews_table` |
| RLS policies | full-sentence description | `"Owners can update their own campers"` |

## Performance considerations

- **Index foreign keys and filter/sort columns.** Unindexed `where`/`order by` on growing tables is the classic slowdown.
- **Select only what you need:** `.select('id, name')` not `.select('*')` on wide tables.
- **Avoid N+1:** use Supabase's nested selects to join in one round trip — `.select('*, campers(name)')`.
- **Paginate** large lists with `.range(from, to)` instead of fetching everything.
- **Keep RLS policy expressions cheap.** Wrap repeated `auth.uid()` calls as `(select auth.uid())` so Postgres caches them per-statement; avoid correlated subqueries in hot policies.
- **Connection pooling:** for serverless (Vercel) use the pooled connection string (Supavisor, port 6543) for direct Postgres connections; the PostgREST API handles pooling for you.

## Security best practices

1. **RLS on every table**, reviewed policies, deny-by-default mindset.
2. **service_role key server-only.** Never `NEXT_PUBLIC_`, never client-imported, rotate if leaked.
3. **Validate on the server**, not just the client — Server Actions / Route Handlers re-check input even though the UI already did.
4. **Use `getUser()` server-side** for authorization (it verifies the JWT).
5. **Least privilege:** expose the minimum via views/policies; don't surface internal columns.
6. **Don't trust client-sent ownership:** set `owner_id`/`guest_id` from `auth.uid()` server-side or enforce it in `with check`, never from a form field the user controls.
7. **Secrets out of git and out of chat.** `.env.local` is ignored; reference secrets by name.

## Recommended VS Code extensions

- **Supabase** (official) — schema browser, types, snippets.
- **Prisma / PostgreSQL** (e.g. `mtxr.sqltools` + `sqltools-driver-pg`) — run SQL against the local DB from the editor.
- **ESLint** + **Prettier** — consistent code.
- **Tailwind CSS IntelliSense** — class autocomplete.
- **DotENV** — `.env` syntax highlighting.
- **Error Lens** — inline TS/RLS-call errors.

## Recommended package set

```bash
npm install @supabase/supabase-js @supabase/ssr
npm install -D supabase            # optional: pin the CLI per-project via npx
```
