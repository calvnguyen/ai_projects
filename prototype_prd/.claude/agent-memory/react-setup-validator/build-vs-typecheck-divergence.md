---
name: build-vs-typecheck-divergence
description: camp-away-design — npm run build (tsc -b) checks more files than npm run typecheck (tsc --noEmit); a green typecheck does not imply a green build
metadata:
  type: project
---

In `projects/camp-away-design` (Vite + React + TS, npm, Node 26, no `engines` field), `npm run build` is `tsc -b && vite build`. The `tsc -b` step type-checks via project references — including `tsconfig.node.json` (which covers `vite.config.ts`) and `src/stories/*` — whereas `npm run typecheck` is `tsc --noEmit` against the app config only. So **typecheck + lint + vitest can all be green while `npm run build` fails.**

**Why:** the two commands compile different file sets. Validation that only runs `typecheck`/`test:run` misses build-only breakage in `vite.config.ts` and Storybook boilerplate.

**How to apply:** when validating this project, always run `npm run build` explicitly — don't infer build health from `typecheck`. Two blocking build issues were found and fixed on 2026-05-30: (1) `@types/node` was entirely absent → `vite.config.ts` failed on `node:path`/`node:url`/`__dirname`; fixed by `npm i -D @types/node`. (2) `src/stories/Button.tsx` + `Header.tsx` had an unused `import React` tripping `noUnusedLocals` (Vite React plugin uses the automatic JSX runtime, so the import is dead) — removed. Dev server: `npm run dev` → Vite on port 5173; tests: `npm run test:run` for non-watch. See [[camp-away-design-setup]].
