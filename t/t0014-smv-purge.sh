#!/bin/sh
test_description='git smv purge tests'
TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh
ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'purge removes local submodule dir' '
	test_create_repo purge-repo &&
	test_create_submodule_upstream sub &&
	git -c protocol.file.allow=always submodule add ./sub my-sub &&
	git commit -m "add sub" &&
	git smv init --from-gitmodules &&
	test_path_is_file my-sub/.git &&
	git smv purge --all &&
	test_must_fail test_path_is_file my-sub/.git &&
	git smv install
'
test_done
