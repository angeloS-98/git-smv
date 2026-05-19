# Tests for git-smv

Tests use a minimal TAP-style harness in `test-lib.sh` (v1). Future versions
may adopt Git's full `t/test-lib.sh` from the Git tree.

Run from the repository root:

    make test

Or:

    PATH="$(pwd):$PATH" prove -v t/*.sh

Trash directories `t/trash_directory.*` are created during tests and removed
on the next run.
