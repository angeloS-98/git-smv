# Read/write/validate .gitsmv via git config.

SMV_FORBIDDEN_KEYS='url path branch update ignore'

smv_lock_path() {
	smv_ensure_gitsmv_file
	printf '%s' "$GITSMV_FILE"
}

smv_lock_exists() {
	test -f "$(smv_lock_path)"
}

smv_lock_init_file() {
	file=$(smv_lock_path)
	if test -f "$file" && test -z "${SMV_FORCE:-}"; then
		die ".gitsmv already exists at $file (use --force to replace)"
	fi
	rm -f "$file"
	git config -f "$file" smv.version 1
}

smv_config_key() {
	path=$1
	field=$2
	printf 'submodule.%s.%s' "$path" "$field"
}

smv_get() {
	path=$1
	field=$2
	file=$(smv_lock_path)
	git config -f "$file" --get "$(smv_config_key "$path" "$field")" 2>/dev/null
}

smv_set() {
	path=$1
	field=$2
	value=$3
	file=$(smv_lock_path)
	git config -f "$file" "$(smv_config_key "$path" "$field")" "$value"
}

smv_unset_section() {
	path=$1
	file=$(smv_lock_path)
	git config -f "$file" --remove-section "submodule.$path" 2>/dev/null || true
}

smv_list_paths() {
	file=$(smv_lock_path)
	git config -f "$file" --get-regexp '^submodule\..*\.ref$' 2>/dev/null |
		sed -n 's/^submodule\.\(.*\)\.ref[[:space:]].*$/\1/p'
}

smv_schema_version() {
	file=$(smv_lock_path)
	git config -f "$file" --get smv.version 2>/dev/null || echo ""
}

smv_lock_validate() {
	file=$(smv_lock_path)
	test -f "$file" || die "missing .gitsmv at $file"

	schema=$(smv_schema_version)
	if test "$schema" != "1"; then
		die "unsupported or missing smv.version in $file (expected 1)"
	fi

	for path in $(smv_list_paths); do
		if ! gm_has "$path"; then
			if test -n "${SMV_STRICT:-}"; then
				die "lock entry for '$path' not in .gitmodules"
			else
				warn "lock entry for '$path' not in .gitmodules"
			fi
		fi

		ref=$(smv_get "$path" ref)
		test -n "$ref" || die "submodule '$path' missing ref in $file"

		if test -n "${SMV_STRICT:-}"; then
			version=$(smv_get "$path" version)
			test -n "$version" || die "submodule '$path' missing version in $file"
		fi

		resolved=$(smv_get "$path" resolved)
		if test -n "$resolved" && ! smv_is_sha40 "$resolved"; then
			die "submodule '$path' has invalid resolved SHA: $resolved"
		fi

		for key in $SMV_FORBIDDEN_KEYS; do
			echo "DEBUG ENV FOR $path $key:" >&2
			env | grep GIT >&2
			val=$(git config -f "$file" --get "$(smv_config_key "$path" "$key")" 2>/dev/null) || true
			if test -n "${val:-}"; then
				msg="submodule '$path' must not set $key in .gitsmv (use .gitmodules)"
				if test -n "${SMV_STRICT:-}"; then
					die "$msg"
				else
					warn "$msg"
				fi
			fi
		done
	done
}

smv_lock_ensure_entry() {
	path=$1
	ref=$2
	version=${3-}
	resolved=${4-}

	test -n "$ref" || die "ref required for $path"

	if ! smv_get "$path" ref >/dev/null 2>&1; then
		:
	fi
	smv_set "$path" ref "$ref"
	if test -n "$version"; then
		smv_set "$path" version "$version"
	fi
	if test -n "$resolved"; then
		smv_set "$path" resolved "$resolved"
	fi
}
