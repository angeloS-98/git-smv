#!/bin/sh

cmd_check() {
	require_work_tree
	cd_to_toplevel
	smv_ensure_gitsmv_file

	ALL=
	PATHS=
	PORCELAIN=
	QUIET=
	WORKTREE=
	while test $# -gt 0; do
		case $1 in
		--all) ALL=1; shift ;;
		--porcelain) PORCELAIN=1; shift ;;
		-q|--quiet) QUIET=1; shift ;;
		--worktree) WORKTREE=1; shift ;;
		*) PATHS="$PATHS $1"; shift ;;
		esac
	done

	if ! smv_lock_exists; then
		test -n "$QUIET" || smv_log_warn "no .gitsmv at $(smv_lock_path)"
		return 0
	fi
	require_gitmodules

	if test -n "$ALL"; then
		PATHS=$(gm_list_paths)
	elif test -z "$(echo "$PATHS" | tr -d ' ')"; then
		test -n "$QUIET" || die "usage: git smv check [--all] [<path>...]"
		return 1
	fi

	diff_found=0
	for path in $PATHS; do
		require_gitmodules_entry "$path"
		resolved=$(smv_get "$path" resolved 2>/dev/null)
		if test -z "$resolved"; then
			test -n "$QUIET" || smv_log_warn "no resolved SHA for $path in .gitsmv"
			diff_found=1
			continue
		fi

		index=$(git rev-parse ":$path" 2>/dev/null) || index=
		if test "$resolved" != "$index"; then
			diff_found=1
			if test -z "$QUIET"; then
				if test -n "$PORCELAIN"; then
					printf 'LOCK %s INDEX %s %s\n' "$(smv_short_sha "$resolved")" "$(smv_short_sha "$index")" "$path"
				else
					smv_log_error "$path: .gitsmv resolved=$(smv_short_sha "$resolved"), index=$(smv_short_sha "$index")"
				fi
			fi
		fi

		if test -n "$WORKTREE"; then
			work=$(smv_worktree_sha "$path") || work=
			if test "$resolved" != "$work"; then
				diff_found=1
				if test -z "$QUIET"; then
					if test -n "$PORCELAIN"; then
						printf 'LOCK %s WORKTREE %s %s\n' "$(smv_short_sha "$resolved")" "$(smv_short_sha "$work")" "$path"
					else
						smv_log_error "$path: .gitsmv resolved=$(smv_short_sha "$resolved"), worktree=$(smv_short_sha "$work")"
					fi
				fi
			fi
		fi
	done

	return $diff_found
}
