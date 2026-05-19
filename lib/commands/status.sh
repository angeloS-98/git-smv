#!/bin/sh

require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file

VERBOSE=
while test $# -gt 0; do
	case $1 in
	-v|--verbose)
		VERBOSE=1
		shift
		;;
	*)
		die "unknown option for status: $1"
		;;
	esac
done

if ! smv_lock_exists; then
	warn "no .gitsmv at $(smv_lock_path)"
	exit 0
fi

if ! gm_exists; then
	warn "no .gitmodules"
	exit 0
fi

printf '%-30s %-12s %-20s %-12s %-12s %s\n' \
	"PATH" "VERSION" "REF" "RESOLVED" "WORKTREE" "DRIFT"

for path in $(gm_list_paths); do
	url=$(gm_get "$path" url)
	version=$(smv_get "$path" version 2>/dev/null) || version="-"
	ref=$(smv_get "$path" ref 2>/dev/null) || ref="-"
	resolved=$(smv_get "$path" resolved 2>/dev/null) || resolved="-"
	work=$(smv_worktree_sha "$path") || work="-"
	head=$(smv_gitlink_sha "$path" HEAD 2>/dev/null) || head="-"

	drift=no
	if test "$resolved" != "-" && test "$work" != "-" && test "$resolved" != "$work"; then
		drift=yes
	fi
	if test "$resolved" != "-" && test "$head" != "-" && test "$resolved" != "$head"; then
		drift=yes
	fi
	if test "$ref" = "-" || test "$version" = "-"; then
		drift=yes
	fi

	printf '%-30s %-12s %-20s %-12s %-12s %s\n' \
		"$path" "$version" "$ref" "$(smv_short_sha "$resolved")" "$(smv_short_sha "$work")" "$drift"

	if test -n "$VERBOSE"; then
		printf '  url: %s\n' "$url"
		printf '  index/HEAD gitlink: %s\n' "$(smv_short_sha "$head")"
	fi
done

# Lock entries without .gitmodules
for path in $(smv_list_paths); do
	if ! gm_has "$path"; then
		warn "lock entry without .gitmodules: $path"
	fi
done
