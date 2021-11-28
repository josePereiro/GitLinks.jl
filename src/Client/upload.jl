"""
    upload(upfun::Function, gl::GitLink; verbose, tout = 60.0)

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify
the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
Then an attempt is made to synchronize the changes with the upstream repo.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was succeful.
"""
function upload(upfun::Function, gl::GitLink; verbose, tout = 60.0)
    stage(upfun, gl; tout) || return false
    return sync_link(gl; verbose, force = true)
end