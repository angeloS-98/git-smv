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

smv_has_color() {
	if test -n "${NO_COLOR:-}"; then
		return 1
	fi
	_c=$(git config --get-colorbool color.ui 2>/dev/null)
	if test "$_c" = "true"; then
		return 0
	fi
	return 1
}

smv_log_info() {
	printf '%s\n' "$*"
}

smv_log_ok() {
	if smv_has_color; then
		printf '\033[32msuccess: %s\033[0m\n' "$*"
	else
		printf 'success: %s\n' "$*"
	fi
}

smv_log_warn() {
	if smv_has_color; then
		printf '\033[33mwarning: %s\033[0m\n' "$*" >&2
	else
		printf 'warning: %s\n' "$*" >&2
	fi
}

smv_log_error() {
	if smv_has_color; then
		printf '\033[31merror: %s\033[0m\n' "$*" >&2
	else
		printf 'error: %s\n' "$*" >&2
	fi
}

# git-sh-i18n defines warn; provide fallback for minimal environments.
if ! type warn >/dev/null 2>&1; then
	warn() {
		smv_log_warn "$*"
	}
fi
