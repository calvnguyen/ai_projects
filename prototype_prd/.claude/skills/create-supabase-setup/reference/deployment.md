# Production deployment

## Mental model

- **Local Docker** = your workbench. Disposable, seeded, resettable.
- **Hosted Supabase** = your destination. One project per environment (ideally separate **staging** and **production** projects).
- You move schema from local → hosted by **pushing migrations**, never by hand-editing the hosted DB.

## One-time: create and link the hosted project

1. Create a project at https://supabase.com/dashboard (pick a region near your users; save the DB password).
2. Grab the project ref from the dashboard URL or **Project Settings → General**.
3. Link your local repo to it:

```bash
supabase login                       # opens browser for an access token
supabase link --project-ref <ref>    # writes the link into supabase/config.toml
```

## Deploy schema changes

```bash
supabase db push          # applies any migrations not yet on the hosted DB
```

Push runs only **new** migrations, in order. Because migrations are immutable and
replayable, hosted ends up identical to local. Check what would run first with:

```bash
supabase migration list   # shows local vs remote migration state
```

> Do **not** run `seed.sql` against production. Seed is dev-only. Insert real
> initial/reference data via a dedicated, idempotent migration if you need it.

## Frontend deploy (Vercel example)

1. Push the repo to GitHub, import it into Vercel.
2. Set environment variables in the Vercel dashboard (Project → Settings → Environment Variables):
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://<ref>.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = production anon key
   - `SUPABASE_SERVICE_ROLE_KEY` = production service role key (mark it **not** exposed to the browser — never prefix `NEXT_PUBLIC_`)
   - `NEXT_PUBLIC_SITE_URL` = your production URL
3. In the Supabase dashboard → **Authentication → URL Configuration**, set **Site URL** and **Redirect URLs** to your production domain (`https://yourapp.com/auth/callback`). Auth redirects silently break if you skip this.

## Secrets management

- **Local:** `.env.local`, git-ignored. Keys are throwaway.
- **Production:** set in the host's dashboard (Vercel/Fly/Railway). Never commit real keys; never paste them into chat/logs.
- Rotate keys in **Project Settings → API** if a `service_role` key is ever exposed. Rotating invalidates the old key everywhere — update your host's env vars in the same change.
- Use **separate Supabase projects** for staging vs production so a bad migration or seed can't touch real users.

## CI: apply migrations automatically (GitHub Actions)

```yaml
# .github/workflows/deploy-db.yml
name: Deploy DB migrations
on:
  push:
    branches: [main]
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
        with: { version: latest }
      - run: supabase link --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
      - run: supabase db push
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_DB_PASSWORD: ${{ secrets.SUPABASE_DB_PASSWORD }}
```

Store `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, and `SUPABASE_DB_PASSWORD`
as GitHub repository secrets.

## Pre-launch production checklist

- [ ] RLS enabled on **every** table in the `public` schema, with reviewed policies.
- [ ] `service_role` key only in server env, never `NEXT_PUBLIC_`, never client-imported.
- [ ] Auth Site URL + redirect URLs point to the production domain.
- [ ] Email templates/SMTP configured (the built-in email sender is rate-limited; set up custom SMTP for real volume).
- [ ] Database backups enabled (Pro plan) / point-in-time recovery if needed.
- [ ] Indexes on foreign keys and frequently-filtered columns.
- [ ] Separate staging project; migrations tested on staging before prod.
- [ ] Rate limits and a CAPTCHA on auth endpoints if abuse is a concern.
- [ ] No `seed.sql` data or test users in production.
