# Workflow

## Two machines (desktop + laptop)

Both use the **same git remote** and branch. Docs in `docs/modernization/` sync via git—especially [STATUS.md](./STATUS.md).

### Daily pattern

```bash
# Start of session (either machine)
git checkout scholar-modernization
git pull origin scholar-modernization

# If develop had important changes since last merge:
git fetch origin
git merge origin/develop
# resolve conflicts, run tests, deploy to scholar-dev if needed

# End of session
git add -A
git commit -m "Phase N: short description"
git push origin scholar-modernization
```

**Always push** at end of a session so the other machine (and future Cursor sessions) see the same code and STATUS.

### Never commit

- `.env`, credentials, secrets, production passwords
- `node_modules/` (keep untracked; use `.gitignore` if needed)

## Cursor AI sessions

### Start prompt (copy/paste template)

```text
Scholar modernization on branch scholar-modernization.
Read docs/modernization/STATUS.md and PLAN.md first.
Follow moving-parts rule; scholar-dev only; one slice from current phase.
Update STATUS.md when done.
```

### End of session

- Update [STATUS.md](./STATUS.md): date, machine optional, what finished, what's next, blockers
- Commit docs with code when possible

Different Cursor instances **do not share chat memory**—only git + these files.

## Branch policy

| Branch | Purpose |
|--------|---------|
| `develop` | Legacy Scholar; prod/QA; security fixes allowed |
| `scholar-modernization` | All modernization work |

- Merge direction: **`develop` → `scholar-modernization`**
- Feature → `develop`: only at **cutover** (or emergency cherry-pick process)

### When to merge develop

- Weekly cadence, or
- After security / bundler-audit fixes on `develop`, or
- Before starting a new phase

After merge: run tests, smoke scholar-dev, note merge in STATUS.

## Deployments

| Target | Branch | Who |
|--------|--------|-----|
| scholar-dev | `scholar-modernization` | You, when a slice is ready to test |
| production / QA | `develop` | Not modernization branch until cutover |

Document deploy steps for scholar-dev in STATUS when they differ from usual Capistrano/ansible (whatever UC uses).

## Commits

- One logical slice per commit when possible
- Prefix with phase: `Phase 0: add export manifest rake task`
- Do not ask AI to `git push` unless you explicitly request it

## Cutover (future)

Document in STATUS when approaching Phase 6:

1. Scholar read-only (prod)
2. Final export + delta import
3. Deploy `scholar-modernization` → production path
4. Update DataCite landing URLs
5. Smoke tests + rollback plan

## Troubleshooting sync

If STATUS and code disagree, **trust git + STATUS date**. If chat contradicts docs, **docs win**.
