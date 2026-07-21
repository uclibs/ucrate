# Updating from Samvera Hyku

Our UC setup docs live only under **`docs/local/`**. The root `README.md` is Hyku’s and should stay that way so a normal merge works.

## Where things live

| Path | Who owns it | On `git merge hyku/main` |
|------|-------------|---------------------------|
| `README.md` (repo root) | **Hyku** | Updates normally — do not put UC guides here |
| `docs/local/**` | **UC** | Untouched (Hyku does not ship this tree) |
| `docs/getting-started.md`, `docs/configuration.md`, … | **Hyku** | Updates normally |
| App code, `.env`, Docker files | **Hyku** (+ our later customizations) | Merged normally |

## How to pull Hyku updates

Use a normal merge (no special helper):

```bash
git checkout hyku-oob   # or your branch based on it
git fetch hyku
git merge hyku/main
# or: git merge hyku/v6.2.0
```

Resolve any conflicts in app code or Hyku-owned docs as usual. Leave root `README.md` as Hyku’s version.

## After the merge

- Skim Hyku’s updated `docs/*.md` / root README for new upstream guidance.
- Keep UC procedures in `docs/local/` only — do not copy them into the root README (they would be wiped on the next merge).
- Check `.github/workflows/verify_labels.yml`: we keep it **main-only** so feature PRs into `hyku-oob` do not need release labels. If the merge restores `branches: ['**']`, put the main-only filter back ([github-actions.md](./github-actions.md)).
