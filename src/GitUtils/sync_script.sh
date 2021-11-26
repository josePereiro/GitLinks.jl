# ---------------------------------------------------------------------------------------
# args 
if [ $# -lt 7 ]; then
	echo "Not enougth arguments."
	echo "Usage: sync_script <repodir> <url> <op_mode> <commit_msg> <success_token> <fail_token> <clonning_token>"
	exit 1
fi

sh_repodir="$1" 
sh_url="$2" 
sh_op_mode="$3" 
sh_commit_msg="$4" 
sh_success_token="$5" 
sh_error_token="$6" 
sh_clonning_token="$7"

# ---------------------------------------------------------------------------------------
# variables 
sh_repodir_git="${sh_repodir}/.git" 
sh_gitignore="${sh_repodir}/.gitignore" 
sh_recovery_dir="${sh_repodir}/.recovery" 
sh_recovery_dir_git="${sh_recovery_dir}/.git" 
sh_startup_file="${sh_repodir}/sync_startup"

git_user_name="$(git config user.name)"
git_user_email="$(git config user.email)"
if [ -z "${git_user_name}" ]; then
	git_user_name="GitWorker"
fi
if [ -z "${git_user_email}" ]; then
	git_user_email="fake@email.com"
fi

# ---------------------------------------------------------------------------------------
# startup 
[ -f "${sh_startup_file}" ] && source "${sh_startup_file}"

# ---------------------------------------------------------------------------------------
# utils 
_success () {
	echo "success token: ${sh_success_token}"
	rm -frd "${sh_recovery_dir}" # clear recoveri_dir
	exit 0
}
_error () { 
	local msg="$1"
	echo "error token: ${sh_error_token}"
	echo "error: ${msg}"
	rm -frd "${sh_repodir}" # force clone next time
	rm -frd "${sh_recovery_dir}" # clear recoveri_dir
	exit 1
}
_check_root () {
	local realroot="$(git -C "${sh_repodir}" rev-parse --show-toplevel)"
	local realdummy="${realroot}/.git/._gw_sync_dummy"
	local refdummy="${sh_repodir}/.git/._gw_sync_dummy"

	if [ -d "${realroot}/.git" ]; then
		# remove reference dummy
		rm -f "${refdummy}"
		
		# check real dummy
		if [ -f "${realdummy}" ]; then
			_error "unexpected repo root, expected: ${sh_repodir}, found: ${realroot}"
		fi

		# I create a dummy using the refpath and then 
		# check if it exists in the real
		touch "${refdummy}"
		if [ ! -f "${realdummy}" ]; then
			rm -f "${refdummy}"
			_error "unexpected repo root, expected: ${sh_repodir}, found: ${realroot}"
		fi
	fi
	rm -f "${refdummy}"
	return 0
}
_is_force_clone_mode () {
	[ "${sh_op_mode}" = "FORCE_CLONE" ] && return 0
	[ "${sh_op_mode}" = "FORCE_CLONE_AND_PUSH" ] && return 0
	return 1
}
_is_pull_mode () {
	[ "${sh_op_mode}" = "PULL_OR_CLONE" ] && return 0
	[ "${sh_op_mode}" = "PULL_OR_CLONE_AND_PUSH" ] && return 0
	[ "${sh_op_mode}" = "FORCE_CLONE" ] && return 0
	return 1
}
_is_push_mode () {
	[ "${sh_op_mode}" = "FORCE_CLONE_AND_PUSH" ] && return 0
	[ "${sh_op_mode}" = "PUSH" ] && return 0
	return 1
}
_is_no_op_mode () {
	[ "${sh_op_mode}" = "NO_OP" ] && return 0
	return 1
}

# ---------------------------------------------------------------------------------------
# check no op
_is_no_op_mode && _success

# ---------------------------------------------------------------------------------------
# go to root 
mkdir -p "${sh_repodir}" || _error "unable to create repo dir" 
cd "${sh_repodir}" || _error "unable to cd repo dir" 

# ---------------------------------------------------------------------------------------
# remove any lock
rm -f "${sh_repodir_git}/index.lock"

# ---------------------------------------------------------------------------------------
# pull or clone if necessary
_is_force_clone_mode && rm -frd "${sh_repodir}" 
if _is_pull_mode; then
	_check_root || _error "_check_root fails" 
	if [ -d "${sh_repodir_git}" ]; then
		echo
		echo "pulling hard"
		git -C "${sh_repodir}" fetch || _error "git fetch failed" 
		git -C "${sh_repodir}" reset --hard FETCH_HEAD || _error "git reset --hard FETCH_HEAD failed" 
	else
		echo
		echo "clonning repo, token: ${sh_clonning_token}"
		mkdir -p "${sh_recovery_dir}" || _error "unable to create recovery dir" 
		git -C "${sh_repodir}" clone --depth=1 "${sh_url}" "${sh_recovery_dir}" || _error "git clone failed" 
		mv -f "${sh_recovery_dir_git}" "${sh_repodir_git}" || _error "recovery copy failed"
		git -C "${sh_repodir}" fetch || : # unchecked I know
		git -C "${sh_repodir}" reset --hard FETCH_HEAD || : # unchecked I know
	fi
fi
[ "$?" != "0" ] && _error "PULL or CLONE fails"

# ---------------------------------------------------------------------------------------
# clear recovery_dir
rm -frd "${sh_recovery_dir}" || _error "at rm -frd recovery_dir" 

# ---------------------------------------------------------------------------------------
# push 
if _is_push_mode; then
	echo
	echo "hard pushing"
	_check_root || _error "_check_root fails" 
	rm -frd "${sh_gitignore}" || _error "rm -frd .gitignore" 
	git -C "${sh_repodir}" add -A || _error "add -A failed" 
	git -C "${sh_repodir}" status || _error "git status failed"
	git -C "${sh_repodir}" diff-index --quiet HEAD && _success # If nothing to commit _success
	git -C "${sh_repodir}" -c user.name="${git_user_name}" -c user.email="${git_user_email}" commit -am "${sh_commit_msg}" || _error "commit -am 'msg' failed" 
	git -C "${sh_repodir}" push --force || _error "git push failed" 
fi
[ "$?" != "0" ] && _error "PUSH fails"

# ---------------------------------------------------------------------------------------
# success 
_success