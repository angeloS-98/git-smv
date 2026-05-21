#!/bin/sh
test_description='git smv list tests'
TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh
ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'list prints submodules' '
	test_create_repo list-repo &&
	test_create_submodule_upstream sub &&
	git -c protocol.file.allow=always submodule add ./sub my-sub &&
	git commit -m "add sub" &&
	git smv init --from-gitmodules &&
	git smv list >out &&
	test_output_contains "my-sub" out
'
test_done
