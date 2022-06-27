"""
    upload_wdir(fun::Function, gl::GitLink; tout = 60.0)

Allow to access the working directory of the GitLink just before a `push event`.
The function `fun(working_dir)` will be executed and it should access
the files into `working_dir`.
Any changes to those files will be commited (please do not mess up the `.git` folder).
It is recommended that `fun` not to be an expensive function.
This method will update the `pull/push` events tokens.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function upload_wdir(upfun::Function, gl::GitLink; 
        verbose = false, 
        tout = 60.0, 
        tries = 1,
        clearwd = true, 
    )
    
    # prepare
    wdir = repo_dir(gl)
    mkpath(wdir)
    before_push = () -> upfun(wdir)
    
    # sync
    return _sync_link(gl; 
        before_push, 
        tries,
        tout, 
        verbose, 
        force = true, # force sync
        clearwd,
        merge_stage = false, # do not upload stage
        clearstage = false, # do not upload stage
    )
end