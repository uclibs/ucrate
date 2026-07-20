# Check what you currently have

**These instructions are for `hyku-oob` only.** See the [main README](../README.md).

Compare your Mac to the targets in [versions-and-ports.md](./versions-and-ports.md).

## General tools

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

Optional:

```bash
/usr/libexec/java_home -V
brew list --versions redis imagemagick libreoffice node yarn 2>/dev/null
```

## PostgreSQL

Most teammates coming from `develop` (MySQL) will need to install Postgres. Some may already have it — check first so you do not layer a second install.

```bash
which psql
psql --version
brew list --versions postgresql@16 postgresql@15 postgresql@14 postgresql 2>/dev/null
pg_isready -h localhost 2>&1
```

| Result | Meaning |
|---|---|
| `psql not found` / empty brew list | Postgres is **not** installed → [install.md](./install.md#postgresql-required) Step B |
| `psql` works and `pg_isready` OK | Already set up → [install.md](./install.md#postgresql-required) Step D (user) and Step E (create DBs only if missing). **Do not reinstall.** |
| `psql` works but server down | [install.md](./install.md#postgresql-required) Step C for **your existing** version only |

## Next

- [Install dependencies](./install.md)
