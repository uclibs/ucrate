# Hyku (hyku-oob) — Local macOS Setup (No Docker)

This branch is stock [Samvera Hyku](https://github.com/samvera/hyku), kept beside our Scholar@UC history so we can upgrade toward current Hyku and later merge into `develop` / `main`.

**These instructions are for `hyku-oob` only.** They are not the same as running the `develop` branch.

| | `develop` (Scholar@UC) | `hyku-oob` (this branch) |
|---|---|---|
| Ruby | 2.7.8 | **3.3+** (3.3.x recommended) |
| Database | MySQL | **PostgreSQL** |
| Jobs | Sidekiq | Sidekiq by default locally (see below) |
| App | Custom Scholar@UC | Upstream Hyku |

Upstream Docker docs remain in [docs/getting-started.md](./docs/getting-started.md). This README is the **no-Docker** path for our team.

### Quick links

| Goal | Jump to |
|------|---------|
| Install dependencies | [§3](#3-install-or-update-homebrew--rbenv) |
| Configure env | [§4](#4-local-environment-variables) |
| **Run the app locally** | [§5–§8](#5-start-supporting-services-separate-terminals) |
| **Run tests locally** (optional; can take a long time) | [§9](#9-running-tests-locally-optional) |
| Switch back to `develop` | [§10](#10-switching-back-to-develop) |
| Troubleshooting | [§11](#11-troubleshooting) |

---

## 1. What versions do we need?

| Service | Target for local (no Docker) | Where that comes from |
|---|---|---|
| **Ruby** | 3.3.x (3.3+ OK; Rails 7.2) | [docs/getting-started.md](./docs/getting-started.md); Hyrax base image uses Ruby 3.3 |
| **Bundler** | 2.6.x | `BUNDLED WITH` at the bottom of `Gemfile.lock` |
| **PostgreSQL** | 14+ (11+ OK) | Hyku uses the `pg` gem / Apartment; Docker pin is `postgres:11.1` |
| **Redis** | 6.2+ (7.x fine) | Sidekiq 7 needs Redis ≥ 6.2 (`Gemfile` comment). Still useful with Good Job for cache/Hyrax |
| **Solr (dev)** | **7.4.0** via `solr_wrapper` on port **8983** | `.solr_wrapper` + pin `--version 7.4.0` (matches test pin; Docker image is Solr **8.11.2**) |
| **Solr (test)** | **7.4.0** on port **8985** | `config/solr_wrapper_test.yml` |
| **Fedora (dev)** | **4.7.3** via `fcrepo_wrapper` on port **8984** | `.fcrepo_wrapper`; Docker uses `fcrepo4:4.7.5` |
| **Fedora (test)** | **4.7.3** on port **8986** | `config/fcrepo_wrapper_test.yml` (not develop’s old test port **8080**) |
| **Java** | **8** (Temurin 8) for Fedora wrapper | Same constraint as older Hyrax/Fedora 4 stacks |
| **Node / Yarn** | Node 20-ish, Yarn classic | Universal Viewer / `yarn install` (`package.json`) |
| **ImageMagick, LibreOffice** | Current Homebrew | Derivatives / office conversion |

**Do not trust Homebrew’s `solr` formula for this app.** Use `bundle exec solr_wrapper` so the app gets the version and config under `solr/conf/`.

**Do not source the committed `.env` as-is for local runs.** That file is aimed at Docker Compose (`DB_HOST=db`, `SOLR_HOST=solr`, `REDIS_HOST=redis`, `FCREPO_HOST=fcrepo`). Rails does **not** auto-load `.env` outside Docker. Local defaults in `config/*.yml` already prefer `localhost` / `127.0.0.1` when those vars are unset.

### Dev vs test ports (do not mix)

| | Development (run the app) | Test (run specs) |
|---|---|---|
| Solr | **8983** / `hydra-development` | **8985** / `hydra-test` |
| Fedora | **8984** | **8986** |
| Redis | 6379 | 6379 |
| Postgres DB | `hyku` | `hyku_test` |

You can run the app stack and the test stack at the same time because the ports differ. Do **not** point the test suite at the development Solr/Fedora ports.

---

## 2. Check what you currently have

Run these on your Mac:

```bash
ruby -v
bundler -v
redis-server --version
java -version
node -v
yarn -v
convert -version | head -1  # ImageMagick
soffice --version           # LibreOffice (may be under /Applications)
brew --prefix
```

**PostgreSQL check (most teammates will need to install this — `develop` used MySQL):**

```bash
which psql
psql --version
brew list --versions postgresql@16 postgresql@15 postgresql@14 postgresql 2>/dev/null
```

| Result | Meaning |
|---|---|
| `psql not found` / empty brew list | Postgres is **not** installed → §3 Step B |
| `psql` works and `pg_isready` OK | Already set up → §3 Step D (user) and Step E (create `hyku` DBs only if missing). **Do not reinstall.** |
| `psql` works but server down | §3 Step C for **your existing** version only |

Optional: list Java installs and other Homebrew versions:

```bash
/usr/libexec/java_home -V
brew list --versions redis imagemagick libreoffice node yarn 2>/dev/null
```

Compare each line to the table in §1.

---

## 3. Install or update (Homebrew + rbenv)

Apple Silicon and Intel Macs use the same flow; only Homebrew prefixes differ (`/opt/homebrew` vs `/usr/local`).

### Homebrew packages (Postgres is handled separately below)

Install shared tools. **Leave Postgres out of this command** — discover/install it in the next subsection so we do not layer a second Postgres on someone who already has one.

```bash
brew update
brew install rbenv ruby-build redis imagemagick libreoffice libxml2 libxslt shared-mime-info yarn
brew install --cask temurin@8
```

### PostgreSQL (required)

`hyku-oob` uses **PostgreSQL**, not MySQL. Some teammates will install it fresh; others may already have it. **If you already have a working Postgres, keep using it.** Do not reinstall, upgrade, reinstall formulas, or stop another project’s server just for Hyku.

#### Step A — Discover what you already have (always do this first)

```bash
which psql
psql --version
brew list --versions postgresql@17 postgresql@16 postgresql@15 postgresql@14 postgresql 2>/dev/null
brew services list | grep -i postgres
pg_isready -h localhost 2>&1
```

| What you see | What to do |
|---|---|
| `psql` works **and** `pg_isready` says accepting connections | Working Postgres already. **Skip Step B and Step C.** Go to **Step D**. |
| `psql` works but `pg_isready` fails | Client present; server may be stopped. Go to **Step C (existing install)** — do **not** install another copy. |
| brew lists a `postgresql@…` but `psql not found` | Installed, not on PATH. Fix PATH in **Step C (existing install)** — do **not** install `@16` unless brew list is empty. |
| `psql not found` and brew list is empty | Not installed. Go to **Step B**. |

> **Avoid:** `brew install postgresql@16` when any Postgres formula is already listed; `brew services stop` / `upgrade` / `reinstall` on an existing server; starting a second Postgres while something is already on port **5432**.

#### Step B — Install only if Step A found nothing

```bash
brew install postgresql@16
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
psql --version
```

To make the PATH permanent, add that `export PATH=...` line to `~/.zshrc`, then open a new terminal (or `source ~/.zshrc`).

Then go to **Step C (new install)**.

#### Step C — Ensure the server is running (without breaking an existing one)

**Already accepting connections?** Skip this step entirely.

**Existing install, server stopped** — start **only the version you already have** (see `brew list` / `brew services list`):

```bash
# Pick ONE — the version you already have:
brew services start postgresql@16
# or: brew services start postgresql@15
# or: brew services start postgresql@14
# or: brew services start postgresql

export PATH="$(brew --prefix postgresql@16)/bin:$PATH"   # change @16 to your version
pg_isready -h localhost
```

**Brand-new `@16` install from Step B:**

```bash
brew services start postgresql@16
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
brew services list | grep postgres
pg_isready -h localhost
```

If `pg_isready` fails because **port 5432 is in use**, another Postgres (Homebrew, Docker, Postgres.app, etc.) is already running. Use that server; do not start a second one:

```bash
lsof -i :5432
```

#### Step D — Find your Postgres username (DB user)

Discover the account you already use. Do not create or reset users/passwords on an existing server unless you know you need to.

```bash
whoami
psql -d postgres -c 'SELECT current_user;'
psql -d postgres -c '\du'
```

**If that works**, set `DB_USER` in `.env.local.mac` to that `current_user` (often the same as `whoami`).

**If it fails** (“role does not exist”), try:

```bash
psql -U postgres -d postgres -c 'SELECT current_user;'
```

| What worked | Set `DB_USER` to |
|---|---|
| `psql -d postgres` (no `-U`) | that `current_user` |
| only `psql -U postgres ...` | `postgres` |
| you already use a known user/password for other projects | that existing user (set `DB_PASSWORD` if required) |

Homebrew local installs often need an empty `DB_PASSWORD`. If your existing install needs a password, keep it — don’t change it for Hyku.

#### Step E — Create Hyku databases only if missing

Safe to re-run; does nothing if the databases already exist (will not drop or wipe data):

```bash
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku'" | grep -q 1 || createdb hyku
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku_test'" | grep -q 1 || createdb hyku_test
psql -d postgres -c '\l' | grep hyku
```

You should see `hyku` and `hyku_test`. If `createdb` fails with a permissions error, paste the exact error in the team chat before running any `createuser` / `dropdb` commands.

### Redis (background service)

```bash
brew services start redis
redis-cli ping    # should print PONG
```

Or run Redis in the foreground later with `redis-server` (see §5).

### Java 8 (required for `fcrepo_wrapper`)

```bash
/usr/libexec/java_home -v 1.8
```

If that fails, install Temurin 8 (above) and in **every terminal that runs Fedora**:

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
java -version   # should show 1.8 / 8
```

### Ruby 3.3.x via rbenv

```bash
brew install rbenv ruby-build
# add eval "$(rbenv init - zsh)" to ~/.zshrc if needed, then open a new terminal

rbenv install 3.3.6        # or another 3.3.x
cd /path/to/ucrate
rbenv local 3.3.6
ruby -v                    # confirm 3.3.x
```

### Bundler + gems + JS

```bash
cd /path/to/ucrate
git checkout hyku-oob

gem install bundler -v 2.6.9    # match Gemfile.lock "BUNDLED WITH"
bundle _2.6.9_ install
yarn install
```

---

## 4. Local environment variables

Copy the committed template to a **personal** file (gitignored). This does **not** overwrite the Docker `.env`.

```bash
cp .env.local.mac.example .env.local.mac
```

Edit `.env.local.mac` and set `DB_USER` from §3 Step D (`whoami` / `psql -d postgres -c 'SELECT current_user;'`).

Template contents (also in `.env.local.mac.example`):

```bash
# .env.local.mac — source this; do not use Docker hostnames
export HYKU_MULTITENANT=false
export DB_ADAPTER=postgresql
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=hyku
export DB_TEST_NAME=hyku_test
export DB_USER=YOUR_MAC_USERNAME_HERE   # from §3 Step D
export DB_PASSWORD=                     # usually empty on Homebrew Postgres
export REDIS_HOST=localhost
export REDIS_PORT=6379
# Leave SOLR_URL / FCREPO_HOST unset so config/*.yml use localhost defaults
# Jobs: omit HYRAX_ACTIVE_JOB_QUEUE to use Sidekiq (default)
export INITIAL_ADMIN_EMAIL=admin@example.com
export INITIAL_ADMIN_PASSWORD=testing123
export SECRET_KEY_BASE=dev-secret-change-me
export DISABLE_REDIS_CLUSTER=true
```

Load it in each terminal that runs Rails, Sidekiq, or `db:setup`:

```bash
set -a && source .env.local.mac && set +a
```

> **Multitenancy:** Upstream Hyku often uses `*.localhost.direct` and Stack Car. Stay on `HYKU_MULTITENANT=false` until the single-tenant stack is solid.

---

## 5. Start supporting services (separate terminals)

This section is for **running the app** (development ports). For tests, see [§9](#9-running-tests-locally-optional).

Stay in the project directory. Use **foreground** processes (do not append `&`) so logs are visible. Solr paths must not contain spaces.

### Terminal A — Fedora (port 8984)

```bash
cd /path/to/ucrate
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper   # reads .fcrepo_wrapper → port 8984
```

First run downloads Fedora **4.7.3**. Wait until it is listening.

### Terminal B — Solr (port 8983)

```bash
cd /path/to/ucrate
# Pin 7.4.0 to match config/solr_wrapper_test.yml (avoids "latest" surprises)
bundle exec solr_wrapper --version 7.4.0
```

Uses `.solr_wrapper` (collection `hydra-development`, config under `solr/conf/`). First run downloads Solr.

### Terminal C — Redis (port 6379)

If not using `brew services`:

```bash
redis-server
```

If using Homebrew services, skip this terminal and confirm with:

```bash
redis-cli ping    # PONG
```

### Postgres

Use whatever Postgres you already run from §3. Confirm before Rails setup:

```bash
pg_isready -h localhost
psql -d hyku -c 'SELECT current_user;'
```

Do not start `postgresql@16` (or any other version) if something is already accepting connections on port 5432.

---

## 6. One-time app setup

With Terminals A–C (and Postgres) up, in a new terminal:

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

bundle exec rails db:setup
# db:setup = create + schema + seed (needs Solr + Fedora running for seeds)
```

If the DB already exists:

```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

With `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD` set, seed creates a superadmin.

---

## 7. Start the app and worker

### Terminal D — Sidekiq (background jobs)

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
```

### Terminal E — Rails

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0 -p 3000
```

Open **http://localhost:3000**

Sign in with the `INITIAL_ADMIN_*` values from `.env.local.mac`.

---

## 8. Everyday restart order (app)

1. Postgres + Redis (`brew services` or terminals)
2. `fcrepo_wrapper` (Java 8) — port **8984**
3. `solr_wrapper --version 7.4.0` — port **8983**
4. `sidekiq`
5. `rails server`

Stop with Ctrl+C in each terminal. Safe to leave brew-managed Postgres/Redis running.

---

## 9. Running tests locally (optional)

You do **not** need to run the full suite for every change. A complete local run needs Solr + Fedora on **test** ports and can take a **long time** (often on the order of an hour). Prefer CI for routine full runs; use this section when you specifically want to exercise specs on your Mac.

Prerequisites (same as the app, already covered above):

- Ruby / Bundler / gems installed (§3)
- Postgres running with `hyku_test` created (§3 Step E)
- Redis running
- `.env.local.mac` sourced (`DB_TEST_NAME=hyku_test`, etc.)
- Java 8 available for Fedora

### Option A — Recommended: `rake ci` (auto-starts test Solr + Fedora)

This matches the repo’s non-Docker default (`Rakefile` → `with_server 'test'`). It starts Solr/Fedora using the **test** wrapper configs, then runs the specs.

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"

# First time (or after schema changes):
RAILS_ENV=test bundle exec rails db:prepare

bundle exec rake ci
```

What `rake ci` uses:

| Service | Port | Config |
|---------|------|--------|
| Solr | **8985** | `config/solr_wrapper_test.yml` (Solr 7.4.0, `hydra-test`) |
| Fedora | **8986** | `config/fcrepo_wrapper_test.yml` |

`bundle exec rake` (with no args, outside Docker) runs RuboCop then `ci`.

To run only RuboCop (no Solr/Fedora, much faster):

```bash
bundle exec rubocop
```

### Option B — Manual test wrappers (like the old `develop` flow)

Use this if you want wrappers left running across multiple spec invocations. **Ports differ from `develop`:** Fedora test is **8986** here (not develop’s **8080**). Solr test stays **8985**.

**Terminal 1 — Fedora (test, 8986)**

```bash
cd /path/to/ucrate
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper -c config/fcrepo_wrapper_test.yml
```

**Terminal 2 — Solr (test, 8985)**

```bash
cd /path/to/ucrate
bundle exec solr_wrapper -c config/solr_wrapper_test.yml
```

**Terminal 3 — Redis** (skip if `brew services` already runs it)

```bash
redis-server
```

**Terminal 4 — Specs**

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

RAILS_ENV=test bundle exec rails db:prepare

# Full suite:
bundle exec rspec
# or: bundle exec rake spec

# Targeted (much faster when you only care about one area):
bundle exec rspec spec/path/to/some_spec.rb
```

### Notes

- Keep **development** wrappers (8983/8984) separate from **test** wrappers (8985/8986). Mixing them causes confusing failures.
- Do not source the Docker `.env` for local tests (wrong hostnames).
- If ports are busy, stop old wrappers: `lsof -i :8985` / `lsof -i :8986`.
- Upstream CI also runs specs in Docker/GitLab with Solr/Fedora as services — see `.gitlab-ci.yml` and [docs/getting-started.md](./docs/getting-started.md).

---

## 10. Switching back to `develop`

`develop` still wants Ruby 2.7.8, MySQL, and its own README. When you switch branches:

```bash
git checkout develop
rbenv local 2.7.8    # or whatever develop documents
# use develop’s MySQL + service instructions from that branch’s README
```

Do not mix `hyku-oob` Postgres settings with `develop`’s MySQL setup in the same shell without resetting env vars.

---

## 11. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `psql: command not found` | Postgres not installed or not on PATH | §3 Step A/B; PATH for **your** version only |
| `pg_isready` fails / connection refused | Server not running | Start **existing** version (§3 Step C); don’t install a second copy |
| Port 5432 already in use when starting brew Postgres | Another Postgres already running | `lsof -i :5432`; use that server instead |
| `role "postgres" does not exist` | Homebrew user is your macOS name, not `postgres` | §3 Step D; set `DB_USER` to `whoami` |
| `database "hyku" does not exist` | Hyku DBs not created yet | §3 Step E (safe if-missing `createdb`) |
| `fcrepo_wrapper: command not found` | Not using Bundler | `bundle exec fcrepo_wrapper` from the project root after `bundle install` |
| Unable to locate a Java Runtime / wrong Java | JAVA_HOME not 8 | `export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"` |
| DB connection errors from Rails | Wrong `DB_*` or Postgres not running | Re-check §3 Steps C–E and `.env.local.mac` |
| Solr/Fedora connection errors (app) | Dev wrappers not up, or Docker `.env` hosts loaded | Confirm ports **8983/8984**; **unset** `SOLR_URL` / `FCREPO_HOST` if they point at `solr`/`fcrepo` |
| Specs can’t reach Solr/Fedora | Using dev ports, or test wrappers down | Test ports are **8985/8986**; use `rake ci` or Option B |
| Specs fail after using develop’s Fedora **8080** | Wrong test Fedora port on this branch | Use **8986** (`config/fcrepo_wrapper_test.yml`) |
| Sidekiq Redis errors | Redis down or Redis &lt; 6.2 | `redis-cli ping`; `brew upgrade redis` |
| Seeds fail | Solr/Fedora not ready | Start wrappers first, wait, re-run `db:seed` |
| Solr fails with spaces in path | Known Solr limitation | Move the repo to a path without spaces |
| Port already in use | Old wrapper/server still running | `lsof -i :3000`, `:8983`, `:8984`, `:8985`, `:8986`, `:6379` |

---

## Upstream Hyku docs

- [Getting Started](./docs/getting-started.md) (Docker-oriented)
- [Configuration](./docs/configuration.md)
- [Using Hyku](./docs/using-hyku.md)
- [Support](./docs/support.md)

## Acknowledgments

Hyku was developed by the Hydra-in-a-Box Project (DPLA, DuraSpace, and Stanford University) under a grant from IMLS, and is maintained by the [Samvera](http://samvera.org/) community.
