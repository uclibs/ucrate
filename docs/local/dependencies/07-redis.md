# 7) Redis

Back to setup index: [docs/local/README.md](../README.md)

Redis is required for Sidekiq and app background jobs.

This page is for Redis setup/verification only.

Do not start app services from this page.

## Verify Redis binaries are on PATH

Run this command:

```bash
command -v redis-server
```

If output prints a path, continue.

If output is empty, install Redis:

```bash
brew install redis
```

Now run this command:

```bash
command -v redis-cli
```

If output prints a path, you are done with this step.

If output is empty, Redis is likely a broken/incomplete install. Reinstall Redis:

```bash
brew reinstall redis
```

Then run:

```bash
command -v redis-cli
```

If this prints a path, Redis is installed and on PATH.

If this is still empty, stop here and use [Redis CLI quick fix](../troubleshooting.md#redis-cli-quick-fix) before continuing.


## Next

Go to [8) Java 8 (Temurin)](./08-java-8.md).
