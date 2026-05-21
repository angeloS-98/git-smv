#!/bin/sh

cmd_purge() {
	require_work_tree
	cd_to_toplevel

	ALL=
	PATHS=
	FORCE=
	while test $# -gt 0; do
		case $1 in
		--all) ALL=1; shift ;;
		--force|-f) FORCE=1; shift ;;
		*) PATHS="$PATHS $1"; shift ;;
		esac
	done

	if test -n "$ALL"; then
		PATHS=$(gm_list_paths)
	elif test -z "$(echo "$PATHS" | tr -d ' ')"; then
		die "usage: git smv purge [--all] [<path>...]"
	fi

	for path in $PATHS; do
		require_gitmodules_entry "$path"
		if test -z "$FORCE"; then
			require_clean_submodule "$path"
		fi
		
		git submodule deinit -f "$path" 2>/dev/null || true
		rm -rf ".git/modules/$path"
		smv_log_ok "purged local directory for $path"
	done
}
