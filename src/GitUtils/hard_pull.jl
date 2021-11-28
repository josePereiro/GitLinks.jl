function _clear_wd(gl_repo)
    for path in _readdir(gl_repo; join = true)
        endswith(path, ".git") && continue
        _rm(path)
    end
end

function hard_pull(gl::GitLink; verbose = false, clearwd = true)

    ignorestatus = true
    gl_repo = repo_dir(gl)
    url = remote_url(gl)
    mkpath(gl_repo)

    # check remote connection
    rhash = _remote_HEAD_hash(url)
    isempty(rhash) && return false

    # # enforce repo format (lazy method)
    # _format_repo!(gl_repo, url; verbose) || return false

    # clear wd
    clearwd && _clear_wd(gl_repo)

    if _check_gitdir(gl_repo)
        # if all ok 
        _run("git -C $(gl_repo) fetch 2>&1"; verbose, ignorestatus)
        _run("git -C $(gl_repo) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
    else
        # clone
        _rm(gl_repo)
        mkpath(gl_repo)
        _run("git -C $(gl_repo) clone --depth=1 $(url) $(gl_repo) 2>&1"; verbose, ignorestatus)
        _run("git -C $(gl_repo) fetch 2>&1"; verbose, ignorestatus)
        _run("git -C $(gl_repo) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
    end

    # check success
    chash = _HEAD_hash(gl_repo)
    if rhash != chash
        _rm(gl_repo) # something fail
        return false
    end
    return true
end