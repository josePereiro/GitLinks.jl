"""
    readwdir(fun::Function, gl::GitLink; tout = 60.0))

Allow to access the working directory of the GitLink.
The function `fun(working_dir)` will be executed and it should access
the files into `working_dir`.
Any changes to those files won't be commited (please do not mess up the `.git` folder).
It is recommended that `fun` not to be an expensive function.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the locking action was successful.
"""
function readwdir(fun::Function, gl::GitLink; 
        tout = 60.0
    )

    ok_flag = false
    wdir = repo_dir(gl)
    mkpath(wdir)

    # TODO: control lock vtime
    lock(gl; tout) do
        fun(wdir)
        ok_flag = true
    end
    return ok_flag

end

