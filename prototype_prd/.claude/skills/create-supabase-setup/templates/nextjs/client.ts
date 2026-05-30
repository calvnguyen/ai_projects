// src/lib/supabase/client.ts
// -----------------------------------------------------------------------------
// Browser Supabase client for use in Client Components ("use client").
// Uses the PUBLIC anon key only — every request is still gated by RLS.
// -----------------------------------------------------------------------------
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/lib/database.types'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  )
}

// Usage in a Client Component:
//   'use client'
//   import { createClient } from '@/lib/supabase/client'
//   const supabase = createClient()
//   const { data } = await supabase.from('campers').select('*')
