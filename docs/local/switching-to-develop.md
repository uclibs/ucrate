# Switching back to `develop`

**These instructions are for people who also work on Scholar@UC `develop`.** Team index: [docs/local/README.md](./README.md).

`develop` still wants Ruby 2.7.8, MySQL, and its own README (on that branch). When you switch:

```bash
git checkout develop
rbenv local 2.7.8    # or whatever develop documents
# use develop’s MySQL + service instructions from that branch’s README
```

Do not mix `hyku-oob` Postgres settings with `develop`’s MySQL setup in the same shell without resetting env vars.

## Related

- [hyku-oob dependency setup](./dependencies)
- [hyku-oob run the app](./run-the-app.md)
