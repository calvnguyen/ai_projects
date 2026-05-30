// src/lib/supabase/server.ts
// -----------------------------------------------------------------------------
// Server Supabase client for Server Components, Route Handlers, and Server
// Actions (Next.js App Router). Reads/writes the auth session via cookies.
// Still uses the anon key + RLS — this is the user-scoped client.
//
// For privileged work that must bypass RLS (admin tasks, webhooks, cron),
// create a separate client with SUPABASE_SERVICE_ROLE_KEY and use it ONLY
// in trusted server code. Never import that into anything client-bundled.
// -----------------------------------------------------------------------------
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/lib/database.types'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            )
          } catch {
            // Called from a Server Component where cookies are read-only.
            // Safe to ignore — middleware refreshes the session instead.
          }
        },
      },
    },
  )
}

// Admin client (RLS-bypassing). Server-only. Use sparingly.
//
// import { createServerClient } from '@supabase/ssr'
// export function createAdminClient() {
//   return createServerClient<Database>(
//     process.env.NEXT_PUBLIC_SUPABASE_URL!,
//     process.env.SUPABASE_SERVICE_ROLE_KEY!,   // NEVER NEXT_PUBLIC_
//     { cookies: { getAll: () => [], setAll: () => {} } },
//   )
// }
