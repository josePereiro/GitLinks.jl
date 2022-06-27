import Base.download

"""
    download(gl::GitLink; verbose, tout = 60.0)
    download(upfun::Function, gl::GitLink; verbose, tout = 60.0)
    
Try a to sync the local repo with the remote.
Optionally, and after the pull, it will call `upfun(wdir)` to access the working directory.
This method will update the `pull` event token.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function Base.download(upfun::Function, gl::GitLink; 
        verbose = false, 
        tout = 60.0, 
        clearwd = true, 
        tries = 1
    )

    pull_ok = false

    lock(gl; tout) do

        # HARD PULL (Loop)
        pull_ok = _hard_pull(gl; verbose, clearwd, tries)
        pull_ok || return false # Handle fail

        # call fun
        wdir = repo_dir(gl)
        mkpath(wdir)
        upfun(wdir)

    end

    return pull_ok
end
download(gl::GitLink; kwargs...) = download((wdir) -> nothing, gl; kwargs...)