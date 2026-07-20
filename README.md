# Hyku (`hyku-oob`)

This branch is stock [Samvera Hyku](https://github.com/samvera/hyku), kept beside our Scholar@UC history so we can upgrade toward current Hyku and later merge into `develop` / `main`.

**Instructions below are for `hyku-oob` only.** They are not the same as running the `develop` branch.

| | `develop` (Scholar@UC) | `hyku-oob` (this branch) |
|---|---|---|
| Ruby | 2.7.8 | **3.3+** (3.3.x recommended) |
| Database | MySQL | **PostgreSQL** |
| Jobs | Sidekiq | Sidekiq by default locally |
| App | Custom Scholar@UC | Upstream Hyku |

---

## Local setup (macOS, no Docker)

| I want to… | Go here |
|------------|---------|
| See required versions and ports | [docs/local/versions-and-ports.md](./docs/local/versions-and-ports.md) |
| Check what is already on my Mac | [docs/local/check-your-machine.md](./docs/local/check-your-machine.md) |
| Install dependencies (Homebrew, Postgres, Ruby, gems) | [docs/local/install.md](./docs/local/install.md) |
| Configure `.env.local.mac` | [docs/local/environment.md](./docs/local/environment.md) |
| **Run the app locally** | [docs/local/run-the-app.md](./docs/local/run-the-app.md) |
| **Run tests locally** (optional; can take a long time) | [docs/local/run-tests.md](./docs/local/run-tests.md) |
| Switch back to `develop` | [docs/local/switching-to-develop.md](./docs/local/switching-to-develop.md) |
| Troubleshoot | [docs/local/troubleshooting.md](./docs/local/troubleshooting.md) |
| Browse all local docs | [docs/local/README.md](./docs/local/README.md) |
| **Pull updates from Samvera Hyku** (preserves our README) | [docs/local/updating-from-hyku.md](./docs/local/updating-from-hyku.md) · [`bin/merge-hyku`](./bin/merge-hyku) |

Quick start once dependencies are installed:

1. `cp .env.local.mac.example .env.local.mac` and set `DB_USER` ([details](./docs/local/environment.md))
2. Follow [run the app](./docs/local/run-the-app.md) (Fedora **8984**, Solr **8983**, Redis, Sidekiq, Rails → http://localhost:3000)

---

## Upstream Hyku docs

Hyku’s own root README (as last captured from the `hyku` remote) is saved at [docs/upstream/README.md](./docs/upstream/README.md) so merges can update it **without** overwriting our UC index above. Use [`bin/merge-hyku`](./bin/merge-hyku) when pulling from Samvera — see [updating-from-hyku.md](./docs/local/updating-from-hyku.md).

| Topic | Link |
|-------|------|
| Hyku’s README (snapshot) | [docs/upstream/README.md](./docs/upstream/README.md) |
| Getting started (Docker-oriented) | [docs/getting-started.md](./docs/getting-started.md) |
| Configuration | [docs/configuration.md](./docs/configuration.md) |
| Using Hyku | [docs/using-hyku.md](./docs/using-hyku.md) |
| Support | [docs/support.md](./docs/support.md) |
| Docs wiki | [docs/wiki](./docs/wiki) |

---

## Acknowledgments

Hyku was developed by the Hydra-in-a-Box Project (DPLA, DuraSpace, and Stanford University) under a grant from IMLS, and is maintained by the [Samvera](http://samvera.org/) community.
