import Base.download

"""
    download(gl::GitLink; verbose, loop_tout = 60.0)
    download(upfun::Function, gl::GitLink; verbose, loop_tout = 60.0)
    
Try a to sync the local repo with the remote.
Optionally, and after the pull, it will call `upfun(wdir)` to access the working directory.
This method will update the `pull` event token.
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function download(upfun::Function, gl::GitLink; 
        verbose = config(gl, :verbose), 
        lk_tout = config(gl, :lk_tout), 
        wdir_clear = config(gl, :wdir_clear), 
        tries = config(gl, :sync_tries), 
    )

    pull_ok = false

    lock(gl; tout = lk_tout) do

        # HARD PULL (Loop)
        pull_ok = _hard_pull(gl; verbose, wdir_clear, tries)
        pull_ok || return false # Handle fail

        # call fun
        wdir = repo_dir(gl)
        mkpath(wdir)
        upfun(wdir)

    end

    return pull_ok
end
download(gl::GitLink; kwargs...) = download(_do_nothing, gl; kwargs...)