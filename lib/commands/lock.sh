#!/bin/sh

cmd_lock() {
require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file
require_gitsmv_file
assert_not_in_merge
require_writable_root

ALL=
PATHS=
while test $# -gt 0; do
	case $1 in
	--all)
		ALL=1
		shift
		;;
	*)
		PATHS="$PATHS $1"
		shift
		;;
	esac
done

if test -n "$ALL"; then
	PATHS=$(gm_list_paths)
elif test -z "$(echo "$PATHS" | tr -d ' ')"; then
	die "usage: git smv lock [--all] [<path>...]"
fi

require_gitmodules
smv_lock_validate

for path in $PATHS; do
	require_gitmodules_entry "$path"
	require_smv_entry "$path"
	ref=$(smv_get "$path" ref)
	git -C "$(smv_top_level)" submodule update --init --recursive "$path" 2>/dev/null ||
		git submodule update --init "$path"
	sha=$(resolve_ref "$path" "$ref")
	smv_set "$path" resolved "$sha"
	smv_log_ok "$path: resolved $(smv_short_sha "$sha") (ref $ref)"
done
}
