# Scholar modernization

This folder is the **single source of truth** for the Scholar@UC strangler migration off Samvera/Hyrax. It is written for **humans and for Cursor AI**—start here at the beginning of every work session.

## Quick context

| Item | Value |
|------|--------|
| **Branch** | `scholar-modernization` (long-lived feature branch) |
| **Base branch** | `develop` (production/QA legacy line until cutover) |
| **Deploy target for this work** | `scholar-dev` only—not production until cutover |
| **Language** | Ruby in this repo (`ucrate`) |
| **Strategy** | Strangler: grow new core beside Hyrax; retire services when nothing calls them |

## Documents

| File | Purpose | Who updates |
|------|---------|-------------|
| [PLAN.md](./PLAN.md) | Phases, rules, scope, out-of-scope | Rarely; when strategy changes |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Current vs target stack, code layout | When structure changes |
| [WORKFLOW.md](./WORKFLOW.md) | Git, two machines, Cursor sessions, merges | When process changes |
| [STATUS.md](./STATUS.md) | **Living:** current phase, done, next, blockers | **Every work session** (human + AI) |
| [DECISIONS.md](./DECISIONS.md) | Locked decisions (ADR-style) | When a decision is made final |
| [TESTING.md](./TESTING.md) | Fast vs full specs, `bin/rspec-fast`, definition of done | When test workflow changes |

## Session checklist (human + AI)

1. Read [STATUS.md](./STATUS.md).
2. Confirm branch: `git branch --show-current` → `scholar-modernization`.
3. If resuming after `develop` moved: merge `origin/develop` into this branch before new work.
4. Do **one slice** from the current phase in [PLAN.md](./PLAN.md).
5. Before ending session: update [STATUS.md](./STATUS.md) (done / next / notes).
6. Verify slice: run code quality checks ([TESTING.md](./TESTING.md)—naming, rubocop, `bin/rspec-fast`); push for full CircleCI suite.

## Rule of thumb

> **Never remove a moving part in an environment until nothing in that environment calls it.**  
> Rehearse removal on scholar-dev first. Production changes happen in the **cutover bundle** only.

## For Cursor AI

- Follow `.cursor/rules/scholar-modernization*.mdc`.
- Prefer **additive** code under `lib/scholar/` and `app/models/scholar/`—avoid rewriting Hyrax unless the current slice requires it.
- Do not expand scope beyond the phase in [STATUS.md](./STATUS.md).
- After implementing a slice, update [STATUS.md](./STATUS.md) in the same commit when possible.
