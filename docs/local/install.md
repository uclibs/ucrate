# Install dependencies (macOS, no Docker)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

Apple Silicon and Intel Macs use the same flow; only Homebrew prefixes differ (`/opt/homebrew` vs `/usr/local`).

First: [check your machine](./check-your-machine.md). Version targets: [versions-and-ports.md](./versions-and-ports.md).

## Homebrew packages (Postgres is handled separately)

Install shared tools. **Leave Postgres out of this command** — discover/install it below so we do not layer a second Postgres on someone who already has one.

```bash
brew update
brew install rbenv ruby-build redis imagemagick libreoffice libxml2 libxslt shared-mime-info yarn
brew install --cask temurin@8
```

## PostgreSQL (required)

`hyku-oob` uses **PostgreSQL**, not MySQL. **If you already have a working Postgres, keep using it.** Do not reinstall, upgrade, or stop another project’s server just for Hyku.

### Step A — Discover what you already have (always do this first)

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

### Step B — Install only if Step A found nothing

```bash
brew install postgresql@16
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
psql --version
```

To make the PATH permanent, add that `export PATH=...` line to `~/.zshrc`, then open a new terminal (or `source ~/.zshrc`).

Then go to **Step C (new install)**.

### Step C — Ensure the server is running (without breaking an existing one)

**Already accepting connections?** Skip this step entirely.

**Existing install, server stopped** — start **only the version you already have**:

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

If `pg_isready` fails because **port 5432 is in use**, another Postgres is already running. Use that server; do not start a second one:

```bash
lsof -i :5432
```

### Step D — Find your Postgres username (DB user)

Discover the account you already use. Do not create or reset users/passwords on an existing server unless you know you need to.

```bash
whoami
psql -d postgres -c 'SELECT current_user;'
psql -d postgres -c '\du'
```

**If that works**, put the printed `current_user` in `.env.local.mac` as `DB_USER` (see [environment.md](./environment.md)).

**If it fails** (“role does not exist”), try:

```bash
psql -U postgres -d postgres -c 'SELECT current_user;'
```

| What worked | Set `DB_USER` to |
|---|---|
| `psql -d postgres` (no `-U`) | that `current_user` (often same as `whoami`) |
| only `psql -U postgres ...` | `postgres` |
| you already use a known user/password for other projects | that existing user (set `DB_PASSWORD` if required) |

Homebrew local installs often need an empty `DB_PASSWORD`. If your existing install needs a password, keep it.

### Step E — Create Hyku databases only if missing

Safe to re-run; does nothing if the databases already exist (will not drop or wipe data):

```bash
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku'" | grep -q 1 || createdb hyku
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku_test'" | grep -q 1 || createdb hyku_test
psql -d postgres -c '\l' | grep hyku
```

You should see `hyku` and `hyku_test`. If `createdb` fails with a permissions error, paste the exact error in the team chat before running any `createuser` / `dropdb` commands.

## Redis

```bash
brew services start redis
redis-cli ping    # should print PONG
```

Or run Redis in the foreground later with `redis-server` (see [run-the-app.md](./run-the-app.md)).

## Java 8 (required for `fcrepo_wrapper`)

```bash
/usr/libexec/java_home -v 1.8
```

If that fails, install Temurin 8 (above) and in **every terminal that runs Fedora**:

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
java -version   # should show 1.8 / 8
```

## Ruby 3.3.x via rbenv

```bash
brew install rbenv ruby-build
# add eval "$(rbenv init - zsh)" to ~/.zshrc if needed, then open a new terminal

rbenv install 3.3.6        # or another 3.3.x
cd /path/to/ucrate
rbenv local 3.3.6
ruby -v                    # confirm 3.3.x
```

## Bundler + gems + JS

```bash
cd /path/to/ucrate
git checkout hyku-oob

gem install bundler -v 2.6.9    # match Gemfile.lock "BUNDLED WITH"
bundle _2.6.9_ install
yarn install
```

## Next

- [Local environment variables](./environment.md)
- [Run the app](./run-the-app.md)
- [Run tests](./run-tests.md)
