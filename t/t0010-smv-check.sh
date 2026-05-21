#!/bin/sh
test_description='git smv check tests'
TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh
ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'check detects drift' '
	test_create_repo check-repo &&
	test_create_submodule_upstream sub &&
	git -c protocol.file.allow=always submodule add ./sub my-sub &&
	git commit -m "add sub" &&
	git smv init --from-gitmodules &&
	git smv check --all &&
	git -C my-sub commit --allow-empty -m "new" &&
	git add my-sub &&
	test_must_fail git smv check --all
'
test_done
