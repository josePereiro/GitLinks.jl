function _fetch(repodir::String, url::String; verbose = false)
    
    !_check_gitdir(repodir) && return false
    
    rhash = _check_remote(url)
    isempty(rhash) && return false

    # do fetch
    _run("git -C $(repodir) fetch 2>&1"; verbose, ignorestatus = true)
    
    # check success
    chash = _HEAD_hash(repodir)
    return rhash == chash
end
_fetch(gl::GitLink; verbose = false) = _fetch(repo_dir(gl), remote_url(gl); verbose)