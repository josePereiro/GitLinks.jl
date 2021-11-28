function nuke_remote(gl::GitLink; 
        verbose = true
    )

    ignorestatus = true

    # repo info
    gl_repo = repo_dir(gl)
    url = remote_url(gl)

    # check remote
    rhash0 = _remote_HEAD_hash(url)
    isempty(rhash0) && return false

    # reinit
    _rm(gl_repo)
    mkpath(gl_repo)
    _run("git -C $(gl_repo) init 2>&1"; verbose, ignorestatus)

    # first commit
    _up_push_dummy(gl) # Update push dummy (always push)
    _run("git -C $(gl_repo) add -A 2>&1"; verbose, ignorestatus)
    _run("git -C $(gl_repo) status 2>&1"; verbose, ignorestatus)
    user_name = get_global_config("user.email", "GitLink")
    user_email = get_global_config("user.email", "fake@email.com")
    _run("git -C $(gl_repo) -c user.name='$(user_name)' -c user.email='$(user_email)' commit -am 'Boooom at $(time())' 2>&1"; verbose, ignorestatus)
    
    # rename branch
    _run("git -C $(gl_repo) branch -m master main"; verbose, ignorestatus)

    # check before
    _run("git --no-pager -C $(gl_repo) log 2>&1"; verbose, ignorestatus)
    
    # Set remotes
    _run("git -C $(gl_repo) remote add origin $(url) 2>&1"; verbose, ignorestatus)
    _run("git -C $(gl_repo) branch --set-upstream main origin/main 2>&1"; verbose, ignorestatus)
    
    # delete remote branch
    _run("git -C $(gl_repo) push -d origin main 2>&1"; verbose, ignorestatus)

    # Force push
    _run("git -C $(gl_repo) push origin main --force 2>&1"; verbose, ignorestatus)
    _run("git -C $(gl_repo) push origin :main 2>&1"; verbose, ignorestatus) # delete obsolete remote branches
    # _run("git -C $(gl_repo) push origin --mirror 2>&1"; verbose, ignorestatus)

    # check success
    rhash = _remote_HEAD_hash(url)
    chash = _HEAD_hash(gl_repo)
    if rhash != chash || rhash == rhash0
        _rm(gl_repo) # something fail
        return false
    end
    return true

end