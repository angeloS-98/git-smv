# Roadmap — Git guidelines alignment

Items planned after v1 (see project plan §1.4 / §9).

## Documentation

- [ ] Expand `Documentation/git-smv.adoc` with Git manpage macros and per-command sections
- [ ] Build man page with AsciiDoctor in `make man`

## Tests

- [ ] Adopt Git `t/test-lib.sh` conventions (`test_expect_success`, fuller harness)
- [ ] Expand integration tests (lock, sync, bump, add/remove)

## Shell / UX

- [ ] CodingGuidelines shell audit (`/bin/sh`, avoid bashisms)
- [ ] Shared `parse-options` for flags (`--force`, `--dry-run`, …)
- [ ] Optional `git-sh-i18n` for translated messages

## Distribution

- [ ] `make install-exec` documented and tested in CI
- [ ] Distribution packages (deb/rpm)
- [ ] Windows notes (PATH install)

## Upstream (optional)

- [ ] Proposal to include in Git as `SCRIPT_SH` with `command-list.txt` entry

## Product (out of scope for now)

- [ ] `git smv install` post-checkout hook
- [ ] Nested submodule unified lock
- [ ] GitHub Action for CI
- [ ] Cryptographic signing of `.gitsmv`
