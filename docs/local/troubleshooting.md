# Troubleshooting (local macOS, no Docker)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

| Symptom | Likely cause | Fix |
|---|---|---|
| `psql: command not found` | Postgres not installed or not on PATH | [install.md](./install.md) Step A/B; PATH for **your** version only |
| `pg_isready` fails / connection refused | Server not running | Start **existing** version ([install.md](./install.md) Step C); don’t install a second copy |
| Port 5432 already in use when starting brew Postgres | Another Postgres already running | `lsof -i :5432`; use that server instead |
| `role "postgres" does not exist` | Homebrew user is your macOS name, not `postgres` | [install.md](./install.md) Step D; set `DB_USER` to `whoami` |
| `database "hyku" does not exist` | Hyku DBs not created yet | [install.md](./install.md) Step E |
| `fcrepo_wrapper: command not found` | Not using Bundler | `bundle exec fcrepo_wrapper` from the project root after `bundle install` |
| Unable to locate a Java Runtime / wrong Java | JAVA_HOME not 8 | `export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"` |
| DB connection errors from Rails | Wrong `DB_*` or Postgres not running | Re-check [install.md](./install.md) Steps C–E and [environment.md](./environment.md) |
| Solr/Fedora connection errors (app) | Dev wrappers not up, or Docker `.env` hosts loaded | Confirm ports **8983/8984**; **unset** `SOLR_URL` / `FCREPO_HOST` if they point at `solr`/`fcrepo` |
| Specs can’t reach Solr/Fedora | Using dev ports, or test wrappers down | Test ports are **8985/8986**; see [run-tests.md](./run-tests.md) |
| Specs fail after using develop’s Fedora **8080** | Wrong test Fedora port on this branch | Use **8986** (`config/fcrepo_wrapper_test.yml`) |
| Sidekiq Redis errors | Redis down or Redis &lt; 6.2 | `redis-cli ping`; `brew upgrade redis` |
| Seeds fail | Solr/Fedora not ready | Start wrappers first, wait, re-run `db:seed` |
| Solr fails with spaces in path | Known Solr limitation | Move the repo to a path without spaces |
| Port already in use | Old wrapper/server still running | `lsof -i :3000`, `:8983`, `:8984`, `:8985`, `:8986`, `:6379` |

## Related

- [Versions and ports](./versions-and-ports.md)
- [Run the app](./run-the-app.md)
- [Run tests](./run-tests.md)
