# Local macOS docs (hyku-oob, no Docker)

**Start here** for Scholar@UC work on the `hyku-oob` branch. The repo root [README.md](../../README.md) is Samvera Hyku’s upstream README and will change when we merge from Hyku — our guides live only under `docs/local/`.

| Doc | Contents |
|-----|----------|
| [versions-and-ports.md](./versions-and-ports.md) | Version targets; dev vs test ports |
| [check-your-machine.md](./check-your-machine.md) | What is already installed |
| [install.md](./install.md) | Homebrew, Postgres, Ruby, gems |
| [environment.md](./environment.md) | `.env.local.mac` setup |
| [run-the-app.md](./run-the-app.md) | Solr/Fedora/Redis + Rails + Sidekiq |
| [run-tests.md](./run-tests.md) | Optional local RSpec / `rake ci` |
| [switching-to-develop.md](./switching-to-develop.md) | Switching back to Scholar@UC `develop` |
| [troubleshooting.md](./troubleshooting.md) | Common failures |
| [updating-from-hyku.md](./updating-from-hyku.md) | Pulling Hyku updates with a normal `git merge` |

## Quick start

1. [install.md](./install.md) → [environment.md](./environment.md)
2. [run-the-app.md](./run-the-app.md) → http://localhost:3000
3. Tests only when you need them: [run-tests.md](./run-tests.md)

<!-- trivial change for PR/CI process smoke test -->
