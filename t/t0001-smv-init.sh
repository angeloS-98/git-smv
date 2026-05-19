#!/bin/sh
#
# Copyright (c) 2026
# Basic smoke tests for git smv init and .gitsmv format.

test_description='git smv init creates valid .gitsmv'

TDIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$TDIR" || exit 1
. ./test-lib.sh

ROOT=$(CDPATH= cd .. && pwd)
PATH="$ROOT:$PATH"
export PATH

test_expect_success 'init creates .gitsmv with smv.version' '
	test_create_repo init-basic &&
	git commit --allow-empty -m "root" &&
	git-smv init &&
	test -f .gitsmv &&
	test "$(git config -f .gitsmv --get smv.version)" = 1
'

test_expect_success 'init --from-gitmodules populates ref and resolved' '
	test_create_repo init-sub &&
	mkdir sub-upstream &&
	git -C sub-upstream init -q &&
	git -C sub-upstream config user.email "s@e" &&
	git -C sub-upstream config user.name "S" &&
	echo one >sub-upstream/f &&
	git -C sub-upstream add f &&
	git -C sub-upstream commit -qm "c1" &&
	git -c protocol.file.allow=always submodule add ./sub-upstream vendor/lib &&
	git add .gitmodules vendor/lib &&
	git commit -qm "add sub" &&
	git-smv init --from-gitmodules &&
	test -n "$(git config -f .gitsmv --get submodule.vendor/lib.ref)" &&
	test -n "$(git config -f .gitsmv --get submodule.vendor/lib.resolved)"
'

test_expect_success 'status runs without error' '
	test_create_repo status-run &&
	git commit --allow-empty -m "r" &&
	git-smv init &&
	git-smv status
'

test_done
