#!/bin/sh

cmd_help() {
cmd=${1:-}

case $cmd in
init)
	cat <<'EOF'
git smv init [--from-gitmodules] [--force]

Create .gitsmv at the repository root with smv.version = 1.
With --from-gitmodules, populate ref and resolved from current submodule state.
EOF
	;;
add)
	cat <<'EOF'
git smv add <path> <url> [--ref <ref>] [--version <version>]

Run git submodule add, then add a lock entry in .gitsmv.
EOF
	;;
remove)
	cat <<'EOF'
git smv remove <path> [--keep-dir]

Deinitialize submodule, remove .gitsmv entry, and remove from index/.gitmodules.
EOF
	;;
lock)
	cat <<'EOF'
git smv lock [--all] [<path>...]

Fetch each submodule and update resolved (and resolve ref) in .gitsmv.
EOF
	;;
sync)
	cat <<'EOF'
git smv sync [--all] [<path>...] [--dry-run] [--allow-partial]

Initialize/update submodules and checkout resolved SHAs from .gitsmv.
EOF
	;;
bump)
	cat <<'EOF'
git smv bump <path> --ref <ref> [--version <version>] [--to-latest]

Update ref/version in .gitsmv and re-resolve to update resolved.
With --to-latest, resolve the branch from .gitmodules (or current ref).
EOF
	;;
status)
	cat <<'EOF'
git smv status [-v]

Show version/ref/resolved from .gitsmv vs submodule HEAD vs parent gitlink.
EOF
	;;
diff)
	cat <<'EOF'
git smv diff [--porcelain]

Compare resolved in .gitsmv with gitlink recorded in HEAD (and index).
EOF
	;;
*)
	cat <<EOF
$USAGE

Environment:
  GITSMV_FILE    Path to lock file (default: .gitsmv at repo root)

Global options (before subcommand):
  --gitsmv-file <path>   Lock file path
  --force, -f            Force overwrite / allow dirty parent
  --strict               Strict validation
  --dry-run, -n          Dry run (sync)
  --allow-partial        Skip submodules without lock entries (sync)

See: git smv help <command>
EOF
	;;
esac
}
