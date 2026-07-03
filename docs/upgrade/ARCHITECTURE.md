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

## After B4 (scholar-dev) — where data lives

| Content | Store |
|---------|--------|
| Legacy works | **Fedora 4** (read via Wings) |
| New Valkyrie metadata | **PostgreSQL** |
| Users / roles / admin | **PostgreSQL** |
| Binaries | Fedora (until Phase D moves files on-campus) |
| Jobs | **Redis** + Sidekiq |
| Catalog | **Solr** |

## Milestone (Phase C complete — infosec)

Same application stack as Phase B, but repository tier is **Fedora 7 (OCFL)** instead of F4.

**Path to milestone:**

1. **C1–C2 on scholar-dev:** F4 → F6 → F7 (prove F7 here).
2. **Merge** `scholar-modernization` → `develop` (allowed only after C2).
3. **C3 production cutover:** deploy from `develop`, MySQL → PostgreSQL, F4 → F6 → F7.

## End state (Phase D complete)

```text
  Users ──► Rails/Hyrax 5.2 + Valkyrie
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
 PostgreSQL   Redis      Solr
 (works       (Sidekiq)  (catalog)
  metadata,
  users)
                │
                ▼
         On-campus file storage
         (disk/NFS)
```

- **No Fedora**
- **No ActiveFedora**
- **Same 8 work types**
- **Redis remains** while Sidekiq (or equivalent) needs it—not removed by Phase D by default

## Transition path

```text
Phase A     Hyrax 2.9 slim + F4
Phase B     B1–B2 Ruby/Rails/Hyrax→4.x
            B3 PostgreSQL (scholar-dev / CI)
            B4 Hyrax 5.2 + Valkyrie + Wings on F4
            B5 Solr reindex
Phase C     C1–C2: F4→F6→F7 on scholar-dev
            merge → develop
            C3: production cutover (app + PG + F6/F7)
Phase D     Remaining metadata/files off Fedora; decommission Fedora
```

**Ordering:** Phase C requires Phase B. Merge to **`develop`** only after **C2** (F7 on scholar-dev). Production F7 is **C3**.

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
