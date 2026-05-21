#!/bin/sh
test_description='git smv install tests'
TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh
ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'install auto-initializes if missing' '
	test_create_repo install-repo &&
	test_create_submodule_upstream sub &&
	git -c protocol.file.allow=always submodule add ./sub my-sub &&
	git commit -m "add sub" &&
	git smv install &&
	test -f .gitsmv &&
	echo "DUMPING .gitsmv" && cat .gitsmv && echo "END DUMP" &&
	git config -f .gitsmv --list &&
	git smv check
'
test_done
