function _up_push_dummy(gl::GitLink)
    dir = global_state_dir(gl)
    mkpath(dir) 
    dummy = joinpath(dir, ".gl-push-dummy")
    write(dummy, rand_str())
end

function soft_push(gl::GitLink; verbose = false, commit_msg = "Up at $(time())")
    
    # repo info
    gl_repo = repo_dir(gl)
    url = remote_url(gl)

    # check remote
    rhash0 = _remote_HEAD_hash(url)
    isempty(rhash0) && return false

    # # enforce repo format (lazy method)
    # _format_repo!(gl_repo, url; verbose) || return false

    # check it is sync
    chash0 = _HEAD_hash(gl_repo)
    (rhash0 != chash0) && return false

    # check repodir
    !_check_gitdir(gl_repo) && return false

    # soft push
    _up_push_dummy(gl) # Update push dummy (always push)
    _rm(joinpath(gl_repo, ".gitignore")) # avoid interference
    _run("git -C $(gl_repo) add -A 2>&1"; verbose)
    _run("git -C $(gl_repo) status 2>&1"; verbose)
    user_name = get_global_config("user.name", "GitLink")
    user_email = get_global_config("user.email", "fake@email.com")
    _run("git -C $(gl_repo) -c user.name='$(user_name)' -c user.email='$(user_email)' commit -am '$(commit_msg)' 2>&1"; verbose)
    _run("git -C $(gl_repo) push 2>&1"; verbose)

    # check success
    rhash1 = _remote_HEAD_hash(url)
    chash1 = _HEAD_hash(gl_repo)
    if rhash0 == rhash1 && chash0 == chash1
        _rm(gl_repo) # something fail
        return false
    end
    return true
end