#!/bin/sh

cmd_list() {
	require_work_tree
	cd_to_toplevel
	smv_ensure_gitsmv_file

	PORCELAIN=
	CHECK_REMOTE=
	while test $# -gt 0; do
		case $1 in
		--porcelain) PORCELAIN=1; shift ;;
		--check-remote) CHECK_REMOTE=1; shift ;;
		*) die "unknown option for list: $1" ;;
		esac
	done

	if ! smv_lock_exists; then
		return 0
	fi
	require_gitmodules

	if test -z "$PORCELAIN"; then
		if test -n "$CHECK_REMOTE"; then
			printf '%-30s %-12s %-20s %-12s %-12s\n' "PATH" "VERSION" "REF" "RESOLVED" "UPSTREAM"
		else
			printf '%-30s %-12s %-20s %-12s\n' "PATH" "VERSION" "REF" "RESOLVED"
		fi
	fi

	for path in $(gm_list_paths); do
		version=$(smv_get "$path" version 2>/dev/null) || version="-"
		ref=$(smv_get "$path" ref 2>/dev/null) || ref="-"
		resolved=$(smv_get "$path" resolved 2>/dev/null) || resolved="-"
		
		if test -n "$PORCELAIN"; then
			if test -n "$CHECK_REMOTE"; then
				upstream=$(git -C "$(smv_submodule_dir "$path")" ls-remote origin "$ref" 2>/dev/null | awk '{print $1}')
				test -z "$upstream" && upstream="-"
				printf '%s %s %s %s %s\n' "$path" "$version" "$ref" "$resolved" "$upstream"
			else
				printf '%s %s %s %s\n' "$path" "$version" "$ref" "$resolved"
			fi
		else
			if test -n "$CHECK_REMOTE"; then
				upstream=$(git -C "$(smv_submodule_dir "$path")" ls-remote origin "$ref" 2>/dev/null | awk '{print $1}')
				test -z "$upstream" && upstream="-"
				if test "$upstream" = "$resolved"; then
					upstream="="
				fi
				printf '%-30s %-12s %-20s %-12s %-12s\n' "$path" "$version" "$ref" "$(smv_short_sha "$resolved")" "$(smv_short_sha "$upstream")"
			else
				printf '%-30s %-12s %-20s %-12s\n' "$path" "$version" "$ref" "$(smv_short_sha "$resolved")"
			fi
		fi
	done
}
