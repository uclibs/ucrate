# Upgrade plan

## Goal

Upgrade Scholar@UC to a **community-supported** stack while **preserving every existing work**:

1. **Phase A** — Remove nonessential customizations on **Hyrax 2.9 / Fedora 4**
2. **Phase B** — Stair-step to **Hyrax 5.2.x + PostgreSQL + Valkyrie + Wings** (still on Fedora 4 for repository content)
3. **Phase C** — Migrate repository **Fedora 4 → 6 (OCFL) → 7** (infosec milestone)
4. **Phase D** — Move work metadata off Fedora to PostgreSQL-only; decommission Fedora

## Non-negotiables

| Requirement | Implementation to preserve |
|-------------|---------------------------|
| **All works findable and displayable** | Keep 8 work types; [INTEGRITY.md](./INTEGRITY.md) gates |
| **DOI (DataCite)** | Mint, manual DOI, embargo publish, destroy/hide |
| **Shibboleth (UC Central Login)** | Devise + `omniauth-shibboleth`; minimal UC attribute mapping |
| **Permanent URLs** | `/show/:id` for DOI landing pages |
| **Collections** | Membership and discovery preserved; **simplify** toward stock Hyrax collection types (remove pre-Hyrax custom collection logic in Phase A where stock behavior suffices) |
| **Embargoes & visibility** | Public / restricted / private; embargo release + DOI update |
| **Fixity** | Existing fixity checks and file integrity behavior |
| **On-campus file storage** | No cloud-only storage requirement |

## Work types (locked decision)

**Keep all 8 UC curation concerns** in `config/initializers/hyrax.rb`:

| Registered name | Model | Type-specific metadata (examples) |
|-----------------|-------|-----------------------------------|
| `generic_work` | `GenericWork` | genre, college, department |
| `article` | `Article` | journal_title, issn |
| `document` | `Document` | genre |
| `dataset` | `Dataset` | genre |
| `image` | `Image` | (shared UC fields) |
| `medium` | `Medium` | (shared UC fields) |
| `student_work` | `StudentWork` | advisor, degree, genre |
| `etd` | `Etd` | advisor, degree, committee_member, etd_publisher |

Nurax (Hyrax 5 reference) uses `generic_work`, `image`, `monograph`. **Do not adopt Nurax’s type list.** Simplify deposit UI toward stock Hyrax; **never drop** type-specific fields from models, indexers, or show pages.

## Platform constraints (do not skip)

1. **No direct Fedora 4 → 7 migration.** Data must pass through **Fedora 6 OCFL**, then F6 → F7 is a drop-in on the same OCFL store.
2. **Hyrax 2.9 + ActiveFedora cannot use Fedora 6/7.** Phase B (Hyrax 5 + Valkyrie) must complete before Phase C.
3. **Wings** lets Hyrax 5 read **existing Fedora 4 objects** without bulk migration during Phase B.
4. **PostgreSQL** is required for Hyrax 5 + Valkyrie metadata **before** Valkyrie/Wings go live (Phase B3 before B4).

## Branch policy

| Branch | Role |
|--------|------|
| **`scholar-modernization`** | **All upgrade work** (Phases A–D). Every sub-phase commits here. |
| **`develop`** | Production/QA legacy line. **Do not merge upgrade work into `develop` until Fedora 7 works on scholar-dev** (after C2). Production cutover is **C3**, after that merge. |
| **`develop` → `scholar-modernization`** | Optional: merge or cherry-pick **security fixes** from production line into the feature branch. |

| Environment | Branch | When |
|-------------|--------|------|
| scholar-dev | `scholar-modernization` | Every sub-phase through C2 (F7 proven here first) |
| production / QA | `develop` | Unchanged until **after C2**, then merge + **C3** production cutover |

## What to keep vs remove

### Keep (minimal custom surface)

