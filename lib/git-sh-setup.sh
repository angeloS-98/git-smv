# Load Git shell library (die, usage, cd_to_toplevel, ...).
if test -z "${GITSMV_SH_SETUP:+set}"; then
	GITSMV_SH_SETUP=1
	GIT_EXEC_PATH=$(git --exec-path) || {
		echo "git-smv: cannot determine git exec path" >&2
		exit 2
	}
	if test ! -f "$GIT_EXEC_PATH/git-sh-setup"; then
		echo "git-smv: git-sh-setup not found in $GIT_EXEC_PATH" >&2
		exit 2
	fi
	# shellcheck source=/dev/null
	. "$GIT_EXEC_PATH/git-sh-setup"
fi
