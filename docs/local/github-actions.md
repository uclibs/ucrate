# GitHub Actions / CI notes (hyku-oob)

Team index: [docs/local/README.md](./README.md).

## PR label checker (`Verify` / “PR has required labels”)

Upstream Hyku requires release labels (`patch-ver`, `minor-ver`, `major-ver`, `ignore-for-release`, or `dependencies`) on PRs.

For Scholar@UC work we **do not** use that process on feature branches. `.github/workflows/verify_labels.yml` is limited to PRs whose **base branch is `main`**.

PRs into `hyku-oob` (or other non-`main` bases) should **not** need those labels.

If a Hyku merge resets that workflow to `branches: ['**']`, restore the `main`-only filter (see the comments in the workflow file).

## Other CI

Hyku also ships workflows such as `build-test-lint.yaml`. Those are separate from the label check and may still run on your PRs depending on their `on:` triggers.
