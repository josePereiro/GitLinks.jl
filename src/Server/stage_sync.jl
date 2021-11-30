# At each push event, the stage will be merge and 
# it will be aknowlaged by synching the tokens
function _is_stage_up_to_day(gl::GitLink)

    stage_token = _get_stage_token(gl)
    push_token = _get_push_token(gl)
    
    isempty(stage_token) && return false
    isempty(push_token) && return false

    return stage_token == push_token
end

function _merge_stage(gl::GitLink)
    rdir = repo_dir(gl)
    sdir = stage_dir(gl)

    for src in _readdir(sdir; join = true)
        dest = replace(src, sdir => rdir)
        _cp(src, dest)
    end
end