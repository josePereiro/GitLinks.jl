"""
    stage(upfun::Function, gl::GitLink; loop_tout = 60.0, flag = true)

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
The GitLink Server will upload_stage the staged files in its next iter or `upload_stage` call.
To prevent this, set the acknowledge (`flag`) to false.
Staging is usuful (instead of `upload_wdir`) for acumulating changes and reduce the push rate of the link.
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was successful.
"""
function stage(upfun::Function, gl::GitLink; 
        lk_tout = config(gl, :lk_tout), flag = true
    )

    ok_flag = false
    sdir = stage_dir(gl)
    mkpath(sdir)

    lock(gl; tout = lk_tout) do
        upfun(sdir)
        flag && _set_stage_token(gl)
        ok_flag = true
    end

    return ok_flag
end
stage(gl::GitLink; kwargs...) = stage(_do_nothing, gl; kwargs...)

# TODO: test this
"""
    stage(gl::GitLink, paths::Vector{String}; root::String = "", loop_tout = 60.0, flag = true)

Stage the `files` (by copying them to the GitLink stage folder).
The GitLink Server will upload_stage them in its next iter.
To prevent this set the acknowledge (`flag`) to false.
Staging is usuful (instead of `upload_wdir`) for acumulating changes and reduce the push rate of the link.
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
If a `root` (as a kwarg) is provided, the tree structure relative to it will be respected.
Ex: if root = "A" and a file path is "A/B/C.txt" it will be staged as "gl-stage/B/C.txt".
Otherwise (root = ""), the file will be copied in the repo's stage "gl-stage/C.txt".
Returns `true` if the action was successful.
"""
function stage(gl::GitLink, paths::Vector{String}; 
        root::String = "", loop_tout = 60.0, flag = true
    )

    return stage(gl;  loop_tout, flag) do sdir
        
        sdir = abspath(sdir)

        if isempty(root)
            for src_file in paths
                dest_file = joinpath(sdir, basename(src_file))
                _cp(src_file, dest_file)
            end
        else
            root = abspath(root)
            for src_file in paths
                src_file = abspath(src_file)
                dest_file = replace(src_file, root => sdir)
                _mkdir(dest_file)
                _cp(src_file, dest_file)
            end
        end
        
    end
end