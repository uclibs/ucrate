# Data integrity verification

**Principle:** No work may become undiscoverable or lose displayable metadata, files, or collection membership during any upgrade slice.

Run checks when a slice touches Fedora, Solr, work types, FileSets, collections, DOI, or auth. Phase A1 establishes the **baseline**; later slices compare against it.

## Baseline environment

| Environment | Use |
|-------------|-----|
| **scholar-dev** | Primary baseline and per-slice checks (currently **seed data**). UC dev deployment; not necessarily your laptop. |
| **Local dev** | Acceptable for A1 baseline **if** Fedora + Solr are running and `data_note` in JSON explains local vs scholar-dev. |
| **Production (read-only)** | Optional reference counts when accessible; goal is a **prod-shaped copy** on scholar-dev later—re-baseline when that exists. |

Do not block Phase A on a full production clone. Document in STATUS which environment the baseline used.

## Baseline (Phase A1 — required once)

### 1. Solr counts by work type

In `rails console` with Solr up (Fedora must be up for sample ID lookup). Same Solr query pattern as `app/controllers/sitemaps_controller.rb`:

```ruby
types = Hyrax.config.registered_curation_concern_types
# => ["generic_work", "article", ...] — keys from config/initializers/hyrax.rb
counts = {}
types.each do |t|
  klass = t.classify  # e.g. "generic_work" => "GenericWork"
  n = ActiveFedora::SolrService.query(
    "has_model_ssim:#{klass}",
    rows: 0
  ).response['numFound']
  counts[t] = n
  puts "#{t}: #{n}"
end
puts "total works: #{counts.values.sum}"
```

### 2. FileSet count (optional)

```ruby
ActiveFedora::SolrService.query('has_model_ssim:FileSet', rows: 0).response['numFound']
```

### 3. Collection count (optional)

```ruby
ActiveFedora::SolrService.query('has_model_ssim:Collection', rows: 0).response['numFound']
```

### 4. DOI count (optional)

DOI is indexed as `stored_searchable` (`doi_tesim`), not `doi_ssim`:

```ruby
ActiveFedora::SolrService.query("#{Solrizer.solr_name('doi')}:*", rows: 0).response['numFound']
# Or: ActiveFedora::SolrService.query('doi_tesim:*', rows: 0).response['numFound']
```

### 5. Sample IDs

Save at least one **public** work ID per type under `sample_ids` for repeat spot-checks. Include one work **in a collection** if any exist.

### 6. Commit baseline JSON

Save to `docs/upgrade/baseline/baseline-YYYY-MM-DD.json`:

```json
{
  "date": "2026-07-03",
  "environment": "scholar-dev",
  "data_note": "seed data; re-baseline when prod-shaped copy available",
  "solr_by_type": {
    "generic_work": 0,
    "article": 0,
    "document": 0,
    "dataset": 0,
    "image": 0,
    "medium": 0,
    "student_work": 0,
    "etd": 0
  },
  "solr_total_works": 0,
  "solr_fileset_count": null,
  "solr_collection_count": null,
  "solr_doi_count": null,
  "fedora_object_count": null,
  "sample_ids": {
    "generic_work": null,
    "article": null,
    "document": null,
    "dataset": null,
    "image": null,
    "medium": null,
    "student_work": null,
    "etd": null,
    "work_in_collection": null
  },
  "notes": ""
}
```

Fill `fedora_object_count` from Fedora API or export tool when available.

## Per-slice verification

### Count check

- Re-run Solr counts by type (and FileSets/collections if baseline included them).
- **Pass:** matches baseline, OR delta documented in STATUS with cause.

### Spot-check matrix (works)

For each work type, verify one work (use `sample_ids` when possible):

| Check | Pass? |
|-------|-------|
| Catalog search finds work by title | |
| Show page loads | |
| Title and creators display | |
| Type-specific fields (ETD advisor, Article journal_title, etc.) | |
| File download (if work has files) | |
| `/show/:id` permanent URL resolves | |

### FileSets

| Check | Pass? |
|-------|-------|
| Download file from a work with attachments | |
| Representative image/media displays if applicable | |

### Collections

| Check | Pass? |
|-------|-------|
| Collection show lists member works | |
| Work show shows collection membership (if in collection) | |
| Search/browse within collection (if UI exists) | |

### Visibility

| Check | Pass? |
|-------|-------|
| One **embargoed** work shows appropriate visibility | |
| One **restricted** work respects permissions | |
| DOI link resolves (if work has DOI) | |

### DOI flows (when DOI code changed)

| Flow | Verify |
|------|--------|
| Mint on publish | New deposit with auto-DOI |
| Manual DOI | Deposit with existing identifier |
| Embargo release | `IdentifierEmbargoUpdateJob` |
| Destroy / withdraw | `IdentifierDeleteJob` |

Use DataCite **sandbox** on scholar-dev unless ops specifies otherwise.

### Auth (when auth changed)

- Shibboleth login, logout, new user provisioning (if test account available).

## Phase gates (full verification)

Run full baseline comparison + matrix + DOI + auth before:

- Phase A → Phase B
- Phase B → Phase C
- Phase C production cutover
- Phase D Fedora decommission

## Fedora migration (Phase C)

Additional checks:

1. Export checksums match files on disk
2. F6 object count ≥ F4 count (document expected differences)
3. Random sample: 20 works by type — metadata diff F4 vs F6
4. File fixity: download + checksum sample FileSets
5. Permissions on restricted works
6. Collection membership preserved

Dry-run on scholar-dev **twice** before production.

## Rollback (Phase C2)

- F4 read-only snapshot until sign-off
- Rollback: repoint Hyrax to F4, reindex Solr
- Record rollback owner and time limit in STATUS

## When verification fails

1. **Stop** — do not proceed to next phase or merge to `develop`
2. Document in STATUS (work ID, type, failure)
3. Fix or revert slice
4. Re-run full matrix

## Automation (Phase A1 optional)

Consider rake tasks `scholar:integrity:counts` and `scholar:integrity:spot_check[id]` — optional; console steps above are sufficient initially. Prefer **unit specs** for any automation (see [TESTING.md](./TESTING.md)).
