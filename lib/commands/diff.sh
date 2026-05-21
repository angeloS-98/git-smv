#!/bin/sh

cmd_diff() {
require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file

PORCELAIN=
while test $# -gt 0; do
	case $1 in
	--porcelain)
		PORCELAIN=1
		shift
		;;
	*)
		die "unknown option for diff: $1"
		;;
	esac
done

if ! smv_lock_exists; then
	warn "no .gitsmv"
	exit 0
fi

if ! gm_exists; then
	warn "no .gitmodules"
	exit 0
fi

diff_found=0
for path in $(gm_list_paths); do
	resolved=$(smv_get "$path" resolved 2>/dev/null) || continue
	head=$(smv_gitlink_sha "$path" HEAD 2>/dev/null) || head=
	index=$(git rev-parse ":$path" 2>/dev/null) || index=

	if test "$resolved" = "$head" && test "$resolved" = "$index"; then
		continue
	fi
	diff_found=1

	if test -n "$PORCELAIN"; then
		printf 'M %s lock:%s head:%s index:%s\n' \
			"$path" "$(smv_short_sha "$resolved")" "$(smv_short_sha "$head")" "$(smv_short_sha "$index")"
	else
		printf '%s:\n' "$path"
		printf '  .gitsmv resolved: %s\n' "$(smv_short_sha "$resolved")"
		printf '  HEAD gitlink:     %s\n' "$(smv_short_sha "$head")"
		printf '  index gitlink:    %s\n' "$(smv_short_sha "$index")"
	fi
done

return $diff_found
}
