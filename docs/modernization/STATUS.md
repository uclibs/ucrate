# Status (living document)

**Update this file at the end of every work session.**

| Field | Value |
|-------|--------|
| **Last updated** | 2026-06-26 |
| **Updated by** | Session wrap — local test tier + docs |
| **Current phase** | Phase 0 (not started) |
| **Branch** | `scholar-modernization` |

## Done recently

- [x] Created modernization docs and Cursor rules
- [x] Created `scholar-modernization` branch (local)
- [x] Added `bin/rspec-fast` and [TESTING.md](./TESTING.md) (fast local tier; CI runs full suite)
- [x] Added throwaway slop checks in `spec/throwaway/` (mocked slow-tier smoke; local only)
- [x] Removed 14 empty Hyrax/QA spec placeholders (generator stubs; no real coverage lost)

## In progress

- [ ] (nothing yet)

## Next up

1. Push `scholar-modernization` to origin (when ready)
2. Phase 0: design export manifest format + first rake task skeleton
3. Merge `origin/develop` into feature branch if behind

## Blockers

- None

## Phase checklist

Copy phase items from [PLAN.md](./PLAN.md); check off here as completed.

### Phase 0

- [ ] Export manifest
- [ ] Integrity / restore procedure
- [ ] Test with prod-shaped sample on scholar-dev

### Phase 1–6

See [PLAN.md](./PLAN.md)—detail here as each phase starts.

## Session log (optional)

| Date | Notes |
|------|--------|
| 2026-03-26 | Planning docs and rules created |
| 2026-06-26 | Fast local test tier: `bin/rspec-fast`, TESTING.md, `:slow` metadata |
| 2026-06-26 | Throwaway slop specs; removed 14 empty spec placeholders; commit prep |

## scholar-dev deploy notes

_(Record last deploy commit SHA, date, and any env vars needed for new code.)_

- Not yet deployed
