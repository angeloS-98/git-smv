# Helpers for .gitmodules

gm_gitmodules_file() {
	printf '%s/.gitmodules' "$(smv_top_level)"
}

gm_exists() {
	test -f "$(gm_gitmodules_file)"
}

gm_config_key() {
	path=$1
	field=$2
	printf 'submodule.%s.%s' "$path" "$field"
}

gm_get() {
	path=$1
	field=$2
	file=$(gm_gitmodules_file)
	git config -f "$file" --get "$(gm_config_key "$path" "$field")" 2>/dev/null
}

gm_has() {
	path=$1
	gm_get "$path" path >/dev/null 2>&1
}

gm_list_paths() {
	file=$(gm_gitmodules_file)
	test -f "$file" || return 0
	git config -f "$file" --get-regexp '^submodule\..*\.path$' 2>/dev/null |
		sed -n 's/^submodule\.\(.*\)\.path[[:space:]].*$/\1/p'
}

require_gitmodules() {
	gm_exists || die "no .gitmodules in repository"
}

require_gitmodules_entry() {
	path=$1
	gm_has "$path" || die "submodule path not in .gitmodules: $path"
}
