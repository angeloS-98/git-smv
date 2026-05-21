#!/bin/sh
test_description='git smv upgrade tests'
TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh
ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'upgrade fetches and updates resolved' '
	test_create_repo upg-repo &&
	test_create_submodule_upstream sub &&
	git -c protocol.file.allow=always submodule add ./sub my-sub &&
	git commit -m "add sub" &&
	git smv init --from-gitmodules &&
	old=$(git config -f .gitsmv --get submodule.my-sub.resolved) &&
	git -C sub commit --allow-empty -m "new commit upstream" &&
	git smv upgrade --all &&
	new=$(git config -f .gitsmv --get submodule.my-sub.resolved) &&
	test "$old" != "$new"
'
test_done
