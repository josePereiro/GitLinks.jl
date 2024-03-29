function git_status(gl::GitLink)
    repodir = repo_dir(gl)
    _check_gitdir(repodir) || return
    _read_bash("git -C $(repodir) status 2>&1"; verbose = true, ignorestatus = true)
    return nothing
end