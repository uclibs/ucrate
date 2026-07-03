# Scholar@UC upgrade (Hyrax 5 + Fedora 7)

This folder is the **single source of truth** for upgrading **Scholar@UC** (`uclibs/ucrate` — a Hyrax-based institutional repository at the University of Cincinnati) from Hyrax 2.9 / Fedora 4 to **community Hyrax 5.2.x**, **Fedora 7** (infosec), and eventually **PostgreSQL** as the sole persistence layer. Written for humans and Cursor AI—**start here every session with no chat memory assumed**.

**Supersedes:** the March 2026 strangler plan (`Scholar::Record`, custom stack beside Hyrax). That approach is **cancelled**. Do not implement it.

## Quick context

| Item | Value |
|------|--------|
| **App** | Scholar@UC — Rails + Hyrax 2.9.6 + ActiveFedora + Fedora 4 (see [ARCHITECTURE.md](./ARCHITECTURE.md)) |
| **Feature branch** | `scholar-modernization` (historical name; docs say **upgrade** — all upgrade commits land here) |
| **Production line** | `develop` — **do not merge upgrade work into `develop` until Fedora 7 is working** |
| **scholar-dev** | UC **development deployment** of Scholar; deploys from `scholar-modernization` after each sub-phase |
| **Deploy target** | scholar-dev first; production/QA (`develop`) only after Phase C + coordinated cutover |
| **Strategy** | De-customize → Hyrax 5 + Valkyrie → Fedora 6 → Fedora 7 → PostgreSQL-only |
| **Data priority** | **No lost or undisplayable works.** Counts and spot-checks every slice. |
| **Current sub-phase** | Always read [STATUS.md](./STATUS.md) — as of last update: **A1** (audit + baseline; **no app code changes**) |

## Glossary

| Term | Meaning |
|------|---------|
| **Slice** | One bounded unit of work—usually **one sub-phase** (e.g. A2) or a clearly scoped part of it. One slice per session unless STATUS says otherwise. |
| **scholar-dev** | Dev server/environment for upgrade testing (not local laptop by default). Local Fedora+Solr can substitute for baseline **only** if documented in STATUS. |
| **Wings** | Hyrax 5 bridge that reads legacy **ActiveFedora / Fedora 4** objects without bulk migration (Phase B4). |
| **Valkyrie** | Hyrax 5 metadata persistence layer; uses PostgreSQL (Phase B3–B4). |
| **Infosec milestone** | Production on **Fedora 7** (Phase C complete). |
| **Moving-parts rule** | Do not remove Fedora, Solr, or Redis from an environment until nothing there calls them. |

## Do not implement (cancelled)

- `Scholar::Record`, `app/models/scholar/`, `lib/scholar/` export/import stack
- Strangler “Phase 0–6” export plan from March 2026 docs
- Collapsing 8 UC work types to Nurax’s 3 types
- Merging upgrade work to `develop` before Fedora 7 works

**Safe to keep:** `lib/scholar.rb` (`Scholar.permanent_url_for` only) — see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Documents

| File | Purpose | Who updates |
|------|---------|-------------|
| [PLAN.md](./PLAN.md) | Phases A–D, keep/remove list, exit criteria, slice order | When strategy changes |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Current vs milestone vs end-state stack | When stack changes |
| [INTEGRITY.md](./INTEGRITY.md) | Baseline counts, verification gates, rollback | When verification steps change |
| [WORKFLOW.md](./WORKFLOW.md) | Git, branch policy, Cursor prompts | Rarely |
| [STATUS.md](./STATUS.md) | **Living:** current phase, done, next, blockers | **Every work session** |
| [DECISIONS.md](./DECISIONS.md) | Locked ADR-style decisions | When a decision is final |
| [TESTING.md](./TESTING.md) | `bin/rspec-fast`, CI, definition of done | When test workflow changes |

Also see repo root [AGENTS.md](../../AGENTS.md) for a one-screen agent entry point.

## Session checklist (human + AI)

1. Read [STATUS.md](./STATUS.md).
2. Confirm branch: `git branch --show-current` → `scholar-modernization`.
3. Optionally merge **`develop` → `scholar-modernization`** for security fixes on the production line (cherry-pick or merge); never the reverse until Fedora 7 works.
4. Do **one slice** from the current sub-phase in [PLAN.md](./PLAN.md)—not the whole phase.
5. Run verification from [INTEGRITY.md](./INTEGRITY.md) when the slice touches works, Fedora, Solr, DOI, or auth.
6. Before ending: update [STATUS.md](./STATUS.md) (date, done, next, blockers, baseline notes).
7. Done bar: [TESTING.md](./TESTING.md)—naming, rubocop on changed files, `bin/rspec-fast`; push for full CircleCI when ready.

## Core rules

> **Never remove a moving part in an environment until nothing there calls it.**

> **All upgrade work stays on `scholar-modernization` until Fedora 7 is validated.** Do not merge to `develop` before then.

> **If chat history conflicts with these docs, docs win.**

## For Cursor AI

- Follow `.cursor/rules/scholar-upgrade*.mdc` and [scholar-code-quality.mdc](../../.cursor/rules/scholar-code-quality.mdc).
- **Keep:** DOI (DataCite), Shibboleth, all **8 work types**, collections (simplify toward stock Hyrax), metadata on show.
- **Remove:** ORCID, ChangeManager, Grape API, unused gems, custom collection logic where stock Hyrax replaces it.
- Do not start Phase B until Phase A exit criteria are met on scholar-dev.
- Do not start Phase C until Phase B exit criteria are met.
- Commit prefix: `Phase A2: …`, `Phase B4: …`, etc.
