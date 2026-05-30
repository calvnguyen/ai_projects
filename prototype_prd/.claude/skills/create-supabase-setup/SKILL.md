---
name: create-supabase-setup
description: Bootstrap and manage a local-first Supabase backend with Docker for modern web app MVPs (React/Next.js + TypeScript + Tailwind). Use when setting up Supabase, scaffolding auth/database/storage, writing migrations or RLS policies, generating TypeScript types, seeding a local database, or deploying to hosted Supabase. Optimized for AI-assisted coding with Claude Code on macOS.
---

# Create Supabase Setup

A practical, production-oriented playbook for standing up a **local-first Supabase backend** with Docker and wiring it into a **Next.js + React + TypeScript + Tailwind** frontend. Built for MVP startups and AI-assisted development with Claude Code.

## What this skill gives you

- A **Quick Start** that goes zero → running backend in under 15 minutes.
- Copy-paste terminal commands for the full lifecycle (install → init → migrate → seed → types → deploy).
- Reusable templates: `docker-compose.yml`, `.env.example`, `schema.sql`, `seed.sql`, migrations, RLS policies, and Next.js client helpers.
- Reference docs for workflow, auth, deployment, best practices, and troubleshooting.

## How to use this skill

When a user asks to set up or extend a Supabase backend:

1. **Confirm the target directory** and whether it's an existing Next.js app or a fresh project.
2. **Run the Quick Start** below, copying templates from `templates/` and scripts from `scripts/` into the project.
3. **Adapt templates** to the user's schema — don't paste them verbatim if the domain differs. Treat `schema.sql` / `seed.sql` as examples.
4. **Pull in reference docs only when needed** (progressive disclosure):
   - `reference/workflow.md` — recommended day-to-day developer workflow, migration strategy, Claude Code workflow, common beginner mistakes.
   - `reference/auth.md` — auth/session management, example auth flow, RLS-aware patterns.
   - `reference/deployment.md` — linking to hosted Supabase, pushing migrations, production notes, secrets.
   - `reference/best-practices.md` — architecture patterns, repo structure, naming conventions, performance, security, VS Code extensions.
   - `reference/troubleshooting.md` — Docker/Supabase debugging.

Default to the **local Docker stack for development**; use **hosted Supabase for staging/production**. See "Local vs hosted" below.

### Portability & reuse

This skill is **project-agnostic** — nothing in it is tied to a specific app or domain.

- **Reuse across projects:** copy this `create-supabase-setup/` folder into any project's `.claude/skills/`, or drop it in `~/.claude/skills/` to make it available in *every* project on your machine.
- **The templates are starting points, not fixtures.** `schema.sql`, `seed.sql`, and the `migrations/` examples model a sample domain (`profiles` + `campers` + `bookings`) purely to demonstrate the patterns (ownership, RLS, triggers, joins). Replace the domain tables with the user's own; keep the `profiles` + trigger + RLS scaffolding, which applies to almost any app.
- **The Next.js helpers (`templates/nextjs/`) are domain-free** and drop into any Next.js App Router project unchanged.

---

## Quick Start (zero → running backend in < 15 min)

> Assumes macOS. The Supabase CLI runs a full local stack in Docker — Postgres, Auth (GoTrue), Storage, Realtime, the REST API (PostgREST), and Studio.

### 1. Install prerequisites (one-time)

```bash
# Docker Desktop (the local stack runs in containers)
brew install --cask docker
open -a Docker            # launch it once and wait for the whale icon to settle

# Supabase CLI (do NOT install globally with npm — use Homebrew or npx)
brew install supabase/tap/supabase

# Verify
docker --version
supabase --version
```

If you don't use Homebrew, install Docker Desktop from https://www.docker.com/products/docker-desktop and the CLI via `npx supabase`.

### 2. Initialize Supabase in your project

```bash
cd your-nextjs-app          # or: npx create-next-app@latest your-app --ts --tailwind --app
supabase init               # creates ./supabase/ (config.toml, migrations/, seed.sql)
```

### 3. Start the local stack

```bash
supabase start              # first run pulls images (~a few minutes); later runs are fast
```

When it finishes it prints your local credentials. Copy them — you'll need `API URL`, `anon key`, and `service_role key`:

```
         API URL: http://127.0.0.1:54321
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
        anon key: eyJhbGc...
service_role key: eyJhbGc...
```

Re-print these any time with `supabase status`.

### 4. Wire up environment variables

Copy `templates/.env.example` to `.env.local` and fill in the values from step 3:

```bash
cp .claude/skills/create-supabase-setup/templates/.env.example .env.local
```

```bash
# .env.local  (local development — git-ignored)
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...        # anon key from `supabase status`
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...            # server-only — NEVER expose to the browser
```

