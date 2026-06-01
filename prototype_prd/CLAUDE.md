# Prototype PRD Projects

This repo is Calvin's workspace for building PRD-driven product prototypes with Claude Code.

## Who I'm working with

**Calvin Nguyen** — senior frontend engineer, ~9 years experience, deep expertise in Angular and TypeScript, some React.

- Assume expert-level TypeScript and frontend architecture instincts — skip the basics, lead with the decision and trade-off.
- React is less familiar. When something differs from Angular (hooks lifecycle, state colocation vs. services/DI), call out the _why_, not just the _how_.
- Standards Calvin judges work on: **UX, input validation, system reliability, and accessibility** — all first-class, not polish. Flag gaps rather than shipping past them.

## Preferred stack

- **React + TypeScript** (Next.js App Router for new projects)
- **Tailwind v4** for styling
- **Supabase** (Postgres + Storage + Auth) as the backend, always behind a typed data-layer interface
- **Vitest + RTL** for unit/component tests; **Playwright** for e2e
- **TypeScript strict** — no `any`

## Repo structure

```
projects/       # Individual product prototypes (each has its own CLAUDE.md + docs/)
demos/          # Demo scripts and agent experiments
.claude/
  skills/       # Reusable implementation workflows
  agents/       # Specialized agent behavior and reasoning
```

## Documentation conventions

Every project under `projects/` organizes its docs as:

| Path                 | Purpose                                             |
| -------------------- | --------------------------------------------------- |
| `docs/prd/`          | Product requirements and feature specs              |
| `docs/architecture/` | Technical architecture and implementation decisions |
| `docs/decisions/`    | Architectural decision records (ADRs)               |
| `docs/workflows/`    | User and business workflows                         |

Do not store large PRD or implementation details directly in `CLAUDE.md` — write to `docs/` and reference from there.

## `.claude/` conventions

`.claude/skills/` — reusable implementation workflows (intake forms, Supabase setup, API scaffolding, UI generation, validation)

`.claude/agents/` — specialized agent behavior and reasoning (intake agent, layout generation agent, architect review agent)

Prefer existing skills before creating new abstractions.

## Engineering expectations

- Keep `CLAUDE.md` concise and high-level — reference docs instead of duplicating content.
- Read relevant docs before implementing features.
- Prefer existing skills before creating new abstractions.
- Keep architecture modular and scalable.
- Avoid overengineering MVP features.

## Accessibility (non-negotiable)

Accessibility is a core requirement on every UI change — not polish, not optional.

- **Semantic HTML first** — use real `button`, `nav`, `main`, `ul/li`, ordered headings. ARIA only fills gaps native HTML can't express.
- **Every control has a label** — `<label htmlFor>` or wrapping label. Placeholders are not labels.
- **Validation is announced** — `aria-invalid` on the field, error message in an element referenced by `aria-describedby` with `role="alert"`, focus moved to the first invalid field on submit.
- **Full keyboard operability** — every interactive element reachable and operable via Tab/Shift+Tab, Enter/Space. Custom controls expose correct role and state.
- **Visible focus** — never remove `:focus-visible` without an equally clear replacement.
- **Color is never the only signal** — pair with text or icon; meet WCAG AA contrast.
- **Images and icons** — meaningful ones get `alt` or an accessible name; decorative ones are `aria-hidden`.
- **Test by behavior** — use `getByRole`/`getByLabelText` in RTL, assert `aria-invalid`, `role="alert"`, checked/expanded states.

Flag accessibility gaps rather than shipping past them.

## Documentation & Change Management Rules

### Before implementing

1. Review `docs/prd/`, `docs/architecture/`, `docs/decisions/`, and relevant existing components first.
2. Check for conflicting requirements or patterns that already exist.
3. Reuse existing flows and components before creating new abstractions.
4. Confirm the change aligns with current MVP goals.
5. Summarize the planned change, identify affected flows/components and docs, confirm whether existing patterns apply.

### PRD update rules

Whenever new requirements, workflows, or business logic are introduced, update the appropriate doc under `docs/prd/`. Keep docs in sync with implementation. Prefer updating existing sections over creating duplicate requirements.

| Change type | Update target |
|---|---|
| New intake field | `docs/prd/intake-flow.md` |
| New workflow state or transition | relevant workflow doc |
| New AI behavior | `docs/prd/ai-concept-generation.md` (or equivalent) |
| New role behavior | relevant review/workflow doc |

### Architecture review rules

Before introducing new routes, services, state management patterns, database tables, or abstractions:

1. Review existing architecture docs.
2. Check whether the pattern already exists.
3. Prefer consistency over novelty.
4. Keep MVP architecture simple — avoid unnecessary abstractions, premature optimization, duplicate services, or overengineering.

### After coding

- Update relevant documentation.
- Verify workflows still make sense end-to-end.
- Confirm role behaviors are clear.
- Confirm status/transition consistency.

### MVP philosophy

- Prefer clarity over complexity.
- Prefer simple, reusable flows.
- Keep AI features optional and resilient — never block core workflows on AI failures.
- Optimize for iteration speed and maintainability.
