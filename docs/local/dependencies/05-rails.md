# 5) Rails

Back to setup index: [docs/local/README.md](../README.md)

You do not install Rails globally for this project.
Rails comes from the Gemfile and is run through Bundler.

## Check

```bash
cd /path/to/ucrate
bundle exec rails -v
```

Expected: prints Rails 7.2.x.

If this fails, go back to [4) Bundler](./04-bundler.md) and re-run `bundle _2.6.9_ install`.

## Next

Go to [6) Node + Yarn](./06-node-yarn.md).