### 5. Create your first migration

```bash
supabase migration new init
# edit the new file in supabase/migrations/ — see templates/schema.sql for a worked example
supabase db reset           # drops, recreates, runs ALL migrations, then runs seed.sql
```

Use `templates/schema.sql` and `templates/migrations/` as starting points (profiles + a sample domain table with RLS).

### 6. Generate TypeScript types

```bash
supabase gen types typescript --local > src/lib/database.types.ts
```

### 7. Install the client libraries and connect from Next.js

```bash
npm install @supabase/supabase-js @supabase/ssr
```

Copy the Next.js helpers from `templates/nextjs/` into `src/lib/supabase/`:

- `client.ts` — browser client (Client Components)
- `server.ts` — server client (Server Components, Route Handlers, Server Actions)
- `middleware.ts` — refreshes the auth session cookie on every request

```ts
// Example: a Server Component reading data
import { createClient } from '@/lib/supabase/server'

export default async function Page() {
  const supabase = await createClient()
  const { data: campers } = await supabase.from('campers').select('*')
  return <pre>{JSON.stringify(campers, null, 2)}</pre>
}
```

### 8. Run the app

```bash
npm run dev                 # http://localhost:3000
# Studio (DB GUI, table editor, SQL editor): http://127.0.0.1:54323
```

You now have a running backend. Add the npm scripts from `templates/package-scripts.json` to make the loop ergonomic (`npm run db:reset`, `npm run db:types`, etc.).

To stop: `supabase stop` (add `--no-backup` to discard local data).

---

## Local vs hosted Supabase — when to use which

| | **Local (Docker)** | **Hosted (supabase.com)** |
|---|---|---|
| Use for | Day-to-day development, tests, CI | Staging, production, sharing with teammates/clients |
| Cost | Free | Free tier → paid |
| Speed | Instant, offline, resettable | Network latency, shared state |
| Data | Disposable, seeded | Real, persistent |
| Secrets | Throwaway local keys | Real keys — guard carefully |

**Rule of thumb:** develop and test against local; promote schema changes to hosted via migrations (`supabase db push`). Never develop directly against production. See `reference/deployment.md`.

---

## Files in this skill

```
create-supabase-setup/
├── SKILL.md                          ← you are here
├── scripts/
│   ├── bootstrap.sh                  ← one-shot: install deps, init, start, seed
│   └── reset-db.sh                   ← reset DB + regenerate types
├── templates/
│   ├── .env.example                  ← all env vars, documented
│   ├── docker-compose.yml            ← optional self-hosted stack (advanced)
│   ├── schema.sql                    ← example tables (profiles, campers, bookings)
│   ├── seed.sql                      ← example seed data
│   ├── package-scripts.json          ← npm scripts to merge into package.json
│   ├── migrations/
│   │   ├── 20240101000000_init.sql           ← tables + triggers
│   │   └── 20240101000001_rls_policies.sql   ← RLS enable + policies
│   └── nextjs/
│       ├── client.ts                 ← browser Supabase client
│       ├── server.ts                 ← server Supabase client (@supabase/ssr)
│       ├── middleware.ts             ← session refresh middleware
│       └── auth-actions.ts           ← example sign-up/in/out Server Actions
└── reference/
    ├── workflow.md                   ← dev loop, migration strategy, Claude workflow, mistakes
    ├── auth.md                       ← auth/session management + example flow
    ├── deployment.md                 ← hosted deploy, secrets, prod notes
    ├── best-practices.md             ← architecture, repo structure, naming, perf, security
    └── troubleshooting.md            ← Docker/Supabase debugging
```

## Most-used commands (cheat sheet)

```bash
supabase start                  # start local stack
supabase stop                   # stop (keeps data); add --no-backup to wipe
supabase status                 # show URLs + keys
supabase migration new <name>   # scaffold a new migration
supabase db reset               # rebuild local DB from migrations + seed
supabase db diff -f <name>      # capture Studio/manual changes as a migration
supabase gen types typescript --local > src/lib/database.types.ts
supabase link --project-ref <ref>   # connect CLI to a hosted project
supabase db push                # apply local migrations to the linked hosted DB
```

## Golden rules

1. **The `service_role` key bypasses RLS.** Server-side only, never `NEXT_PUBLIC_*`, never in the browser bundle.
2. **Every table gets RLS.** Enable RLS and add explicit policies — a table with RLS on and no policy denies all access by default.
3. **Schema changes are migrations, not clicks.** Make changes via SQL migrations (or capture Studio changes with `supabase db diff`) so they're reproducible and reviewable.
4. **Regenerate types after every schema change.** Keep `database.types.ts` in sync so the frontend is type-safe.
5. **Develop local, deploy via migrations.** Local Docker is the workbench; hosted is the destination.
