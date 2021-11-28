const _MAIN_BRANCH_NAME = "main"
const _REMOTE_MAIN_BRANCH_NAME = "origin/main"
const _REMOTE_NAME = "origin"

#=
GitLink demands:
- An remote named 'origin'
- Current branch to be named 'main'
=#
function _format_repo!(repodir::String, url::String; verbose = false)
    ignorestatus = true

    # check remote
    remotes = _curr_remotes(repodir)
    @show remotes
    if !(_REMOTE_NAME in remotes) 
        # reset remote
        _run("git -C $(repodir) remote remove $(_REMOTE_NAME) 2>&1"; verbose, ignorestatus)
        _run("git -C $(repodir) remote add $(_REMOTE_NAME) $(url) 2>&1"; verbose, ignorestatus)

        remotes = _curr_remotes(repodir)
        @show remotes
        !(_REMOTE_NAME in remotes) && return false
    end

    cbranch = _curr_branch(repodir)
    @show cbranch
    if cbranch != _MAIN_BRANCH_NAME

        # fetch
        _run("git -C $(repodir) fetch 2>&1"; verbose, ignorestatus)
        _run("git -C $(repodir) reset --hard FETCH_HEAD 2>&1"; verbose, ignorestatus)

        # rename branch
        _run("git -C $(repodir) branch -m $(cbranch) $(_MAIN_BRANCH_NAME) 2>&1"; verbose, ignorestatus)
        
        # try to delete on remote
        _run("git -C $(repodir) push $(_REMOTE_NAME) --delete $(cbranch) 2>&1"; verbose, ignorestatus)
        
        # try to push force
        _run("git -C $(repodir) branch --set-upstream $(_MAIN_BRANCH_NAME) $(_REMOTE_MAIN_BRANCH_NAME) 2>&1"; verbose, ignorestatus)
        _run("git -C $(repodir) push --force 2>&1"; verbose, ignorestatus)

        # check success
        chash = _HEAD_hash(repodir)
        rhash = _remote_HEAD_hash(url)
        (isempty(chash) || rhash != chash) && return false

    end

    return true
end

_format_repo!(gl::GitLink; verbose = false) = _format_repo!(repo_dir(gl), remote_url(gl); verbose)