# Updating from Samvera Hyku

Our UC setup docs live under **`docs/local/`**. Keep detailed UC procedures there.

**Canonical inventory of every Scholar@UC customization vs Hyku** (what to keep on merge, conflicts, why):  
**[uc-hyku-customizations.md](./uc-hyku-customizations.md)**  
(CI enforces the companion [uc-hyku-customizations.manifest.yml](./uc-hyku-customizations.manifest.yml).)

We also keep a **short Scholar@UC pointer** at the top of the root `README.md` (links to `docs/local/` and `.env.local.mac.example`). Upstream Hyku merges may overwrite that pointer — put it back after a merge if it disappears.

## Where things live

| Path | Who owns it | On `git merge hyku/main` |
|------|-------------|---------------------------|
| `README.md` (repo root) | **Hyku** + short UC pointer at top | Hyku content updates; re-add the UC pointer if lost |
| `docs/local/**` | **UC** | Untouched (Hyku does not ship this tree) |
| `.env.local.mac.example` | **UC** (local no-Docker template) | Keep ours; do not replace with Docker `.env` |
| `.envrc` | **UC** (direnv → `.env.local.mac`) | Keep ours |
| `docs/getting-started.md`, `docs/configuration.md`, … | **Hyku** | Updates normally |
| App code, `.env`, Docker files | **Hyku** (+ our later customizations) | Merged normally — see [uc-hyku-customizations.md](./uc-hyku-customizations.md) for the full list |

For CI workflows, security gems, wrapper shims, flaky-spec patches, and sample seeds, use the inventory — do not rely on this short table alone.

## How to pull Hyku updates

Use a normal merge (no special helper):

```
git checkout hyku-oob   # or your branch based on it
git fetch hyku
git merge hyku/main
# or: git merge hyku/v6.2.0
```

Resolve any conflicts in app code or Hyku-owned docs as usual.

## After the merge

- Skim Hyku’s updated `docs/*.md` / root README for new upstream guidance.
- Confirm the short Scholar@UC pointer is still at the top of root `README.md`; restore it if the merge removed it.
- Keep detailed UC procedures in `docs/local/` only.
- Check `.github/workflows/verify_labels.yml`: we keep it **main-only** so feature PRs into `hyku-oob` do not need release labels. If the merge restores `branches: ['**']`, put the main-only filter back ([github-actions.md](./github-actions.md)).
