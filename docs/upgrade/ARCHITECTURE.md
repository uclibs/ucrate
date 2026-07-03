# Architecture

## Current (production / develop)

```text
                    ┌─────────────┐
  Users ──────────► │ Rails/Hyrax │
                    │   2.9.6     │
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
      ┌─────────┐    ┌──────────┐    ┌─────────┐
      │  MySQL  │    │  Redis   │    │  Solr   │
      │ (users, │    │ (Sidekiq)│    │(catalog)│
      │  app)   │    └──────────┘    └─────────┘
      └─────────┘           │
                            ▼
                    ┌───────────────┐
                    │ Fedora 4.7.x  │
                    │ ActiveFedora  │
                    │ 8 work types  │
                    └───────────────┘
```

| Layer | Version / detail |
|-------|------------------|
| Ruby | 2.7.8 |
| Rails | 5.2.4.6 |
| Hyrax | 2.9.6 (ActiveFedora) |
| Fedora | 4.7.5 (Java 8) |
| Solr | 8.x |
| Sidekiq | 6.5.x + Redis |
| App DB | MySQL (prod), SQLite (local test) |

**Works:** 8 ActiveFedora models + `FileSet` + `Collection` in Fedora.

**Keep through upgrade:** DOI, Shibboleth, permanent URLs, UC metadata, collections (simplify custom code toward stock Hyrax).

## Phase B complete (scholar-dev)

```text
  Users ──► Rails/Hyrax 5.2 + Valkyrie + Wings
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
 PostgreSQL   Redis      Solr
 (app +       (Sidekiq)  (catalog)
  Valkyrie
  metadata)
                │
                ▼
         ┌─────────────┐
         │  Fedora 4   │  ← repository binaries + legacy AF objects via Wings
         └─────────────┘
```

PostgreSQL arrives in **Phase B3** (before Valkyrie/Wings in B4).

## Milestone (Phase C complete — infosec)

Same as Phase B stack but repository tier is **Fedora 7 (OCFL)** instead of F4.

## End state (Phase D complete)

```text
  Users ──► Rails/Hyrax 5.2 + Valkyrie
                │
    ┌───────────┴───────────┐
    ▼                       ▼
 PostgreSQL              On-campus
 (works metadata,         file storage
  users, jobs)            (disk/NFS)
                │
                ▼
              Solr
```

- **No Fedora**
- **No ActiveFedora**
- **Same 8 work types**

## Transition path

```text
Phase A     Hyrax 2.9 slim + F4
Phase B     B1–B2 Ruby/Rails/Hyrax→4.x
            B3 PostgreSQL
            B4 Hyrax 5.2 + Valkyrie + Wings on F4
            B5 Solr reindex
Phase C     F4 → F6 → F7 (repository tier)
Phase D     Metadata off Fedora → PostgreSQL-only; decommission Fedora
```

**Ordering:** Phase C requires Phase B. No merge to **`develop`** until Fedora 7 works (after Phase C).

## Code layout

| Path | Role |
|------|------|
| `app/models/*.rb` | 8 work types → Valkyrie resources (B4) |
| `config/metadata/*.yaml` | Valkyrie schemas (B4) |
| `config/initializers/hyrax.rb` | 8 curation concerns |
| `app/models/concerns/remotely_identified_by_doi.rb` | DOI |
| `app/actors/hyrax/actors/mint_doi_actor.rb` | DOI mint |
| `lib/scholar.rb` | Permanent URLs |
| `app/controllers/common_objects_controller.rb` | `/show/:id` |
| `app/controllers/callbacks_controller.rb` | Shibboleth (not devise-multi_auth) |

**Cancelled:** `Scholar::Record`, `lib/scholar/` export stack.

## Environments

| Environment | Branch | Stack | Notes |
|-------------|--------|--------|-------|
| Production / QA | `develop` | Hyrax 2.9 + F4 until cutover | Public Scholar@UC |
| **scholar-dev** | `scholar-modernization` | Current upgrade sub-phase | UC dev deployment; validate each sub-phase here |

**scholar-dev** is operated by UC; deploy `scholar-modernization` after CI passes. Local dev (root README) can substitute for baseline counts only if documented in STATUS baseline JSON.

## File storage

On-campus disk/NFS; Active Storage or Valkyrie disk adapter in Phase D.
