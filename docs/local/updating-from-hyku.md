# Updating from Samvera Hyku (protecting our docs)

**Problem:** Hyku’s root `README.md` and some files under `docs/` change over time. Our UC setup lives in the root `README.md` (index) and `docs/local/`. A plain `git merge hyku/main` can **silently replace** our root `README.md` whenever only upstream changed that file — even if you never notice a conflict.

**Solution:** keep UC content out of Hyku’s paths where possible, and always merge through a helper that restores our README while saving theirs.

## Where things live

| Path | Who owns it | On Hyku merge |
|------|-------------|-----------------|
| `README.md` (repo root) | **UC** (index into `docs/local/`) | Preserved by [`bin/merge-hyku`](../../bin/merge-hyku) |
| `docs/local/**` | **UC** | Untouched (Hyku does not ship this tree) |
| `docs/upstream/README.md` | Snapshot of **Hyku’s** README | Refreshed by `bin/merge-hyku` |
| `docs/getting-started.md`, `docs/configuration.md`, … | **Hyku** | Merged normally — you get their updates |
| `.env`, Docker files, app code | **Hyku** (+ our later customizations) | Merged normally |

## How to pull Hyku updates (use this every time)

Do **not** run a bare `git merge hyku/main` for routine upgrades.

```bash
git checkout hyku-oob   # or your branch based on it
bin/merge-hyku          # defaults to hyku/main
# or: bin/merge-hyku hyku/v6.2.0
```

What the script does:

1. `git fetch hyku`
2. Merges the ref you named
3. Writes Hyku’s `README.md` → `docs/upstream/README.md`
4. Puts our UC `README.md` back at the repo root
5. Commits that restore/refresh when needed

If there are conflicts in **other** files, resolve them as usual. Do not accept upstream’s root `README.md` as ours.

## Why `.gitattributes` alone is not enough

We set `README.md merge=ours` so **conflict** resolutions keep our file. That does **not** help when only Hyku changed `README.md` — Git then takes their version with no conflict. The script covers that case.

## After the merge

- Skim `docs/upstream/README.md` and Hyku’s updated `docs/*.md` for new upstream guidance.
- Keep UC procedures in `docs/local/` — do not paste long UC guides back into the root README or into Hyku-owned doc files.
