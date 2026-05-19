# Global and per-command checks.

run_global_checks() {
	# G0
	_smv_bin=$(command -v git-smv) || die "git-smv not found in PATH (install or symlink)"
	case "$0" in
	*git-smv*)
		_smv_real=$(CDPATH= cd "$(dirname "$0")" && pwd)/$(basename "$0")
		case $_smv_bin in
		/*) ;;
		*) _smv_bin=$(CDPATH= cd "$(dirname "$_smv_bin")" && pwd)/$(basename "$_smv_bin") ;;
		esac
		;;
	esac

	# G1
	if ! git version >/dev/null 2>&1; then
		die "git not found in PATH"
	fi
	_git_ver=$(git version | sed 's/git version //')
	_git_major=$(echo "$_git_ver" | cut -d. -f1)
	_git_minor=$(echo "$_git_ver" | cut -d. -f2)
	if test "$_git_major" -lt 2 || { test "$_git_major" -eq 2 && test "$_git_minor" -lt 20; }; then
		die "git version 2.20+ required (found $_git_ver)"
	fi

	# G2 — already loaded via lib/git-sh-setup.sh

	require_git_repo
	smv_ensure_gitsmv_file
}

require_git_repo() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
		die "not a git repository"
}

assert_not_in_merge() {
	if test -f "$(git rev-parse --git-dir)/MERGE_HEAD" ||
		test -f "$(git rev-parse --git-dir)/REBASE_HEAD"; then
		die "repository is in merge or rebase state"
	fi
}

require_gitsmv_file() {
	smv_ensure_gitsmv_file
	smv_lock_exists || die "missing .gitsmv at $(smv_lock_path) (run 'git smv init' first)"
}

require_smv_entry() {
	path=$1
	smv_get "$path" ref >/dev/null 2>&1 ||
		die "no lock entry for submodule '$path' in .gitsmv"
}

require_writable_root() {
	top=$(smv_top_level)
	test -w "$top" || die "repository root is not writable: $top"
}

require_clean_submodule() {
	path=$1
	dir=$(smv_submodule_dir "$path")
	if test ! -d "$dir/.git"; then
		return 0
	fi
	if ! git -C "$dir" diff-index --quiet HEAD -- 2>/dev/null; then
		die "submodule '$path' has uncommitted changes"
	fi
}

require_clean_parent() {
	if test -n "${SMV_FORCE:-}"; then
		return 0
	fi
	if ! git diff-index --quiet HEAD -- 2>/dev/null; then
		die "parent working tree has uncommitted changes (use --force)"
	fi
}

# Resolve ref inside submodule; prints full SHA to stdout.
resolve_ref() {
	path=$1
	ref=$2
	dir=$(smv_submodule_dir "$path")

	if test ! -d "$dir"; then
		die "submodule directory missing: $dir"
	fi

	git -C "$dir" fetch --quiet origin 2>/dev/null ||
		git -C "$dir" fetch --quiet 2>/dev/null || true

	if smv_is_sha40 "$ref"; then
		sha=$(git -C "$dir" rev-parse --verify "$ref^{commit}" 2>/dev/null) ||
			die "cannot resolve SHA $ref in $path"
		printf '%s' "$sha"
		return 0
	fi

	# Tag
	sha=$(git -C "$dir" rev-parse --verify "refs/tags/$ref^{commit}" 2>/dev/null) &&
		{ printf '%s' "$sha"; return 0; }

	# Branch (local, remote, origin)
	for candidate in "$ref" "origin/$ref" "refs/heads/$ref"; do
		sha=$(git -C "$dir" rev-parse --verify "$candidate^{commit}" 2>/dev/null) &&
			{ printf '%s' "$sha"; return 0; }
	done

	die "cannot resolve ref '$ref' in submodule '$path'"
}

smv_gitlink_sha() {
	path=$1
	which=${2:-HEAD}
	git rev-parse "$which:$path" 2>/dev/null
}

smv_worktree_sha() {
	path=$1
	dir=$(smv_submodule_dir "$path")
	if test -d "$dir/.git"; then
		git -C "$dir" rev-parse HEAD 2>/dev/null
	else
		echo ""
	fi
}
