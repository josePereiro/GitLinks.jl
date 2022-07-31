function _fetch(repodir::String, url::String; verbose = false)
    
    _check_gitdir(repodir) || return false
    
    rhash = _remote_HEAD_hash(url)
    isempty(rhash) && return false

    # do fetch
    _read_bash("git -C $(repodir) fetch 2>&1"; verbose, ignorestatus = true)

    # check success
    # TODO: add a ceck here
    return true
end
_fetch(gl::GitLink; verbose = false) = _fetch(repo_dir(gl), remote_url(gl); verbose)