# Modernization plan

## Goal

Evolve Scholar@UC from Samvera/Hyrax (Fedora, Solr, Redis, many servers) into a **maintainable repository**: relational database + on-campus file storage + Rails app—with **DOI (DataCite)** and **ORCID** preserved. Same product name and URL at cutover; work happens incrementally on `scholar-modernization` and **scholar-dev**.

## Non-negotiables

- **DOI**: preserve existing identifiers; DataCite mint/update/hide behavior
- **ORCID**: profile connect + display (push-to-ORCID optional later)
- **Shibboleth** login (same institutional auth)
- **Migration** of existing works from Fedora/Hyrax
- **On-campus** database and file storage (no cloud object storage requirement)
- **Collections** and **visibility** (public / restricted / private; embargoes phase 2+)

## Core rule

> **Never remove a moving part until nothing in that environment calls it.**

On scholar-dev, rehearse turning off Fedora, Solr, Redis, and Hyrax **in that order** (Hyrax last). Production removes services only in the **cutover** deploy after dev rehearsal and final sync.

## Phases

### Phase 0 — Trust and visibility

**Pitch:** reliability, backups, integrity.

- [ ] Export manifest (metadata + file list + checksums + DOI + visibility + collections)
- [ ] Restore/integrity check procedure documented
- [ ] Run export against prod-shaped data on scholar-dev

**Legacy stack:** unchanged for users.

---

### Phase 1 — Extract integrations

**Pitch:** reduce fork risk; centralize DOI/ORCID.

- [ ] `Scholar::DoiService` (DataCite); Hyrax actors call it (no behavior change)
- [ ] ORCID connection logic documented / isolated where practical

**Legacy stack:** unchanged for users.

---

### Phase 2 — New core beside Hyrax

**Pitch:** modern metadata + file storage on our servers.

- [ ] DB tables for `Scholar::Record` (and related)
- [ ] Active Storage → on-campus disk (configured path)
- [ ] Import rake task: Fedora/Solr export → `Scholar::Record` (mirror/verify)
- [ ] Admin-only or rake-only at first—no public UI required

**Legacy stack:** still serves all user traffic.

---

### Phase 3 — Pilot deposit (one resource type)

**Pitch:** simplified deposit for one type (start with **Generic Work** or **Document**).

- [ ] New deposit route (feature-flagged or `/deposit/...`)
- [ ] Index new records in Solr **or** interim browse path (see STATUS)
- [ ] DOI on publish via `Scholar::DoiService`
- [ ] scholar-dev only; internal testers

**Legacy stack:** all other types and edits via Hyrax.

---

### Phase 4 — Unified discovery

**Pitch:** one catalog experience on dev.

- [ ] Search/browse finds legacy + new records (Solr dual-index or DB search—decide in STATUS)
- [ ] Collections: plan for new records (legacy collections may still be Hyrax-only initially)

---

### Phase 5 — Migration waves

**Pitch:** legacy content on supported storage.

- [ ] Batch import by type or cohort
- [ ] Redirect/show route for migrated items
- [ ] DOI landing URL updates when show URL changes
- [ ] Fedora objects read-only after successful migrate

---

### Phase 6 — Cutover and decommission

**Pitch:** remove unsupported dependencies.

- [ ] Production deploy (one coordinated release)
- [ ] Final delta import
- [ ] Turn off Hyrax deposit paths
- [ ] Decommission Fedora → Solr → Redis as nothing calls them
- [ ] Bulkrax replaced by CSV import on `Scholar::Record`

## Out of scope for v1 (unless STATUS says otherwise)

- Eight separate deposit wizards (use `resource_type` + conditional fields)
- Fedora-style versioning and FileSet reorder UI
- Full Sipity workflow parity
- Grape API parity
- Push works to ORCID automatically
- IIIF / BrowseEverything
- Hyrax upgrade to latest
- Cloud-only storage (AWS S3)

## Work types (target)

One `Scholar::Record` with `resource_type`: `generic_work`, `article`, `document`, `dataset`, `image`, `medium`, `student_work`, `etd` (align with existing Hyrax types for migration mapping).

## Merge policy

- Merge **`develop` → `scholar-modernization`** regularly (weekly or after security fixes).
- Do **not** merge feature → `develop` until cutover (except cherry-picked prod fixes landed on develop first).

See [WORKFLOW.md](./WORKFLOW.md).
