#!/bin/sh

cmd_remove() {
require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file
assert_not_in_merge
require_writable_root

if test $# -lt 1; then
	die "usage: git smv remove <path> [--keep-dir]"
fi

path=$1
shift

KEEP_DIR=
while test $# -gt 0; do
	case $1 in
	--keep-dir)
		KEEP_DIR=1
		shift
		;;
	*)
		die "unknown option for remove: $1"
		;;
	esac
done

require_gitmodules_entry "$path"

if smv_lock_exists; then
	smv_unset_section "$path"
fi

git submodule deinit -f "$path" 2>/dev/null || true

if test -z "$KEEP_DIR"; then
	git rm -f "$path" 2>/dev/null || rm -rf "$path"
	git config -f "$(gm_gitmodules_file)" --remove-section "submodule.$path" 2>/dev/null || true
else
	git rm --cached -f "$path" 2>/dev/null || true
	git config -f "$(gm_gitmodules_file)" --remove-section "submodule.$path" 2>/dev/null || true
fi

smv_log_ok "removed submodule $path"
}
