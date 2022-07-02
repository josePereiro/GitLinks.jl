"""
    upload_stage(upfun::Function, gl::GitLink; verbose = false, loop_tout = 60.0)
    upload_stage(gl::GitLink; verbose = false, loop_tout = 60.0)

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify
the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
Then an attempt is made to synchronize the changes with the upstream repo.
This method will update all events tokens `pull/stage/push`.
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function upload_stage(gl::GitLink; 
        verbose = config(gl, :verbose), 
        lk_tout = config(gl, :lk_tout), 
        force = config(gl, :force_sync), 
        wdir_clear = config(gl, :wdir_clear), 
        stage_clear = config(gl, :stage_clear),
        tries = config(gl, :sync_tries), 
    )

    return sync_link(gl; 
        verbose, lk_tout, force, 
        stage_clear, wdir_clear, tries, 
        stage_merge = true # force merge
    )
end

function upload_stage(upfun::Function, gl::GitLink; lk_tout = 60.0, kwargs...)
    stage(upfun, gl; lk_tout) || return false
    return upload_stage(gl; kwargs...)
end