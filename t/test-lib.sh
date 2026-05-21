# Minimal TAP helpers (subset of Git test-lib).

test_count=0
test_failures=0
test_bailout=0

export GIT_AUTHOR_NAME="SMV Test"
export GIT_AUTHOR_EMAIL="smv@test.example"
export GIT_COMMITTER_NAME="SMV Test"
export GIT_COMMITTER_EMAIL="smv@test.example"
export GIT_ALLOW_PROTOCOL="file"
export GIT_CONFIG_PARAMETERS="'protocol.file.allow=always'"

test_start_() {
	test_count=$((test_count + 1))
	_test_name=$1
}

test_ok_() {
	if test "$1" = 0; then
		printf 'ok %d - %s\n' "$test_count" "$_test_name"
	else
		test_failures=$((test_failures + 1))
		printf 'not ok %d - %s\n' "$test_count" "$_test_name"
		if test -n "${2:-}"; then
			printf '#   %s\n' "$2"
		fi
	fi
}

test_expect_success() {
	test_start_ "$1"
	shift
	(
		eval "$*"
	)
	_test_exit=$?
	test_ok_ $_test_exit
}

test_expect_failure() {
	test_start_ "$1"
	shift
	(
		eval "$*" &&
		exit 1
	) || exit 0
	_test_exit=$?
	test_ok_ $_test_exit
}

test_done() {
	if test $test_bailout -ne 0; then
		printf 'Bail out!\n'
	fi
	printf '1..%d\n' "$test_count"
	if test $test_failures -ne 0; then
		exit 1
	fi
}

debug() {
	printf '# %s\n' "$*" >&2
}

test_create_repo() {
	name=$1
	rm -rf "trash_directory.$name"
	mkdir "trash_directory.$name"
	cd "trash_directory.$name" || exit 1
	git init -q
	git config user.email "smv@test.example"
	git config user.name "SMV Test"
}

test_must_fail() {
	"$@"
	_exit=$?
	if test $_exit -eq 0; then
		echo "test_must_fail: command succeeded: $*" >&2
		return 1
	fi
	return 0
}

test_cmp() {
	diff -u "$1" "$2"
}

test_path_is_file() {
	if test ! -f "$1"; then
		echo "File $1 doesn't exist" >&2
		return 1
	fi
	return 0
}

test_path_is_dir() {
	if test ! -d "$1"; then
		echo "Directory $1 doesn't exist" >&2
		return 1
	fi
	return 0
}

test_output_contains() {
	if ! grep -q "$1" "$2"; then
		echo "Expected '$1' in '$2'" >&2
		cat "$2" >&2
		return 1
	fi
	return 0
}

test_create_submodule_upstream() {
	_name=$1
	mkdir -p "$_name"
	git -C "$_name" init -q
	git -C "$_name" config user.email "s@e"
	git -C "$_name" config user.name "S"
	echo one >"$_name/f"
	git -C "$_name" add f
	git -C "$_name" commit -qm "c1"
}
