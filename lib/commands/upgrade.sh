#!/bin/sh

cmd_upgrade() {
	require_work_tree
	cd_to_toplevel
	smv_ensure_gitsmv_file
	require_gitsmv_file
	assert_not_in_merge
	require_writable_root

	ALL=
	PATHS=
	REMOTE="origin"
	DRY_RUN=
	while test $# -gt 0; do
		case $1 in
		--all) ALL=1; shift ;;
		--remote) shift; test $# -gt 0 || die "--remote requires a value"; REMOTE=$1; shift ;;
		--remote=*) REMOTE=${1#--remote=}; shift ;;
		--dry-run|-n) DRY_RUN=1; SMV_DRY_RUN=1; shift ;;
		*) PATHS="$PATHS $1"; shift ;;
		esac
	done

	if test -n "$ALL"; then
		PATHS=$(gm_list_paths)
	elif test -z "$(echo "$PATHS" | tr -d ' ')"; then
		die "usage: git smv upgrade [--all] [<path>...] [--remote <name>]"
	fi

	require_clean_parent

	for path in $PATHS; do
		require_gitmodules_entry "$path"
		require_smv_entry "$path"
		ref=$(smv_get "$path" ref)
		old_resolved=$(smv_get "$path" resolved)

		smv_log_info "fetching $REMOTE per $path..."
		dir=$(smv_submodule_dir "$path")
		git -C "$dir" fetch --quiet "$REMOTE" 2>/dev/null || true

		new_resolved=$(resolve_ref "$path" "$REMOTE/$ref") || new_resolved=$(resolve_ref "$path" "$ref") || die "cannot resolve $ref in $path"

		if test "$old_resolved" != "$new_resolved"; then
			if test -z "$DRY_RUN"; then
				smv_set "$path" resolved "$new_resolved"
				smv_log_ok "upgraded $path: $(smv_short_sha "$old_resolved") -> $(smv_short_sha "$new_resolved")"
			else
				smv_log_info "would upgrade $path: $(smv_short_sha "$old_resolved") -> $(smv_short_sha "$new_resolved")"
			fi
		else
			smv_log_info "$path is already up to date at $(smv_short_sha "$old_resolved")"
		fi
	done
}
