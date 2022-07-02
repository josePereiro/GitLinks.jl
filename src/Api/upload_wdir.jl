function _upload_wdir_up_wrapper(gl::GitLink, upfun::Function)
    wdir = repo_dir(gl)
    mkpath(wdir)
    upfun(wdir)
end

"""
    upload_wdir(fun::Function, gl::GitLink; loop_tout = 60.0)

Allow to access the working directory of the GitLink just before a `push event`.
The function `fun(working_dir)` will be executed and it should access
the files into `working_dir`.
Any changes to those files will be commited (please do not mess up the `.git` folder).
It is recommended that `fun` not to be an expensive function.
This method will update the `pull/push` events tokens.
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function upload_wdir(upfun::Function, gl::GitLink; 
        verbose = config(gl, :verbose), 
        lk_tout = config(gl, :lk_tout), 
        tries = config(gl, :sync_tries), 
        wdir_clear = config(gl, :wdir_clear), 
    )
    
    # sync
    return sync_link(gl;
        before_push = (gl) -> _upload_wdir_up_wrapper(gl, upfun), 
        tries, lk_tout, verbose, wdir_clear,
        force = true, # force sync
        stage_merge = false, # do not upload stage
        stage_clear = false, # do not touch stage
    )
end

upload_wdir(gl::GitLink; kwargs...) = upload_wdir(_do_nothing, gl; kwargs...)