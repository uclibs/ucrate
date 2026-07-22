# Local macOS setup for hyku-oob (no Docker)

Use this guide when setting up `hyku-oob` on a Mac for the first time.

This team workflow is **manual services**, not Docker. Start each service yourself in the right order, then start Rails last.

## Two things every teammate should know

1. **These docs (`docs/local/`)** are our Scholar@UC source of truth for running this branch on a Mac without Docker. Follow [docs/local/README.md](./README.md) (this page) in order. Upstream Hyku’s root [README.md](../../README.md) is for Hyku generally and may change on merges — do not treat it as our local setup guide.

2. **Local environment file:** copy the committed template `.env.local.mac.example` to a personal `.env.local.mac` (gitignored). Full steps: [environment.md](./environment.md). [Open the template file](../../.env.local.mac.example).  
   Do **not** source the repo’s Docker `.env` for local no-Docker runs.

If you have already set up this branch before and just need to run services, go to [start-services.md](./start-services.md).

If you need to start test services specifically, go to [start-test-services.md](./start-test-services.md).

## Rules for this guide

1. Do not use Docker for local app runs.
2. Do not install duplicate services when one is already present.
3. Keep dev ports and test ports separate.
4. Use [troubleshooting.md](./troubleshooting.md) when a command fails.

## First-time setup checklist

Follow these steps in order:

1. Confirm branch and workspace:

	```bash
	git branch --show-current
	pwd
	```

	Expected branch: `hyku-oob`

2. Optional: skim versions and ports (reference only):

	[versions-and-ports.md](./versions-and-ports.md)

	What to do in this step:

	- Skim the page so you know what "good" looks like.
	- Do **not** memorize the table.
	- Do **not** install anything yet.
	- Do **not** run setup commands yet.

	You can come back to this page later. Setup starts in Step 3.

3. Create local environment variables:

	[environment.md](./environment.md)

4. Dependency 1: Homebrew

	[dependencies/01-homebrew.md](./dependencies/01-homebrew.md)

5. Dependency 2: PostgreSQL

	[dependencies/02-postgresql.md](./dependencies/02-postgresql.md)

6. Dependency 3: Ruby + rbenv

	[dependencies/03-ruby-rbenv.md](./dependencies/03-ruby-rbenv.md)

7. Dependency 4: Bundler

	[dependencies/04-bundler.md](./dependencies/04-bundler.md)

8. Dependency 5: Rails (project-managed)

	[dependencies/05-rails.md](./dependencies/05-rails.md)

9. Dependency 6: Node + Yarn

	[dependencies/06-node-yarn.md](./dependencies/06-node-yarn.md)

10. Dependency 7: Redis

	[dependencies/07-redis.md](./dependencies/07-redis.md)

11. Dependency 8: Java 8

	[dependencies/08-java-8.md](./dependencies/08-java-8.md)

12. Dependency 9: ImageMagick + LibreOffice

	[dependencies/09-imagemagick-libreoffice.md](./dependencies/09-imagemagick-libreoffice.md)

13. Start runtime dependencies:

	[start-services.md](./start-services.md)

	[start-test-services.md](./start-test-services.md)

14. Run the app and one-time database setup/seeding:

	[run-the-app.md](./run-the-app.md)

	This is where one-time database seeding happens for this branch.
	It creates the admin user from `.env.local.mac` and site defaults (admin set, workflows, enabled work types).
	It does **not** deposit sample works — an empty catalog after seed is normal.
	Optional UC samples (adapted from `develop`): see `uc:seed:samples` on [run-the-app.md](./run-the-app.md).
	Before `db:setup` / `db:seed`, wait until Solr has finished downloading and is listening (see that page).
	Your env must set `SOLR_HOST=localhost` and `HYKU_CACHE_ROOT` under the repo (see [environment.md](./environment.md)).
	That page also covers starting or restarting Rails if it is not up yet.

15. Run tests only when needed:

	[run-tests.md](./run-tests.md)

## Document map

| Doc | Contents |
|-----|----------|
| [dependencies/](./dependencies) | One-dependency-at-a-time setup path for juniors |
| [versions-and-ports.md](./versions-and-ports.md) | Version targets and dev/test ports |
| [environment.md](./environment.md) | `.env.local.mac` setup (`HYKU_ROOT_HOST`, Sidekiq, `SOLR_*`, `HYKU_CACHE_ROOT`; fill `DB_USER` later) |
| [start-services.md](./start-services.md) | Single source for runtime service startup commands |
| [start-test-services.md](./start-test-services.md) | Startup commands for test runtime services on test ports |
| [run-the-app.md](./run-the-app.md) | One-time DB setup/seeding, Rails start/restart if needed, first sign-in |
| [run-tests.md](./run-tests.md) | Optional local RSpec and `rake ci` |
| [switching-to-develop.md](./switching-to-develop.md) | Switching back to Scholar@UC `develop` |
| [troubleshooting.md](./troubleshooting.md) | Common errors and fixes |
| [updating-from-hyku.md](./updating-from-hyku.md) | Pulling Hyku updates with `git merge` |
| [github-actions.md](./github-actions.md) | CI behavior on `hyku-oob` |
