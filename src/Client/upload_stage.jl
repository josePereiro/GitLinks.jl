"""
    upload_stage(upfun::Function, gl::GitLink; verbose = false, tout = 60.0)
    upload_stage(gl::GitLink; verbose = false, tout = 60.0)

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify
the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
Then an attempt is made to synchronize the changes with the upstream repo.
This method will update all events tokens `pull/stage/push`.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function upload_stage(gl::GitLink; 
        verbose = false, 
        tout = 60.0, 
        force = false, 
        clearwd = true, 
        clearstage = false,
        tries = 1,
    )

    return _sync_link(gl; 
        verbose, tout, force, 
        clearstage, clearwd, tries, 
        merge_stage = true # force merge
    )
end

function upload_stage(upfun::Function, gl::GitLink; tout = 60.0, kwargs...)
    stage(upfun, gl; tout) || return false
    return upload_stage(gl; kwargs...)
end