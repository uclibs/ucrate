# Upgrade workflow

## Terms

- **Slice:** one sub-phase (e.g. A2) or a scoped portion documented in STATUS. Default: **one sub-phase per session**.
- **scholar-dev:** UC development deployment (see [ARCHITECTURE.md](./ARCHITECTURE.md)); not the same as “my laptop” unless STATUS says so.

## Branches

| Branch | Purpose |
|--------|---------|
| **`scholar-modernization`** | **All upgrade work** (Phases A–D). Every commit for this effort lands here. |
| **`develop`** | Production/QA legacy line (Hyrax 2.9 + F4). **Do not merge upgrade work into `develop` until Fedora 7 is working** on scholar-dev and cutover is planned. |

### Allowed git flows

```text
develop ──(optional security fixes)──► scholar-modernization
                                              │
                                              ▼
                                        scholar-dev deploys
                                              │
         (after Phase C / Fedora 7)           │
scholar-modernization ───────────────────────► develop
                                              │
                                              ▼
                                        production cutover
```

- **OK:** Merge or cherry-pick **`develop` → `scholar-modernization`** for production-line security fixes.
- **Not OK:** Merge **`scholar-modernization` → `develop`** before Fedora 7 validation (Phase C exit).

## Environments

| Environment | Branch | Stack |
|-------------|--------|--------|
| scholar-dev | `scholar-modernization` | Current upgrade sub-phase |
| QA / production | `develop` | Legacy until post–F7 cutover |

## Per-session workflow

1. `git checkout scholar-modernization` and pull.
2. Optionally merge latest `develop` for security fixes.
3. Read [STATUS.md](./STATUS.md) and [PLAN.md](./PLAN.md) — implement **one slice** only.
4. Code + tests per [TESTING.md](./TESTING.md).
5. Integrity checks per [INTEGRITY.md](./INTEGRITY.md) when applicable.
6. Update [STATUS.md](./STATUS.md).
7. Commit: `Phase A2: remove Grape API` (prefix with sub-phase).
8. Push; CircleCI runs full suite.

## Deploy

- **scholar-dev:** after each sub-phase when CI green and spot-checks pass.
- **Production:** only after **`scholar-modernization` → `develop`** merge post–Fedora 7.

## Cursor prompts (examples)

**Start session**

> Read `docs/upgrade/STATUS.md` and `PLAN.md`. We are on sub-phase [X]. Implement only that slice.

**End session**

> Update STATUS.md with today’s work, blockers, and next steps. Run `bin/rspec-fast` on changed areas.

**Integrity slice**

> This touches Solr/works. Run INTEGRITY count check and document in STATUS.

## Commit message format

```text
Phase A3: remove ORCID and devise-multi_auth

- Remove ORCID routes and gem; keep users.orcid column
- Shibboleth unchanged (no multi_auth)
```

## Definition of done (one slice)

- [ ] Scope matches current sub-phase in PLAN
- [ ] Naming per `.cursor/rules/scholar-naming-conventions.mdc`
- [ ] `bundle exec rubocop` on changed Ruby files
- [ ] `bin/rspec-fast` (prefer unit specs over new feature specs)
- [ ] INTEGRITY checks if slice touches data/auth/DOI
- [ ] STATUS.md updated
- [ ] CI green on push
