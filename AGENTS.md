# Agent instructions (Scholar@UC)

**Repository:** `uclibs/ucrate` — Scholar@UC, a Hyrax 2.9 institutional repository.

For **Hyrax 5 + Fedora 7 upgrade** work, read first:

**[docs/upgrade/README.md](docs/upgrade/README.md)** (glossary, cancelled work, session checklist)

Then [STATUS.md](docs/upgrade/STATUS.md) for the **current sub-phase** — do only that slice.

## Quick reference

| Item | Value |
|------|--------|
| Branch | `scholar-modernization` (all upgrade commits; **no merge to `develop` until Fedora 7 works**) |
| Strategy | De-customize → Hyrax 5 + Valkyrie → Fedora 7 → PostgreSQL |
| **Cancelled** | Strangler plan (`Scholar::Record`, `lib/scholar/` export stack) |
| Keep | DOI, Shibboleth, **8 work types**, collections (simplify toward stock Hyrax), metadata on show |
| Remove | ORCID, ChangeManager, Grape API, unused gems (see PLAN) |
| Data rule | No lost/undisplayable works — [INTEGRITY.md](docs/upgrade/INTEGRITY.md) |
| Done bar | Naming, rubocop, `bin/rspec-fast`, update STATUS.md |

Implement **one sub-phase slice** from [PLAN.md](docs/upgrade/PLAN.md) per session. Do not start Phase B until Phase A exit criteria are met.

Legacy Hyrax behavior: change only when the active sub-phase requires it.