| Area | Key files |
|------|-----------|
| DOI | `app/models/concerns/remotely_identified_by_doi.rb`, `app/actors/hyrax/actors/mint_doi_actor.rb`, `config/initializers/hydra_remote_identifier_config.rb`, DOI views/forms/jobs, `hydra-remote_identifier` fork |
| Landing URLs | `lib/scholar.rb`, `app/controllers/common_objects_controller.rb` |
| Shibboleth | `config/initializers/devise.rb` (Shibboleth omniauth), `app/controllers/callbacks_controller.rb` (`shibboleth` action) |
| 8 work types | Models, forms, indexers, presenters, controllers under `app/` |
| Ops | ClamAV (`clamby`), fixity/embargo rake tasks, Sidekiq |

### Remove (in phase order)

| Item | Phase | Prerequisite |
|------|-------|--------------|
| Grape API (`app/api/scholar/`) | A2 | A1: no campus dependency |
| Kaltura, RSS, collection TSV export | A2 | A1 audit |
| **Sitemap** (`sitemap.xml`) | A2 only if unused | A1 audit — **default keep** (SEO / discovery); remove only with stakeholder OK |
| **Featured collections** | A2 only if unused | A1 audit — **default keep** if homepage/admin uses them; do not confuse with stock Hyrax **featured works** |
| `aws-xray-sdk` | A2 | Dev group only; remove if unused locally |
| Bulkrax | A2 | A1: confirm unused |
| ORCID fork + profile UI | A3 | — |
| `devise-multi_auth` gem | A3 | After ORCID callback removed (ORCID-only in code) |
| ChangeManager + proxy notification customizations | A4 | A1 audit |
| Custom collection logic superseded by stock Hyrax | A2/A6 | A1 audit; **keep membership data**, simplify code only |
| BrowseEverything cloud providers | A5 | A1 audit |
| Unused gems after above removals | A7 | Re-run `bundle` / grep for references |
| ActiveFedora monkey patches | B1+ | When gem versions allow |

---

## Phase A — De-customize on Hyrax 2.9 / Fedora 4

**Goal:** Smallest diff vs stock Hyrax 2.9 before gem major bumps.

**Deploy:** Each sub-phase to scholar-dev on **`scholar-modernization`** only.

### A1 — Audit and baseline (do first)

Complete the **A1 audit table** in [STATUS.md](./STATUS.md) for every row below. **Default: remove in the listed phase unless the audit finds active use.**

