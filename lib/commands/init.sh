#!/bin/sh

cmd_init() {
require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file

FROM_GITMODULES=
while test $# -gt 0; do
	case $1 in
	--from-gitmodules)
		FROM_GITMODULES=1
		shift
		;;
	--force|-f)
		SMV_FORCE=1
		shift
		;;
	*)
		die "unknown option for init: $1"
		;;
	esac
done

assert_not_in_merge
require_writable_root

if test -f "$(smv_lock_path)" && test -z "${SMV_FORCE:-}"; then
	die ".gitsmv already exists (use --force)"
fi

smv_lock_init_file

if test -n "$FROM_GITMODULES"; then
	require_gitmodules
	for path in $(gm_list_paths); do
		require_gitmodules_entry "$path"
		sha=$(smv_gitlink_sha "$path" HEAD 2>/dev/null) ||
			sha=$(smv_worktree_sha "$path")
		ref=$(gm_get "$path" branch)
		if test -z "$ref"; then
			ref=HEAD
		fi
		version=$(smv_get "$path" version 2>/dev/null) || version=
		if test -z "$version" && test -n "$sha"; then
			version=$ref
		fi
		smv_lock_ensure_entry "$path" "$ref" "$version" "$sha"
	done
fi

smv_log_ok "Created $(smv_lock_path)"
}
