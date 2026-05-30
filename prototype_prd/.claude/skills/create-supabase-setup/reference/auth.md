# Authentication & session management

Supabase Auth (GoTrue) issues JWTs. In Next.js App Router we store the session
in cookies via `@supabase/ssr` so both the browser and the server can read it,
and middleware keeps it fresh. The JWT's `sub` claim is the user id that
`auth.uid()` returns inside RLS policies — this is what makes RLS work.

## The pieces (all in `templates/nextjs/`)

| File | Where it runs | Job |
|------|---------------|-----|
| `client.ts` | Browser (Client Components) | User-scoped client with anon key |
| `server.ts` | Server Components / Actions / Route Handlers | User-scoped client reading session from cookies |
| `middleware.ts` | Edge, every request | Refreshes the session cookie, gates routes |
| `auth-actions.ts` | Server Actions | sign up / in / out / OAuth |

## Example auth flow (email + password)

1. **Sign up** — `signUp()` Server Action calls `supabase.auth.signUp()`. With email confirmations on (the default), the user gets a confirmation email. Locally, intercepted emails are visible in **Inbucket** at http://127.0.0.1:54324.
2. **Confirm** — the link points to `/auth/callback`, a Route Handler that exchanges the code for a session (see below).
3. **Sign in** — `signIn()` calls `signInWithPassword()`; Supabase sets the session cookie; redirect to `/dashboard`.
4. **Every request** — `middleware.ts` calls `getUser()` to revalidate and refresh the token, rewriting the cookie so it never expires mid-session.
5. **Read the user** — in any Server Component: `const { data: { user } } = await supabase.auth.getUser()`.
6. **Sign out** — `signOut()` clears the session and redirects.

### Auth callback Route Handler

Create `src/app/auth/callback/route.ts` to complete email confirmation and OAuth:

```ts
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/dashboard'

  if (code) {
    const supabase = await createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (!error) return NextResponse.redirect(`${origin}${next}`)
  }
  return NextResponse.redirect(`${origin}/login?error=auth`)
}
```

## getUser() vs getSession()

- **Server-side, for authorization:** always `getUser()`. It verifies the JWT with the auth server, so a tampered/expired cookie can't fool you.
- **`getSession()`** just decodes the cookie locally — fine for reading the access token to attach to a request, not for deciding "is this person allowed".

## Local auth config (`supabase/config.toml`)

```toml
[auth]
site_url = "http://localhost:3000"
additional_redirect_urls = ["http://localhost:3000/auth/callback"]

[auth.email]
enable_signup = true
enable_confirmations = true   # set false locally to skip the email step while testing

# Enable an OAuth provider (also set client id/secret as env in config or dashboard)
[auth.external.google]
enabled = true
client_id = "env(SUPABASE_AUTH_GOOGLE_CLIENT_ID)"
secret    = "env(SUPABASE_AUTH_GOOGLE_SECRET)"
```

On hosted, configure the same under **Authentication → URL Configuration** and
**Providers** in the dashboard, and set the redirect URLs to your production domain.

## Storage + auth (buckets)

Create a bucket and gate it with policies in a migration:

```sql
-- Create a public bucket for avatars (readable by anyone, writable by owner).
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Anyone can view avatars.
create policy "Avatar images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- A user may upload to a folder named after their own uid: avatars/<uid>/file.png
create policy "Users can upload their own avatar"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own avatar"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
```

Upload from the client:

```ts
const supabase = createClient()
const { data: { user } } = await supabase.auth.getUser()
await supabase.storage
  .from('avatars')
  .upload(`${user!.id}/avatar.png`, file, { upsert: true })

const { data } = supabase.storage.from('avatars').getPublicUrl(`${user!.id}/avatar.png`)
// data.publicUrl
```

For private buckets, use `createSignedUrl(path, expiresInSeconds)` instead of public URLs.
