#!/bin/sh

cmd_install() {
	require_work_tree
	cd_to_toplevel
	smv_ensure_gitsmv_file

	NO_SYNC=
	while test $# -gt 0; do
		case $1 in
		--no-sync) NO_SYNC=1; shift ;;
		*) die "unknown option for install: $1" ;;
		esac
	done

	if ! smv_lock_exists; then
		smv_log_info ".gitsmv non esiste, inizializzazione da .gitmodules in corso..."
		. "$SMV_LIB_ROOT/lib/commands/init.sh"
		cmd_init --from-gitmodules
	fi

	smv_log_info "Clonazione e aggiornamento dei sottomoduli..."
	git submodule update --init --recursive

	if test -z "$NO_SYNC"; then
		smv_log_info "Sincronizzazione alle versioni bloccate..."
		. "$SMV_LIB_ROOT/lib/commands/sync.sh"
		cmd_sync --all
	fi
}
