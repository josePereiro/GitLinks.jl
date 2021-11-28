function _fetch(repodir::String, url::String; verbose = false)
    
    !_check_gitdir(repodir) && return false
    
    rhash = _remote_HEAD_hash(url)
    isempty(rhash) && return false

    # do fetch
    _run("git -C $(repodir) fetch 2>&1"; verbose, ignorestatus = true)

    # check success
    clist = _list_commits(repodir, "origin/main"; count = 1)
    return !isempty(clist) && rhash == clist[1]
end
_fetch(gl::GitLink; verbose = false) = _fetch(repo_dir(gl), remote_url(gl); verbose)