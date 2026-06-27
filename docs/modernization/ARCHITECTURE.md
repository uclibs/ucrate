# Architecture

## Current (legacy)

```text
                    ┌─────────────┐
  Users ──────────► │ Rails/Hyrax │
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
                    │ Fedora (Java) │
                    │ Works, FileSets│
                    │ metadata, files│
                    └───────────────┘
```

- **Works**: `ActiveFedora::Base` (e.g. `GenericWork`, `FileSet`) in Fedora
- **Search**: Blacklight + Solr
- **Jobs**: Sidekiq + Redis
- **Custom**: DataCite DOI (`RemotelyIdentifiedByDoi`), ORCID gem, Bulkrax, 8 curation concerns

## Target (end state)

```text
  Users ──► Rails app (no Hyrax)
                │
        ┌───────┴───────┐
        ▼               ▼
   ┌─────────┐    ┌──────────────┐
   │   DB    │    │ File storage │
   │ (works, │    │ (on-campus   │
   │  users, │    │  disk/NFS)   │
   │  jobs)  │    └──────────────┘
   └─────────┘
```

Optional later: dedicated search engine if DB full-text is insufficient. **Not required** for initial target.

- **No Fedora, no Solr, no Redis** when fully cut over
- **DB-backed jobs** (e.g. Good Job / Solid Queue) when Rails version allows—or keep Redis until that hop
- **Files**: Active Storage, `local` or `database` + disk service (on-campus path)

## Transition (strangler)

Both stacks may run in **one Rails app** on scholar-dev:

```text
  Request ──► Router / flags
                 ├── Legacy: Hyrax controllers → Fedora
                 └── New: Scholar:: controllers → DB + Active Storage
```

Solr may index **both** during Phase 4–5; retire when catalog reads from DB.

## New code layout

Keep new code **namespaced and isolated** from Hyrax overrides.

| Path | Purpose |
|------|---------|
| `lib/scholar/` | Export/import, `DoiService`, pure Ruby services |
| `app/models/scholar/` | `Scholar::Record`, collections, permissions |
| `app/controllers/scholar/` | New deposit, show, admin (when added) |
| `app/views/scholar/` | New UI (Hotwire/simple ERB) |
| `lib/tasks/scholar/` | Rake tasks (export, import, verify) |
| `spec/scholar/` or `spec/lib/scholar/` | Tests for new code |

**Do not** scatter new logic in `app/models/generic_work.rb` or Hyrax overrides unless Phase 1 explicitly bridges legacy.

## Data model (sketch)

**`scholar_records`** (table name may vary):

- Core: `title`, `creators` (json), `description`, `resource_type`, `visibility`, `embargo_until`
- DOI: `doi`, `doi_url`, `existing_identifier`, `doi_state`
- Provenance: `legacy_fedora_id`, `depositor_id`, timestamps
- Metadata: `metadata` (json) for type-specific fields during migration

**Files**: Active Storage attachments on `Scholar::Record`

**Collections**: `scholar_collections`, `scholar_collection_memberships`

Exact schema evolves in Phase 2; document changes in [DECISIONS.md](./DECISIONS.md).

## Infrastructure (environments)

| Environment | Branch | Stack |
|-------------|--------|--------|
| Production | `develop` (until cutover) | Full legacy |
| QA | `develop` | Full legacy |
| scholar-dev | `scholar-modernization` | Legacy + new core as built |

## Integrations

| Integration | Legacy | Target |
|-------------|--------|--------|
| DataCite | `hydra-remote_identifier` fork | `Scholar::DoiService` |
| ORCID | `omniauth-orcid` + `users.orcid` | Same OAuth; optional refactor |
| Auth | Devise + Shibboleth | Unchanged |
