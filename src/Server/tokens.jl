# utils
function _read_token(fn::String)
    !isfile(fn) && return ""
    return string(strip(read(fn, String)))
end

function _write_token(fn::String, new_token::String = rand_str())
    _mkdir(fn)
    write(fn, new_token)
    return new_token
end

# tokens
# stage-token
const _STAGE_TOKEN_FILE_NAME = "gl-stage-token"
_stage_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _STAGE_TOKEN_FILE_NAME)
_set_stage_token(gl::GitLink, new_token::String = rand_str()) = 
    _write_token(_stage_token_file(gl), new_token)
_get_stage_token(gl::GitLink) = _read_token(_stage_token_file(gl))

# push-token
const _PUSH_TOKEN_FILE_NAME = "gl-push-token"
_push_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _PUSH_TOKEN_FILE_NAME)
_set_push_token(gl::GitLink, new_token::String = rand_str()) = 
    _write_token(_push_token_file(gl), new_token)
_get_push_token(gl::GitLink) = _read_token(_push_token_file(gl))

# stage-sync-token
const _STAGE_PUSHED_TOKEN_FILE_NAME = "gl-stage-pushed-token"
_stage_pushed_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _STAGE_PUSHED_TOKEN_FILE_NAME)
_set_stage_pushed_token(gl::GitLink) = 
    _write_token(_stage_pushed_token_file(gl), _get_stage_token(gl))
_get_stage_pushed_token(gl::GitLink) = _read_token(_stage_pushed_token_file(gl))


# pull-token
const _PULL_TOKEN_FILE_NAME = "gl-pull-token"
_pull_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _PULL_TOKEN_FILE_NAME)
_set_pull_token(gl::GitLink, new_token::String = rand_str()) = 
    _write_token(_pull_token_file(gl), new_token)
_get_pull_token(gl::GitLink) = _read_token(_pull_token_file(gl))