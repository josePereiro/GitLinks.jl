const _STAGE_TOKEN_FILE_NAME! = "gl-stage-token"
_stage_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _STAGE_TOKEN_FILE_NAME!)

const _LAST_STAGE_TOKEN_KEY = :last_stage_token_key
last_stage_token(gl::GitLink) = get!(gl, _LAST_STAGE_TOKEN_KEY, "")
last_stage_token!(gl::GitLink, token) = set!(gl, _LAST_STAGE_TOKEN_KEY, string(token))

function _is_stage_token_sync(gl::GitLink)
    stfile = _stage_token_file(gl)
    !isfile(stfile) && return false
    disk_token = strip(read(stfile, String))
    isempty(disk_token) && return false
    last_token = last_stage_token(gl)
    return disk_token == last_token
end

function _sync_stage_token!(gl::GitLink)
    stfile = _stage_token_file(gl)
    _mkdir(stfile)
    new_token = rand_str()
    write(stfile, new_token)
    last_stage_token!(gl, new_token)
    return new_token
end

function _merge_stage(gl::GitLink)
    rdir = repo_dir(gl)
    sdir = stage_dir(gl)

    for src in _readdir(sdir)
        dest = replace(src, sdir => rdir)
        _cp(src, dest)
    end
end

"""
    stage!(gl::GitLink, files::Vector{String}; root::String = "", tout = 60.0)

Stage the `files` (by copying them to the GitLink stage folder).
The GitLink Server will upload them in its next iter.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
If a `root` (as a kwarg) is provided, the tree structure relative to it will be respected.
Ex: if root = "A" and a file path is "A/B/C.txt" it will be staged as "gl-stage/B/C.txt".
Otherwise (root = ""), the file will be copied in the repo's stage "gl-stage/C.txt".
Returns `true` if the action was succeful.
"""
function stage!(gl::GitLink, files::Vector{String}; 
        root::String = "", tout = 60.0
    )

    ok_flag = false
    sdir = stage_dir(gl)
    mkpath(sdir)

    lock(gl; tout) do
        if isempty(root)
            for src_file in files
                dest_file = joinpath(sdir, basename(src_file))
                cp(src_file, dest_file; force = true)
            end
        else
            error("""root != "" not implemented, yet!!!!""")
        end
        _sync_stage_token!(gl)
        ok_flag = true
    end
    return ok_flag
end

"""
    stage!(upfun::Function, gl::GitLink; tout = 60.0))

Allow to modify the stage directory of the GitLink.
The function `upfun(stage_dir)` will be executed and it should copy/create/modify
the files into `stage_dir`.
It is recommended that `upfun` not to be an expensive function.
The GitLink Server will upload the staged files in its next iter.
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was succeful.
"""
function stage!(upfun::Function, gl::GitLink; 
        tout = 60.0
    )

    ok_flag = false
    sdir = stage_dir(gl)
    mkpath(sdir)

    lock(gl; tout) do
        upfun(sdir)
        _sync_stage_token!(gl)
        ok_flag = true
    end

    return ok_flag
end