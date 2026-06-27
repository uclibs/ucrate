# Agent instructions (Scholar@UC)

For **Scholar modernization** work, read first:

**[docs/modernization/README.md](docs/modernization/README.md)**

Then [STATUS.md](docs/modernization/STATUS.md) for current phase and next tasks.

- Branch: `scholar-modernization`
- Rule: never remove a moving part until nothing in that environment calls it
- New code: `lib/scholar/`, `app/models/scholar/` (see [ARCHITECTURE.md](docs/modernization/ARCHITECTURE.md))
- Update STATUS.md when finishing a session slice

Legacy Hyrax/Fedora behavior: only change when the active phase requires it.
