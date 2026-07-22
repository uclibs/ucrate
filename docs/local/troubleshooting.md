# Troubleshooting (local macOS, no Docker)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

| Symptom | Likely cause | Fix |
|---|---|---|
| `psql: command not found` | Postgres not installed or not on PATH | [dependencies/02-postgresql.md](./dependencies/02-postgresql.md) check/install; PATH for **your** version only |
| `SELECT current_user;` fails for both default and `-U postgres` | Role/login mismatch | Run `whoami` and `psql -d postgres -c '\du'`, then pick an existing role for `DB_USER` in `.env.local.mac` |
| `pg_isready` fails / connection refused | Server not running | Start **existing** version ([dependencies/02-postgresql.md](./dependencies/02-postgresql.md)); don’t install a second copy |
| Port 5432 already in use when starting brew Postgres | Another Postgres already running | `lsof -i :5432`; use that server instead |
| `role "postgres" does not exist` | Homebrew user is your macOS name, not `postgres` | [dependencies/02-postgresql.md](./dependencies/02-postgresql.md); set `DB_USER` to `whoami` |
| `database "hyku" does not exist` | Hyku DBs not created yet | [dependencies/02-postgresql.md](./dependencies/02-postgresql.md) |
| `fcrepo_wrapper: command not found` | Not using Bundler | `bundle exec fcrepo_wrapper` from the project root after `bundle install` |
| Unable to locate a Java Runtime / wrong Java | Java 8 missing or not active in the Fedora terminal | Use [Java 8 quick fix](#java-8-quick-fix) |
| DB connection errors from Rails | Wrong `DB_*` or Postgres not running | Re-check [dependencies/02-postgresql.md](./dependencies/02-postgresql.md) and [environment.md](./environment.md) |
| `corepack: command not found` | Corepack is not installed/enabled in your Node setup | Run `npm install -g corepack`, then continue Node/Yarn setup in [dependencies/06-node-yarn.md](./dependencies/06-node-yarn.md) |
| `yarn install` fails with `command not found: if` / `fi` or `No matches found: "../config/uv/*"` | Yarn 4 is not supported on this branch | Use Node 20 LTS and Yarn 1 Classic: `corepack prepare yarn@1.22.22 --activate`, confirm `yarn -v` is `1.22.x`, then re-run `yarn install` |
| Solr/Fedora connection errors (app) | Dev wrappers not up, or Docker `.env` hosts loaded | Confirm ports **8983/8984**; **unset** `SOLR_URL` / `FCREPO_HOST` if they point at `solr`/`fcrepo` |
| Specs can’t reach Solr/Fedora | Using dev ports, or test wrappers down | Test ports are **8985/8986**; see [run-tests.md](./run-tests.md) |
| Specs fail after using develop’s Fedora **8080** | Wrong test Fedora port on this branch | Use **8986** (`config/fcrepo_wrapper_test.yml`) |
| `redis-cli` not found | Redis missing from PATH, stale shell cache, or incomplete install | Use [Redis CLI quick fix](#redis-cli-quick-fix) |
| Sidekiq Redis errors | Redis down or Redis &lt; 6.2 | `redis-cli ping`; `brew upgrade redis` |
| Seeds fail | Solr/Fedora not ready | Start wrappers first, wait, re-run `db:seed` |
| Solr fails with spaces in path | Known Solr limitation | Move the repo to a path without spaces |
| Port already in use | Old wrapper/server still running | `lsof -i :3000`, `:8983`, `:8984`, `:8985`, `:8986`, `:6379` |

## Redis CLI quick fix

1. Check whether Homebrew installed Redis:

```bash
brew list --versions redis
```

If this prints nothing, install Redis:

```bash
brew install redis
```

2. Check where Homebrew put redis-cli:

```bash
ls "$(brew --prefix redis)/bin/redis-cli"
```

If this command says file not found, repair install:

```bash
brew reinstall redis
```

3. Refresh your shell command cache:

```bash
hash -r
```

4. Re-check command lookup:

```bash
command -v redis-cli
```

If this now prints a path, the issue is fixed.

5. If still missing, add Redis bin to PATH and reload shell:

```bash
echo 'export PATH="$(brew --prefix redis)/bin:$PATH"' >> ~/.zshrc
```

```bash
source ~/.zshrc
```

6. Confirm again:

```bash
command -v redis-cli
redis-cli --version
```

If still missing after Step 6, collect outputs from Steps 1, 2, 4, and 6 and share them with the team.

## Java 8 quick fix

1. Check whether Java 8 is installed:

```bash
/usr/libexec/java_home -v 1.8
```

If this prints a path, continue to Step 3.

If this prints an error about no matching Java version, continue to Step 2.

2. Install Java 8:

```bash
brew install --cask temurin@8
```

Then re-check:

```bash
/usr/libexec/java_home -v 1.8
```

3. In the terminal where you run Fedora, activate Java 8:

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
```

```bash
export PATH="$JAVA_HOME/bin:$PATH"
```

4. Confirm active Java in that same terminal:

```bash
java -version
```

Expected: output shows Java 8 (`1.8`).

5. Start Fedora from that same terminal:

- Dev: [start-services.md](./start-services.md)
- Test: [start-test-services.md](./start-test-services.md)

## Related

- [Versions and ports](./versions-and-ports.md)
- [Run the app](./run-the-app.md)
- [Run tests](./run-tests.md)
