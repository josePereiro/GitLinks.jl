function _is_stage_up_to_day(gl::GitLink)
    vtoken_file = _stage_version_token_file(gl)
    ptoken_file = _stage_pushed_token_file(gl)

    vtoken = _read_token_file(vtoken_file)
    ptoken = _read_token_file(ptoken_file)

    isempty(vtoken) && return false
    isempty(ptoken) && return false

    return vtoken == ptoken
end

function _sync_stage_tokens!(gl::GitLink)
    vtoken_file = _stage_version_token_file(gl)
    ptoken_file = _stage_pushed_token_file(gl)
    _mkdir(vtoken_file)
    new_token = rand_str()
    write(vtoken_file, new_token)
    write(ptoken_file, new_token)
    return new_token
end

function _merge_stage(gl::GitLink)
    rdir = repo_dir(gl)
    sdir = stage_dir(gl)

    for src in _readdir(sdir; join = true)
        dest = replace(src, sdir => rdir)
        _cp(src, dest)
    end
end

# """
#     stage(gl::GitLink, files::Vector{String}; root::String = "", tout = 60.0)

# Stage the `files` (by copying them to the GitLink stage folder).
# The GitLink Server will upload them in its next iter.
# This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
# If a `root` (as a kwarg) is provided, the tree structure relative to it will be respected.
# Ex: if root = "A" and a file path is "A/B/C.txt" it will be staged as "gl-stage/B/C.txt".
# Otherwise (root = ""), the file will be copied in the repo's stage "gl-stage/C.txt".
# Returns `true` if the action was succeful.
# """
# function stage(gl::GitLink, files::Vector{String}; 
#         root::String = "", tout = 60.0
#     )

#     ok_flag = false
#     sdir = stage_dir(gl)
#     mkpath(sdir)

#     lock(gl; tout) do
#         if isempty(root)
#             for src_file in files
#                 dest_file = joinpath(sdir, basename(src_file))
#                 cp(src_file, dest_file; force = true)
#             end
#         else
#             error("""root != "" not implemented, yet!!!!""")
#         end
#         _set_new_stage_version(gl)
#         ok_flag = true
#     end
#     return ok_flag
# end

"""
    stage(upfun::Function, gl::GitLink; tout = 60.0))

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify
the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
The GitLink Server will upload the staged files in its next iter.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was succeful.
"""
function stage(upfun::Function, gl::GitLink; 
        tout = 60.0
    )

    ok_flag = false
    sdir = stage_dir(gl)
    mkpath(sdir)

    lock(gl; tout) do
        upfun(sdir)
        _set_new_stage_version(gl)
        ok_flag = true
    end

    return ok_flag
end