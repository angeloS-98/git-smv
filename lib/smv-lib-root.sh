# Resolve SMV_LIB_ROOT: source tree, $SMV_LIB_ROOT, or $prefix/share/git-smv.

smv_resolve_lib_root() {
	if test -n "${SMV_LIB_ROOT:-}" &&
		test -f "$SMV_LIB_ROOT/lib/git-sh-setup.sh"; then
		return 0
	fi

	_here=$(CDPATH= cd "$(dirname "$0")" && pwd)

	# Run from repository / symlink next to lib/
	if test -f "$_here/lib/git-sh-setup.sh"; then
		SMV_LIB_ROOT=$_here
		export SMV_LIB_ROOT
		return 0
	fi

	# make install: $prefix/bin/git-smv -> $prefix/share/git-smv/lib/
	_prefix=$(CDPATH= cd "$_here/.." && pwd) || return 1
	if test -f "$_prefix/share/git-smv/lib/git-sh-setup.sh"; then
		SMV_LIB_ROOT=$_prefix/share/git-smv
		export SMV_LIB_ROOT
		return 0
	fi

	printf '%s\n' \
		"git-smv: cannot find lib (expected $_here/lib or $_prefix/share/git-smv/lib)" \
		"Re-run 'make install' or set SMV_LIB_ROOT to the install share path." >&2
	return 1
}
