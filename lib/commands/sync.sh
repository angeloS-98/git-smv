#!/bin/sh

cmd_sync() {
require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file
require_gitsmv_file
assert_not_in_merge

ALL=
PATHS=
while test $# -gt 0; do
	case $1 in
	--all)
		ALL=1
		shift
		;;
	--dry-run|-n)
		SMV_DRY_RUN=1
		shift
		;;
	--allow-partial)
		SMV_ALLOW_PARTIAL=1
		shift
		;;
	--force|-f)
		SMV_FORCE=1
		shift
		;;
	*)
		PATHS="$PATHS $1"
		shift
		;;
	esac
done

require_clean_parent
require_gitmodules
SMV_STRICT=1
smv_lock_validate

if test -n "$ALL"; then
	PATHS=$(gm_list_paths)
elif test -z "$(echo "$PATHS" | tr -d ' ')"; then
	die "usage: git smv sync [--all] [<path>...]"
fi

for path in $PATHS; do
	require_gitmodules_entry "$path"

	if ! smv_get "$path" ref >/dev/null 2>&1; then
		if test -n "${SMV_ALLOW_PARTIAL:-}"; then
			warn "skipping $path (no lock entry)"
			continue
		fi
		die "no lock entry for $path"
	fi

	version=$(smv_get "$path" version)
	test -n "$version" || die "submodule '$path' missing version in .gitsmv"

	resolved=$(smv_get "$path" resolved)
	test -n "$resolved" || die "submodule '$path' missing resolved (run 'git smv lock')"

	if test -n "${SMV_DRY_RUN:-}"; then
		smv_log_info "would sync $path -> $(smv_short_sha "$resolved")"
		continue
	fi

	git submodule update --init "$path"
	dir=$(smv_submodule_dir "$path")
	git -C "$dir" checkout --detach "$resolved" ||
		die "checkout failed for $path at $resolved"

	smv_log_ok "synced $path -> $(smv_short_sha "$resolved")"
done
}