| Item | Where to look | Default action |
|------|---------------|----------------|
| Grape API | `app/api/scholar/`, routes, access logs, campus integrations | A2 remove if unused |
| Bulkrax | `config/initializers/bulkrax.rb`, admin UI, Sidekiq | A2 remove if unused |
| ChangeManager | `Gemfile`, `Scholar::WorksControllerBehavior`, mailers | A4 remove |
| BrowseEverything | `config/browse_everything_providers.yml`, deposit UI | A5 trim/remove cloud |
| Kaltura | `Gemfile`, views, medium deposit | A2 remove if unused |
| AWS X-Ray | `Gemfile` (development group), initializer | A2 remove if unused |
| RSS / feed | `app/services/rss_query_handler.rb`, routes | A2 remove if unused |
| Sitemap | `app/controllers/sitemaps_controller.rb`, `sitemap.xml` route, search-console usage | **Keep** unless stakeholders confirm unused |
| Featured collections | `app/models/concerns/hyrax/collections/featured.rb`, homepage/admin views | **Keep** if UI uses them; not the same as featured **works** |
| Collection TSV export | `app/models/collection_export.rb`, related UI | A2 remove if unused |
| Custom collection types / overrides | Compare to stock Hyrax 2.9 collection types; `app/controllers/hyrax/collections_controller.rb`, `basic_collection_metadata.rb` | A2/A6 simplify code; **never drop membership** |
| RemoveProxyEditors | `app/models/concerns/remove_proxy_editors.rb` | A4 evaluate vs stock |
| **Unused gem inventory** | Full `Gemfile` after above — see [Gem inventory](#gem-inventory-post-a1) | A7 remove dead gems |

**Baseline** ([INTEGRITY.md](./INTEGRITY.md)):

- Run on **scholar-dev** (currently seed data; re-run when a prod-shaped copy is available).
- Optionally capture **read-only production** Solr counts for reference when access is available—do not block A1 on prod copy.
- Commit `docs/upgrade/baseline/baseline-YYYY-MM-DD.json`.

**Exit criteria:** STATUS A1 table filled; baseline JSON committed; **no application code changes** (docs + baseline JSON only).

**A1 audit — suggested commands** (record results in STATUS):

```bash
# Grape API
rg -l 'grape|Grape|app/api/scholar' --glob '!docs/**'
# Bulkrax
rg -l 'bulkrax|Bulkrax' config app Gemfile
# ChangeManager
rg -l 'change_manager|ChangeManager' app config Gemfile
# ORCID (removed in A3; note for audit)
rg -l 'orcid|ORCID|Devise::MultiAuth' app config Gemfile
# Kaltura, X-Ray, RSS, sitemap (default keep), featured collections (default keep), collection export
rg -l 'kaltura|Kaltura' app config Gemfile
rg 'xray|XRay' Gemfile config
rg -l 'RssQueryHandler|SitemapsController|sitemap' app config
rg -l 'featured|Featured' app/models app/views app/controllers
rg -l 'CollectionExport|collection_export' app spec
# Custom collections
rg -l 'collections_controller|basic_collection_metadata|RemoveProxyEditors' app
```

Baseline counts require **Solr + Fedora** running (`rails console` on scholar-dev or local with same seed data—note which in JSON `environment` / `data_note`).

### A2 — Remove optional integrations

Remove items A1 marked safe. After each batch: `bundle install`, `bin/rspec-fast`, push for CI, scholar-dev smoke per INTEGRITY spot-check.

**Exit criteria:** CI green; no removed gem references; integrity spot-check passes.

### A3 — Remove ORCID (ordered steps)

Shibboleth does **not** use `devise-multi_auth` (custom logic in `CallbacksController#shibboleth`). Only **ORCID** uses `Devise::MultiAuth` in `CallbacksController#orcid`.

1. Remove ORCID from Devise `omniauth_providers` in `app/models/user.rb` and `config/initializers/devise.rb`.
2. Remove `CallbacksController#orcid` and ORCID routes.
3. Remove ORCID profile connect UI and `orcid` fork gem.
4. **Keep** `users.orcid` column and `devise_multi_auth_authentications` table data (historical; no user row deletes).
5. Remove `devise-multi_auth` gem from `Gemfile` and run `bundle install`.
6. Verify Shibboleth login/logout/deposit unchanged.

**Exit criteria:** No ORCID UI or routes; Shibboleth works; CI green.

### A4 — Remove ChangeManager and proxy customizations

- Remove `change_manager` gem.
- Revert proxy notification behavior in `Scholar::WorksControllerBehavior` / `depositors_controller` to stock Hyrax where possible.
- Evaluate `RemoveProxyEditors` — remove if stock Hyrax covers it.

**Exit criteria:** Stock proxy deposit; no ChangeManager references; CI green.

### A5 — Simplify BrowseEverything and batch upload

- Trim cloud providers or remove BrowseEverything if unused.
- Simplify `batch_uploads_controller` if multi-type customizations are unnecessary.

**Exit criteria:** File upload on deposit works; CI green.

### A6 — Simplify forms, views, collections (keep show metadata)

- **Forms/views:** Stock Hyrax partials where UC fields still save via form `terms`; keep DOI tab.
- **Show pages:** Keep all type-specific and collection fields visible.
- **Collections:** Remove custom collection behavior that stock Hyrax 2.9+ already provides; preserve collection membership and discovery.

**Exit criteria:** Prefer **unit/view specs** (`bin/rspec-fast`) over new feature specs; manual scholar-dev smoke per INTEGRITY matrix if deposit UI changed.

### A7 — Gem hygiene

- Keep `hydra-remote_identifier` fork until B4 port.
- Document remaining Gemfile pins in STATUS or DECISIONS.
- Remove gems confirmed unused after A2–A6.
- Fix `ExpirationService` hardcoded `api.test.datacite.org` — use env/config from `config/doi.yml`.

### Phase A exit criteria (gate before Phase B)

- [ ] A1–A7 complete on `scholar-modernization`
- [ ] Full CircleCI green
- [ ] [INTEGRITY.md](./INTEGRITY.md) full matrix passed on scholar-dev
- [ ] DOI + Shibboleth + collections spot-checks pass

---

## Phase B — Application upgrade (Fedora 4 until Phase C)

**Goal:** **Hyrax 5.2.x** with **PostgreSQL**, **Valkyrie + Wings** on **Fedora 4**.

### B1 — Ruby and Rails

| Step | Target | Notes |
|------|--------|-------|
| Ruby | 2.7 → 3.2+ (3.3+ for Hyrax 5.1+) | `.ruby-version`, CI, README |
| Rails | 5.2 → 6.1 → 7.2 | **One version hop at a time**; CI green before the next hop |
| Gems | Unpin where safe | `sqlite3`, `minitest`, `rspec`, `capybara`, etc. |

**Branching:** All hops merge back to **`scholar-modernization`**. For risky hops, use a **short-lived branch** (e.g. `upgrade/b1-rails-6.1`) and merge when CI is green—do not leave long-lived side branches. This is **not** a separate feature line from `scholar-modernization`.

Use the **Hyrax upgrade guide for the target release** of each hop—not only `main` branch docs.

Remove `lib/active_fedora/*` patches when upstream versions allow.

**Exit criteria per hop:** App boots; `bin/rspec-fast`; scholar-dev smoke.

### B2 — Hyrax intermediate hops (2.9 → 4.x)

**One Hyrax minor/major hop at a time** (same branching rule as B1—merge back to `scholar-modernization`):

1. Hyrax **2.9 → 3.x**
2. Hyrax **3.x → 4.x**

For each: read that release’s upgrade notes, run `hyrax:update_config` and documented generators, fix deprecations.

**Exit criteria per hop:** CI green; catalog search; one show page per work type.

### B3 — PostgreSQL (Rails app database)

**Do this before B4.** Hyrax 5 + Valkyrie will use PostgreSQL; migrate the **Rails app DB** first (users, roles, Hyrax admin tables, etc.).

- Add `pg` gem; migrate Rails app DB on **scholar-dev** to PostgreSQL (scholar-dev is typically MySQL like production; local **test** may stay SQLite until CI is switched—document which envs use PG in STATUS).
- Update `database.yml` and CI for PostgreSQL on the upgrade track.
- **Production** MySQL → PostgreSQL is **not** done in B3. It is part of the **C3 production cutover** (same window as deploying Hyrax 5 from `develop`), after F7 is proven on scholar-dev and `scholar-modernization` is merged to `develop`.
- **Valkyrie metadata tables** are created in **B4** when Hyrax 5 + Valkyrie generators run against the **same** PostgreSQL instance as the Rails app DB.

**Exit criteria:** App runs on PostgreSQL on scholar-dev; login and admin work; PG ready for B4 Valkyrie install.

### B4 — Hyrax 5.2 + Valkyrie + Wings + custom ports

**Final Hyrax hop**, combined with Valkyrie (not a separate phase after B2).

**Where data lives after B4 (easy to get wrong):**

| Content | Location after B4 |
|---------|-------------------|
| Legacy works (pre-upgrade objects) | Still in **Fedora 4**; Hyrax reads them through **Wings** |
| New deposits / Valkyrie resources | **PostgreSQL** (Valkyrie metadata) + binaries per Hyrax 5 config (often still Fedora until Phase D) |
| Users, roles, admin tables | **PostgreSQL** (Rails app DB from B3) |
| Catalog | **Solr** (reindex in B5) |

Do **not** decommission Fedora in B4. Wings exists so Phase B can finish **without** a repository migration (that is Phase C).

1. Hyrax **4.x → 5.2.x** on PostgreSQL.
2. `rails generate hyrax:work_resource` for **each of 8 types**; metadata YAML:
   - Shared: `config/metadata/uc_common.yaml`
   - Per-type: e.g. `config/metadata/etd.yaml`
3. Enable **Wings** for legacy Fedora 4 objects.
4. Re-port **DOI** (actors, jobs, metadata terms).
5. Re-port **Shibboleth** (`CallbacksController`, user attributes).
6. **DOI spike:** On a **throwaway branch off `scholar-modernization`**, during **first successful Hyrax 5.2 boot** (this sub-phase—not before Phase B, not during Phase A). Goal: confirm `hydra-remote_identifier` fork or port path. Record findings in STATUS/DECISIONS; merge only spike fixes needed for B4—discard experimental code otherwise.

**Exit criteria:** All 8 types in catalog via Wings; deposit/edit/show/download; DOI + Shibboleth on Hyrax 5.

### B5 — Solr reindex

- Full reindex after Valkyrie indexers.
- Verify facets: college, department, `human_readable_type` for all 8 types.

### Phase B exit criteria (gate before Phase C)

- [ ] Hyrax 5.2.x + PostgreSQL + Wings on scholar-dev reading **all works from F4**
- [ ] Full INTEGRITY verification
- [ ] DOI + Shibboleth on Hyrax 5

---

## Phase C — Fedora migration (infosec: Fedora 7)

**Cannot start until Phase B complete.**

### Order (do not invert)

```text
C1  scholar-dev: F4 → F6 (two dry runs)
C2  scholar-dev: F6 → F7  ← F7 must work HERE before any merge to develop
    ── merge scholar-modernization → develop (first time upgrade code hits production line)
C3  production cutover: deploy from develop + F4 → F6 → F7 + app DB MySQL → PG
```

**Why this order:** Production cannot run Hyrax 5 / Wings / F6–F7 until upgrade code is on `develop`. The branch rule is **prove Fedora 7 on scholar-dev first**, then merge, then cut production over. Do **not** attempt a production Fedora migration while production is still on Hyrax 2.9 / `develop` legacy.

### C1 — Fedora 6 on scholar-dev (F4 → F6)

1. Stand up **Fedora 6.5.x** (OCFL).
2. Export/import via [fcrepo-import-export](https://github.com/fcrepo/fcrepo-import-export) or community runbook.
3. Full [INTEGRITY.md](./INTEGRITY.md) verification including FileSets and collections.
4. Point Hyrax 5 Valkyrie Fedora adapter at F6.
5. **Two dry runs** on scholar-dev before C2.

**Exit criteria:** scholar-dev on F6; integrity pass; F4 snapshot retained for rollback practice.

### C2 — Fedora 6 → 7 on scholar-dev (prove F7)

1. Deploy **fcrepo-7.x** on the **same OCFL store** as F6 (drop-in; not a second data migration).
2. Java 21; Tomcat 10+ or Jetty 12 per Fedora 7 requirements.
3. Re-run full integrity + DOI landing URLs (`/show/:id`).

**Exit criteria (merge gate):**

- [ ] scholar-dev on **Fedora 7**
- [ ] Full INTEGRITY matrix green
- [ ] Zero undisplayable works on scholar-dev
- [ ] **Then** coordinated merge **`scholar-modernization` → `develop`** is allowed

### C3 — Production cutover (after merge to `develop`)

Single coordinated window (runbook in STATUS before starting):

1. **App:** Deploy Hyrax 5 stack from `develop`; migrate production **MySQL → PostgreSQL** (Rails app DB; same approach rehearsed on scholar-dev in B3).
2. **Repository:** F4 read-only → export → F6 import → verify → F6 → F7 on same OCFL store.
3. **Solr:** full reindex; spot-check all 8 types, collections, FileSets, DOI, Shibboleth.
4. Keep **F4 snapshot** and DB backup until sign-off; rollback owner and time limit recorded in STATUS.

**Exit criteria (infosec milestone):**

- [ ] Production on **Fedora 7** with infosec sign-off
- [ ] Zero undisplayable works
- [ ] DOI + Shibboleth + permanent URLs verified in production

### Phase C exit criteria

C2 (scholar-dev F7 + merge) **and** C3 (production F7) both complete.

---

## Phase D — PostgreSQL-only persistence

By Phase D, **users/roles** and **some** Valkyrie metadata are already in PostgreSQL (B3–B4). What remains in Fedora is primarily **legacy object graphs and/or binaries** still reached via the Fedora adapter.

1. Migrate remaining work metadata from Fedora 7 → PostgreSQL (Valkyrie)—background/lazy is fine if counts stay correct.
2. Move files to on-campus disk (Active Storage or Valkyrie disk adapter).
3. Reindex Solr; update DOI landing URLs only if paths change.
4. Decommission Fedora 7 only when **nothing** reads it (moving-parts rule).
5. **Keep Redis** while Sidekiq (or equivalent) still uses it—Phase D does **not** remove the job backend.

### Phase D exit criteria

- [ ] All works served from PostgreSQL + on-campus files; Fedora stopped
- [ ] Redis retained unless jobs no longer need it (separate decision)

---

## Verification (every slice)

See [INTEGRITY.md](./INTEGRITY.md). Minimum: counts, spot-check matrix, DOI (if touched), Shibboleth (if touched), `bin/rspec-fast` + CI.

---

## Gem inventory (post-A1)

Track in STATUS during A1/A7. Remove when audit confirms unused.

| Gem / area | Typical fate | Notes |
|----------|--------------|-------|
| `grape`, `grape_on_rails_routes` | A2 remove | After API audit |
| `bulkrax` | A2 remove if unused | |
| `change_manager` | A4 remove | |
| `orcid`, `devise-multi_auth` | A3 remove | ORCID first, then multi_auth |
| `kaltura` | A2 remove | |
| `aws-xray-sdk` | A2 remove | Development group only |
| `browse-everything` | A5 trim/remove | Pin 1.1.0 for Hyrax 2.x if kept |
| `riiif` | Keep until B4 | Re-evaluate on Hyrax 5 |
| `hydra-role-management` | Keep | Required |
| `sidekiq-limit_fetch` | Keep until B | Re-evaluate on Sidekiq 7 |
| `hydra-remote_identifier` | Keep until B4 port | Fork |
| `okcomputer` | Keep | Health checks |
| `clamby` | Keep | Virus scan |

---

## Risks

| Risk | Mitigation |
|------|------------|
| F4→F6 data loss | Baseline + checksums; two dry runs on scholar-dev |
| DOI fork on Hyrax 5 | B4 throwaway-branch spike at first Hyrax 5 boot |
| Infosec timeline vs Phase B | Run A while researching B; escalate if B slips |
| scholar-dev seed vs prod shape | Baseline on dev now; re-baseline when prod copy exists |
| 8 types on Valkyrie | Shared `uc_common.yaml`; generator per type in B4 |
| Production big-bang (C3) | Rehearse app+PG+F6+F7 on scholar-dev; written runbook + rollback owner |

---

## Common mistakes (read before coding)

| Mistake | Correct approach |
|---------|------------------|
| Merge to `develop` so production can “try” F6 early | Prove **F7 on scholar-dev (C2)** first, **then** merge, **then** C3 |
| Start Phase C while still on Hyrax 2.9 | Phase B (Hyrax 5 + Wings) must finish first—AF cannot use F6/F7 |
| Treat B4 as “Fedora is gone” | B4 still uses Fedora via Wings; Phase D removes Fedora |
| Migrate production MySQL in B3 | B3 = scholar-dev (and CI) only; production PG is **C3** |
| Remove sitemap/featured collections by default | **Keep** unless A1 proves unused |
| Drop a work type or type-specific show field | Never—keep all 8 types and displayable metadata |
| Delete `users.orcid` or auth rows in A3 | Remove ORCID **UI/gems only**; keep historical columns/data |
| Remove Redis because “end state is PostgreSQL” | Redis stays for Sidekiq until jobs do not need it |
| Implement cancelled `Scholar::Record` / `lib/scholar/` export stack | Cancelled; only `lib/scholar.rb` permanent URLs stay |
| Skip INTEGRITY because “only a gem remove” | Any slice that can affect works/auth/DOI still needs checks |

---

## Out of scope

- Strangler `Scholar::Record` stack
- Collapsing 8 types to Nurax’s 3
- Fedora 7 without F6 OCFL
- Merging to `develop` before Fedora 7 works **on scholar-dev**
- Production Fedora migration before Hyrax 5 is on `develop`
- Eight bespoke deposit wizards on Hyrax 5

## Next slices

1. **A1** — Audit + baseline on scholar-dev
2. **A2** — Remove confirmed-unused integrations
3. **B4 DOI spike** — throwaway branch at first Hyrax 5.2 boot (during B4, not before)
