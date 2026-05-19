# git-smv — Git Submodule Versioning

`git smv` is a Git extension that manages submodule versions through a lock file
**`.gitsmv`** at the repository root, similar in spirit to `package-lock.json`.

- **`.gitmodules`** — where to clone (`path`, `url`, `branch`) — managed by Git
- **`.gitsmv`** — what to use (`version`, `ref`, `resolved`) — managed by `git smv`
- **Parent tree** — recorded gitlink SHA — updated after `git smv sync` and commit

## Install

```bash
make install PREFIX=~/.local
# installs ~/.local/bin/git-smv and ~/.local/share/git-smv/lib/
export PATH="$HOME/.local/bin:$PATH"
```

Or symlink:

```bash
ln -sf "$(pwd)/git-smv" ~/.local/bin/git-smv
```

Verify:

```bash
git smv help
git help smv
```

## Quick start

```bash
# Existing repo with submodules
git smv init --from-gitmodules
git add .gitsmv
git commit -m "Add submodule version lock"

# Release bump
git smv bump vendor/foo --ref v1.3.0 --version 1.3.0
git smv lock vendor/foo
git smv sync vendor/foo
git add .gitsmv vendor/foo
git commit -m "Bump vendor/foo to 1.3.0"
```

## `.gitsmv` format

Git-config INI (same syntax as `.gitmodules`):

```ini
[smv]
	version = 1

[submodule "vendor/libfoo"]
	version = 2.1.0
	ref = v2.1.0
	resolved = <40-char-sha>
```

Do not put `url`, `path`, or `branch` in `.gitsmv`.

## Commands

| Command | Description |
|---------|-------------|
| `init` | Create `.gitsmv` |
| `add` | Add submodule + lock entry |
| `remove` | Remove submodule + lock entry |
| `lock` | Resolve refs → `resolved` |
| `sync` | Checkout `resolved` in submodules |
| `bump` | Update `ref` / `version` |
| `status` | Show drift |
| `diff` | Lock vs parent gitlink |

Global options (before subcommand): `--gitsmv-file`, `--force`, `--strict`,
`--dry-run`, `--allow-partial`.

Environment: `GITSMV_FILE` overrides the lock file path.

## Tests

```bash
make test
```

## License

MIT — see [LICENSE](LICENSE).

## Roadmap

See [ROADMAP.md](ROADMAP.md) for post-v1 alignment with Git upstream conventions.
