#!/bin/sh

require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file
assert_not_in_merge
require_writable_root

if test $# -lt 2; then
	die "usage: git smv add <path> <url> [--ref <ref>] [--version <version>]"
fi

path=$1
url=$2
shift 2

REF=
VERSION=
while test $# -gt 0; do
	case $1 in
	--ref)
		shift
		test $# -gt 0 || die "--ref requires a value"
		REF=$1
		shift
		;;
	--ref=*)
		REF=${1#--ref=}
		shift
		;;
	--version)
		shift
		test $# -gt 0 || die "--version requires a value"
		VERSION=$1
		shift
		;;
	--version=*)
		VERSION=${1#--version=}
		shift
		;;
	*)
		die "unknown option for add: $1"
		;;
	esac
done

if gm_has "$path"; then
	die "submodule path already exists: $path"
fi

if test -e "$path"; then
	die "path already exists: $path"
fi

if ! smv_lock_exists; then
	smv_lock_init_file
fi

git submodule add "$url" "$path"

if test -z "$REF"; then
	REF=$(gm_get "$path" branch)
	test -n "$REF" || REF=HEAD
fi

if test -z "$VERSION"; then
	VERSION=$REF
fi

sha=$(resolve_ref "$path" "$REF")
smv_lock_ensure_entry "$path" "$REF" "$VERSION" "$sha"

echo "added $path (ref $REF, version $VERSION, resolved $(smv_short_sha "$sha"))"
