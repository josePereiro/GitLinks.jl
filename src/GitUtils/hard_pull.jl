function _clear_wd(rootdir)
    for path in _readdir(rootdir; join = true)
        endswith(path, ".git") && continue
        _rm(path)
    end
end

function hard_pull(gl::GitLink; verbose = false, clearwd = true)

    ignorestatus = true
    rootdir = repo_dir(gl)
    mkpath(rootdir)
    url = remote_url(gl)

    # check remote
    rhash = _remote_HEAD_hash(url)
    isempty(rhash) && return false
    
    
    # clear wd
    clearwd && _clear_wd(rootdir)

    if _check_gitdir(rootdir)
        # if all ok 
        _run("git -C $(rootdir) fetch 2>&1"; verbose, ignorestatus)
        _run("git -C $(rootdir) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
    else
        # clone
        _rm(rootdir)
        mkpath(rootdir)
        _run("git -C $(rootdir) clone --depth=1 $(url) $(rootdir) 2>&1"; verbose, ignorestatus)
        _run("git -C $(rootdir) fetch 2>&1"; verbose, ignorestatus)
        _run("git -C $(rootdir) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
    end

    # check success
    chash = _HEAD_hash(rootdir)
    if rhash != chash
        _rm(rootdir) # something fail
        return false
    end
    return true
end