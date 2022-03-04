"""
    download(gl::GitLink; verbose, tout = 60.0)
    download(upfun::Function, gl::GitLink; verbose, tout = 60.0)
    
Try a to sync the local repo with te remote.
Optionally, and after the pull, it will call `upfun(wdir)` to access the working directory.
This method will update the `pull` event token.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function download(upfun::Function, gl::GitLink; verbose = false, tout = 60.0)

    pull_ok = false

    lock(gl; tout) do

        # HARD PULL (Loop)
        pull_ok = hard_pull(gl; verbose, clearwd = true)
        if !pull_ok # Handle fail
            add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
            return false
        end
        _set_pull_token(gl) # Aknowlage successful pull

        # call fun
        wdir = repo_dir(gl)
        mkpath(wdir)
        upfun(wdir)

    end

    return pull_ok
end
download(gl::GitLink; kwargs...) = download((wdir) -> nothing, gl; kwargs...)