#!/usr/bin/env bash
# =============================================================================
# reset-db.sh — rebuild the local DB and regenerate types
# -----------------------------------------------------------------------------
# Drops the local database, re-runs ALL migrations, runs seed.sql, then
# regenerates TypeScript types. Use after editing migrations or seed data.
#
# Usage:  bash .claude/skills/create-supabase-setup/scripts/reset-db.sh
# =============================================================================
set -euo pipefail

TYPES_PATH="${TYPES_PATH:-src/lib/database.types.ts}"

echo "▶ Resetting local database..."
supabase db reset

echo "▶ Regenerating TypeScript types → ${TYPES_PATH}"
mkdir -p "$(dirname "$TYPES_PATH")"
supabase gen types typescript --local > "$TYPES_PATH"

echo "✓ Database reset and types regenerated."
