function _read_token_file(fn::String)
    !isfile(fn) && return ""
    return string(strip(read(fn, String)))
end

# version-token
const _STAGE_VERSION_TOKEN_FILE_NAME = "gl-stage-version-token"
_stage_version_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _STAGE_VERSION_TOKEN_FILE_NAME)

function _set_new_stage_version(gl::GitLink)
    vtoken_file = _stage_version_token_file(gl)
    _mkdir(vtoken_file)
    new_token = rand_str()
    write(vtoken_file, new_token)
    return new_token
end

# push-token
const _STAGE_PUSHED_TOKEN_FILE_NAME = "gl-stage-pushed-token"
_stage_pushed_token_file(gl::GitLink) = 
    joinpath(local_state_dir(gl), _STAGE_PUSHED_TOKEN_FILE_NAME)
