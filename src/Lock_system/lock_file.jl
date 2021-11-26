# lock_file
const _LOCK_FILE_NAME = ".gl.lock"
_lock_file(gl::GitLink) = joinpath(_local_state_dir(gl), _LOCK_FILE_NAME)
const _LOCK_FILE_KEY = :lock_file_key
lock_file(gl::GitLink) = _gl_dat_fun(gl, _LOCK_FILE_KEY, _lock_file)


const _LOCK_SAFE_TIME = 0.2
const _LOCK_WAIT_TIME = 1.0
const _LOCK_VALID_TIME = 30.0

function _create_lock_file(lf::String, lid::String = rand_str(), ttag::Float64=time() + _LOCK_VALID_TIME)
    _mkdir(lf)
    write(lf, string(lid, " ", ttag))
    return lid, ttag
end

const _LOCK_FILE_REGEX = Regex("^(?<lid>[A-Za-z0-9]+)\\s(?<ttag>[0-9]\\.[0-9e]+)\$")
function _read_lock_file(lf::String)
    !isfile(lf) && return ("", -1.0)
    cont = read(lf, String)
    m = match(_LOCK_FILE_REGEX, cont)
    isnothing(m) && return ("", -1.0)
    ttag = tryparse(Float64, m[:ttag])
    ttag = isnothing(ttag) ? -1.0 : ttag
    return (m[:lid], ttag)
end

# function get_lock(lf::String)
#     isfile(lf)
# end

function has_lock(lf::String, lid::String)
    
    # read
    curr_lid, ttag = _read_lock_file(lf)

    # del if invalid
    if ttag < time()
        rm(lf; force = true)
        return false
    end

    # test
    return lid == curr_lid
end

function release_lock(lf::String, lid::String)
    !has_lock(lf, lid) && return false
    rm(lf; force = true)
    return true
end