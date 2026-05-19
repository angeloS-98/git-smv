#!/bin/sh

require_work_tree
cd_to_toplevel
smv_ensure_gitsmv_file
require_gitsmv_file
assert_not_in_merge
require_writable_root

if test $# -lt 1; then
	die "usage: git smv bump <path> --ref <ref> [--version <version>] [--to-latest]"
fi

path=$1
shift

REF=
VERSION=
TO_LATEST=
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
	--to-latest)
		TO_LATEST=1
		shift
		;;
	--force|-f)
		SMV_FORCE=1
		shift
		;;
	*)
		die "unknown option for bump: $1"
		;;
	esac
done

require_gitmodules_entry "$path"
require_smv_entry "$path"
require_clean_submodule "$path"

if test -n "$TO_LATEST"; then
	REF=$(gm_get "$path" branch)
	test -n "$REF" || REF=$(smv_get "$path" ref)
fi

test -n "$REF" || die "bump requires --ref or --to-latest"

if test -z "$VERSION"; then
	VERSION=$(smv_get "$path" version)
	test -n "$VERSION" || VERSION=$REF
fi

smv_set "$path" ref "$REF"
smv_set "$path" version "$VERSION"

git submodule update --init "$path"
sha=$(resolve_ref "$path" "$REF")
smv_set "$path" resolved "$sha"

echo "bumped $path -> ref $REF version $VERSION resolved $(smv_short_sha "$sha")"
