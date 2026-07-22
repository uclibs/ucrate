# Local environment variables

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

Hyku’s committed `.env` is for Docker. On a Mac without Docker, you use a personal file instead:

| File | In git? | Role |
|------|---------|------|
| `.env.local.mac.example` | Yes | Team template — [open it](../../.env.local.mac.example) |
| `.env.local.mac` | No | Your copy (gitignored) |
| `.envrc` | Yes | Loads your copy via [direnv](./dependencies/direnv.md) |

Create `.env.local.mac` once. direnv loads it when you work in this clone and unloads it when you leave.

## Steps

1. Open a terminal in your **ucrate clone root** (the folder with `Gemfile`). In Cursor, that is usually the project you opened.

2. Copy the template (this does not touch Docker’s `.env`):

```
cp .env.local.mac.example .env.local.mac
```

3. Leave `DB_USER=YOUR_MAC_USERNAME_HERE` alone for now. You set the real value later in [dependencies/postgresql.md](./dependencies/postgresql.md).

4. Still in the clone root, print the cache path:

```
echo "$PWD"/tmp/hyku_file_cache
```

Expected: one absolute path, for example `/Users/alex/Codebases/ruby-on-rails/ucrate/tmp/hyku_file_cache`. Copy that whole line.

5. Open `.env.local.mac`, find `HYKU_CACHE_ROOT`, and paste your path between the quotes so it looks like:

```
export HYKU_CACHE_ROOT="/Users/alex/Codebases/ruby-on-rails/ucrate/tmp/hyku_file_cache"
```

Use your path from step 4, not the example. Keep the quotes. The value must start with `/`, end with `/tmp/hyku_file_cache`, and must not contain `$PWD` or `~`.

Hyku defaults the cache to a Docker path (`/app/...`). Without this absolute path, the homepage can fail with `Errno::EROFS`.

If you move the clone later, repeat steps 4–5.

## Next

Go to [Homebrew](./dependencies/homebrew.md).
