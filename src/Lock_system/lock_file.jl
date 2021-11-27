# lock_file
const _LOCK_FILE_NAME = ".gl.lock"
_lock_file(gl::GitLink) = joinpath(_local_state_dir(gl), _LOCK_FILE_NAME)
const _LOCK_FILE_KEY = :lock_file_key
lock_file(gl::GitLink) = _gl_dat_fun(gl, _LOCK_FILE_KEY, _lock_file)

const _LOCK_DFT_SAFE_TIME = 0.2
const _LOCK_DFT_WAIT_TIME = 1.0
const _LOCK_DFT_VALID_TIME = 30.0
const _LOCK_DFT_TIME_OUT = 0.0

function _write_lock_file(lf::String; 
        lid::String = rand_str(), 
        vtime::Float64 = _LOCK_DFT_VALID_TIME
    )
    _mkdir(lf)
    ttag = time() + vtime
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

_is_valid_ttag(ttag) = ttag > time()

function has_lock(lf::String, lid::String)
    
    # read
    curr_lid, ttag = _read_lock_file(lf)

    # del if invalid
    if !_is_valid_ttag(ttag)
        rm(lf; force = true)
        return false
    end

    # test
    return lid == curr_lid
end

function release_lock(lf::String, lid::String)
    !isfile(lf) && return false
    !has_lock(lf, lid) && return false
    rm(lf; force = true)
    return true
end

function _get_lock(lf::String; 
        vtime = _LOCK_DFT_VALID_TIME, 
        lid = rand_str()
    )
    if isfile(lf)
        curr_lid, ttag = _read_lock_file(lf)
        _isvalid = _is_valid_ttag(ttag)

        # check if is taken
        if _isvalid
            if curr_lid == lid
                return (curr_lid, ttag) # is mine
            else
                return ("", ttag) # is taken
            end
        else
            # del if invalid
            rm(lf; force = true)
        end
    end
    return _write_lock_file(lf; lid, vtime)
end

function get_lock(lf::String; 
        vtime = _LOCK_DFT_VALID_TIME, 
        wt = _LOCK_DFT_WAIT_TIME, 
        tout = _LOCK_DFT_TIME_OUT, 
        lid = rand_str()
    )

    if tout > 0.0
        t0 = time()
        while true
            lid, ttag = _get_lock(lf; vtime, lid)
            !isempty(lid) && return (lid, ttag)
            (time() - t0) > tout && return ("", ttag)
            sleep(wt)
        end
    else
        return _get_lock(lf; vtime, lid)
    end
end

import Base.lock
function lock(f::Function, gl::GitLink;
        vtime = _LOCK_DFT_VALID_TIME, 
        wt = _LOCK_DFT_WAIT_TIME, 
        tout = _LOCK_DFT_TIME_OUT,
        lfile = lock_file(gl), 
        lid = rand_str()
    )
    try
        lid, ttag = get_lock(lfile; vtime, wt, tout)
        f()
    finally
        release_lock(lfile, lid)
    end
end