function _up_push_dummy(gl::GitLink)
    dir = global_state_dir(gl)
    mkpath(dir) 
    dummy = joinpath(dir, ".gl-push-dummy")
    write(dummy, rand_str())
end

function soft_push(gl::GitLink; verbose = false, commit_msg = "Up at $(time())")
    
    # repo info
    rootdir = repo_dir(gl)
    url = remote_url(gl)

    # check remote
    rhash0 = _check_remote(url)
    isempty(rhash0) && return false

    # check it is sync
    chash0 = _curr_hash(rootdir)
    (rhash0 != chash0) && return false

    # check repodir
    !_check_gitdir(rootdir) && return false

    # soft push
    _up_push_dummy(gl) # Update push dummy (always push)
    _rm(joinpath(rootdir, ".gitignore")) # avoid interference
    _run("git -C $(rootdir) add -A 2>&1"; verbose)
    _run("git -C $(rootdir) status 2>&1"; verbose)
    user_name = get_global_config("user.name", "GitLink")
    user_email = get_global_config("user.email", "fake@email.com")
    _run("git -C $(rootdir) -c user.name='$(user_name)' -c user.email='$(user_email)' commit -am '$(commit_msg)' 2>&1"; verbose)
    _run("git -C $(rootdir) push 2>&1"; verbose)

    # check success
    rhash1 = _check_remote(url)
    chash1 = _curr_hash(rootdir)
    if rhash0 == rhash1 && chash0 == chash1
        _rm(rootdir) # something fail
        return false
    end
    return true
end