# Upgrade status

**Last updated:** 2026-07-03  
**Current phase:** A — De-customize (Hyrax 2.9 / Fedora 4)  
**Current sub-phase:** **A1** — Audit and baseline (**docs + baseline JSON only; no app code**)  
**Branch:** `scholar-modernization` (all upgrade work; **do not merge to `develop` until Fedora 7 works**)

## Current stack (until Phase B changes it)

| Layer | Version |
|-------|---------|
| Ruby | 2.7.8 |
| Rails | 5.2.4.6 |
| Hyrax | 2.9.6 |
| Fedora | 4.7.5 |
| App DB | MySQL (prod/QA), SQLite (local test) |

See [ARCHITECTURE.md](./ARCHITECTURE.md) for target stack per phase.

## Progress

| Phase | Status | Notes |
|-------|--------|-------|
| A1 Audit + baseline | [ ] Not started | |
| A2 Remove integrations | [ ] | After A1 |
| A3 Remove ORCID | [ ] | Ordered steps in PLAN |
| A4 ChangeManager | [ ] | |
| A5 BrowseEverything | [ ] | |
| A6 Forms/views/collections | [ ] | Simplify toward stock Hyrax |
| A7 Gem hygiene | [ ] | |
| **Phase A gate** | [ ] | Before Phase B |
| B1 Ruby/Rails | [ ] | |
| B2 Hyrax 2.9→4.x | [ ] | |
| B3 PostgreSQL | [ ] | Before B4 |
| B4 Hyrax 5.2 + Valkyrie + Wings | [ ] | DOI spike here |
| B5 Solr reindex | [ ] | |
| **Phase B gate** | [ ] | Before Phase C |
| C1–C3 Fedora F6→F7 | [ ] | |
| **Phase C gate** | [ ] | Enables merge to `develop` |
| D PostgreSQL-only | [ ] | |

## Next up

1. Complete **A1 audit table** below (grep, logs, stakeholders).
2. Run baseline counts on scholar-dev per [INTEGRITY.md](./INTEGRITY.md); commit `baseline/baseline-YYYY-MM-DD.json`.
3. Document gem inventory findings for A7.

## Blockers

| Blocker | Owner | Notes |
|---------|-------|-------|
| — | — | None |

## Baseline

| Field | Value |
|-------|-------|
| File | *(none yet — create in A1)* |
| Environment | scholar-dev (seed data) |
| Prod-shaped copy | Aspirational; re-baseline when available |

## A1 audit table

Fill each row during A1. **Default: remove in listed phase unless active use found.**

| Item | Active use? | Evidence | Action |
|------|-------------|----------|--------|
| Grape API | | | Default A2 remove |
| Bulkrax | | | Default A2 remove if unused |
| ChangeManager | | | Default A4 remove |
| BrowseEverything | | | Default A5 trim |
| Kaltura | | | Default A2 remove |
| AWS X-Ray | | | Default A2 remove |
| RSS / feed | | | Default A2 remove |
| Sitemap | | | Default A2 remove |
| Featured collections | | | Default A2 remove |
| Collection TSV export | | | Default A2 remove |
| Custom collection logic | | | Default A2/A6 simplify |
| RemoveProxyEditors | | | Default A4 evaluate |
| Other unused gems | | | A7 |

## Session log

| Date | Sub-phase | Done | Next |
|------|-----------|------|------|
| 2026-07-03 | Docs | Full upgrade plan in `docs/upgrade/`; fresh-agent clarifications; cursor rules | A1 audit + baseline |

## Known issues (carry forward)

| Issue | Phase | Notes |
|-------|-------|-------|
| `ExpirationService` hardcodes `api.test.datacite.org` | A7 | Use `config/doi.yml` / env |
| Rack pinned for security | Done on branch | `~> 2.2.23` |
