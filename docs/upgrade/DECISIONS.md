# Decisions log

## Active decisions

| ID | Date | Decision | Rationale |
|----|------|----------|-----------|
| U1 | 2026-07-03 | **Upgrade in place** on community Hyrax 5 | Supported stack; reduce custom code |
| U2 | 2026-07-03 | **Target Hyrax 5.2.x** + Valkyrie + PostgreSQL end state | Community direction; Wings eases F4 transition |
| U3 | 2026-07-03 | **Fedora 7 infosec milestone** via F6 OCFL first | No F4→F7 direct path |
| U4 | 2026-07-03 | **Keep DOI + Shibboleth only** among auth integrations | Minimal custom surface |
| U5 | 2026-07-03 | **Keep all 8 UC work types** | Data integrity; simplify UI only |
| U6 | 2026-07-03 | **Feature branch `scholar-modernization`** | Historical branch name; docs use “upgrade” |
| U7 | 2026-07-03 | **scholar-dev before production** | Rehearse every sub-phase |
| U8 | 2026-07-03 | **On-campus file storage** | Institutional requirement |
| U9 | 2026-07-03 | **Moving-parts rule** | Retire Fedora/Solr/Redis only when unused |
| U10 | 2026-07-03 | **No merge to `develop` until Fedora 7 works** | Production line stays legacy until cutover |
| U11 | 2026-07-03 | **PostgreSQL before Valkyrie (B3 before B4)** | Hyrax 5 Valkyrie expects PG metadata store |
| U12 | 2026-07-03 | **Collections: simplify toward stock Hyrax** | Remove pre–collection-type custom logic where stock suffices |
| U13 | 2026-07-03 | **Tests: prefer fast unit RSpec** | `bin/rspec-fast`; avoid new flaky feature specs unless necessary |

## Superseded (strangler plan)

| ID | Date | Decision | Superseded by |
|----|------|----------|---------------|
| D1–D9 | 2026-03-26 | Strangler / Scholar::Record / etc. | U1, U5, U10 |

## Open questions

| Question | Default | Owner |
|----------|---------|-------|
| Bulkrax used? | Remove A2 if unused | A1 |
| Grape API used? | Remove A2 if unused | A1 |
| Prod-shaped copy on scholar-dev | Re-baseline when available | Ops |
| DataCite sandbox on scholar-dev | Sandbox | Ops |
| Sidekiq 6 vs 7 on Hyrax 5 | Stay on 6 unless required | B5 |

## Out of scope

- Nurax 3-type collapse
- Greenfield repo
- Merge to `develop` before Fedora 7
