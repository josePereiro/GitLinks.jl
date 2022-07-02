# At each push event, the stage will be merge and 
# it will be aknowlaged by synching the tokens
function _is_stage_up_to_day(gl::GitLink)

    curr_stage_token = _get_stage_token(gl)
    last_stage_token = _get_stage_pushed_token(gl)
    
    isempty(curr_stage_token) && return true # if is missing no stage has happened
    isempty(last_stage_token) && return false # If is missing let push

    return curr_stage_token == last_stage_token
end

function _merge_stage(gl::GitLink)
    rdir = repo_dir(gl)
    sdir = stage_dir(gl)

    _merge_dirs(sdir, rdir)
end