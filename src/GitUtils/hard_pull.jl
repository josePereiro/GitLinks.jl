

function _hard_pull(gl::GitLink; 
        verbose = false, 
        wdir_clear = true, 
        tries = 1
    )

    it = 0
    while true

        it += 1
        (it > tries) && return false

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
        wdir_clear && _clear_git_repo_wdir(gl_repo)

        if _check_gitdir(gl_repo)
            # if all ok 
            _read_bash("git -C $(gl_repo) fetch 2>&1"; verbose, ignorestatus)
            _read_bash("git -C $(gl_repo) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
        else
            # clone
            _rm(gl_repo)
            mkpath(gl_repo)
            _read_bash("git -C $(gl_repo) clone --depth=1 $(url) $(gl_repo) 2>&1"; verbose, ignorestatus)
            _read_bash("git -C $(gl_repo) fetch 2>&1"; verbose, ignorestatus)
            _read_bash("git -C $(gl_repo) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)
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