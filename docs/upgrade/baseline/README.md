# Baseline snapshots

Store Solr/Fedora count snapshots here for data integrity comparisons during the upgrade.

**Naming:** `baseline-YYYY-MM-DD.json` (commit to git)

See [INTEGRITY.md](../INTEGRITY.md) for the full JSON schema and console commands.

## Environment notes

| Source | When to use |
|--------|-------------|
| **scholar-dev (seed data)** | Phase A1 now — establishes first baseline |
| **scholar-dev (prod-shaped copy)** | Re-baseline when ops provides a full prod duplicate |
| **Production (read-only)** | Optional reference counts in `notes` field; do not block A1 |

Document `environment` and `data_note` in the JSON file.

Phase A1 creates the first baseline **before** any de-customization code changes.

**Required fields:** `solr_by_type`, `solr_total_works`, `solr_fileset_count`, `solr_collection_count`, and `solr_doi_count` (use `0` when none). `sample_ids` may be `null` per type when seed data has no works of that type—note that in `data_note`.
