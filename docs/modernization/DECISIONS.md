# Decisions log

Short ADR-style entries. When a decision is final, add a row; do not delete—mark superseded if it changes.

| ID | Date | Decision | Rationale |
|----|------|----------|-----------|
| D1 | 2026-03-26 | **Strangler in `ucrate`**, not greenfield repo | Management frame as improvements; reuse auth, deploy, domain knowledge |
| D2 | 2026-03-26 | **Ruby**, not C# | Solo maintainer for foreseeable future; strangler fits same Rails app |
| D3 | 2026-03-26 | **Branch `scholar-modernization`** | Long-lived feature branch; merge `develop` in periodically |
| D4 | 2026-03-26 | **scholar-dev only** until cutover | Prod/QA stay on `develop`/legacy until coordinated switch |
| D5 | 2026-03-26 | **On-campus DB + disk**, not cloud object storage | Institutional requirement; Active Storage `local`/mounted path |
| D6 | 2026-03-26 | **Exit Hyrax/Fedora/Solr/Redis** over time | Reduce server count and unsupported stack; not big-bang gem bump |
| D7 | 2026-03-26 | **One `Scholar::Record` + `resource_type`**, not 8 models | Maintainability; map legacy types on import |
| D8 | 2026-03-26 | **New code under `lib/scholar/`, `app/models/scholar/`** | Isolate from Hyrax overrides; easier merges from develop |
| D9 | 2026-03-26 | **MySQL for new tables initially** | Already in stack; revisit Postgres only if strong ops reason |

## Open questions

Track here until resolved; move to table above when decided.

| Question | Notes |
|----------|--------|
| Active Storage root path on scholar-dev vs prod | Ask ops; document in STATUS when known |
| Solr dual-index vs early DB search for Phase 3–4 | Decide before Phase 3 UI |
| DataCite sandbox vs production prefix on scholar-dev | Use sandbox for dev testing |
| Pilot resource type: Generic Work vs Document | Default Generic Work; confirm in Phase 3 |
