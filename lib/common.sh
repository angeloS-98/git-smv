# Shared paths and global options.

GITSMV_FILE=${GITSMV_FILE-}
SMV_FORCE=
SMV_STRICT=
SMV_DRY_RUN=
SMV_ALLOW_PARTIAL=

smv_top_level() {
	git rev-parse --show-toplevel
}

smv_default_gitsmv_file() {
	printf '%s/.gitsmv' "$(smv_top_level)"
}

smv_set_gitsmv_file() {
	if test -n "$1"; then
		case $1 in
		/*) GITSMV_FILE=$1 ;;
		*) GITSMV_FILE="$(smv_top_level)/$1" ;;
		esac
	else
		GITSMV_FILE=$(smv_default_gitsmv_file)
	fi
}

smv_ensure_gitsmv_file() {
	if test -z "${GITSMV_FILE:-}"; then
		smv_set_gitsmv_file ""
	fi
}

smv_submodule_dir() {
	path=$1
	top=$(smv_top_level)
	printf '%s/%s' "$top" "$path"
}

smv_is_sha40() {
	echo "$1" | grep -Eq '^[0-9a-f]{40}$'
}

smv_short_sha() {
	echo "$1" | cut -c1-12
}

# git-sh-i18n defines warn; provide fallback for minimal environments.
if ! type warn >/dev/null 2>&1; then
	warn() {
		printf 'warning: %s\n' "$*" >&2
	}
fi
