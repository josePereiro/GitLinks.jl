function git_status(gl::String)
    repodir = repo_dir(gl)
    !_check_gitdir(repodir) && return
    _run("git -C $(repodir) status 2>&1"; verbose = true, ignorestatus = true)
    return nothing
end