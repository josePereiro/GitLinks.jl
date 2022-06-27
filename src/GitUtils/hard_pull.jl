

function _hard_pull(gl::GitLink; 
        verbose = false, 
        clearwd = true, 
        tries = 1
    )

    for t in 1:max(tries, 1)

        ignorestatus = true
        gl_repo = repo_dir(gl)
        url = remote_url(gl)
        mkpath(gl_repo)

        # check remote connection
        rhash = _remote_HEAD_hash(url)
        isempty(rhash) && continue

        # enforce repo format (lazy method)
        _format_repo!(gl_repo, url; verbose)

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
            _rm(gl_repo) # something failed
            continue
        end

        # Aknowlage successful pull
        _set_pull_token(gl)
        
        return true
    end

    return false
end