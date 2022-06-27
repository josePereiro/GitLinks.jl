const _REMOTE_NAME = "origin"

#=
A GitLink repo demands:
- A remote named 'origin' (that's it!!!)
=#
function _format_repo!(repodir::String, url::String; verbose = false)
    ignorestatus = true

    # check remote
    curr_url = _remote_url(repodir)
    if curr_url != url
        # reset remote
        _run("git -C $(repodir) remote remove $(_REMOTE_NAME) 2>&1"; verbose, ignorestatus)
        _run("git -C $(repodir) remote add $(_REMOTE_NAME) $(url) 2>&1"; verbose, ignorestatus)

        cbranch = _curr_branch(repodir)
        _run("git -C $(repodir) branch --unset-upstream 2>&1"; verbose, ignorestatus)
        _run("git -C $(repodir) branch --set-upstream-to $(_REMOTE_NAME) $(cbranch) 2>&1"; verbose, ignorestatus)

        curr_url = _remote_url(repodir)
    end
    
    return curr_url == url
    
end

_format_repo!(gl::GitLink; verbose = false) = _format_repo!(repo_dir(gl), remote_url(gl); verbose)