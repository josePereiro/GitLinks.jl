## ---------------------------------------------------------
# force signal
const _PUSH_EXTERNAL_SIGNAL_NAME = "gl-push-signal"
_push_ext_signal_file(gl::GitLink) = 
    joinpath(global_state_dir(gl), _PUSH_EXTERNAL_SIGNAL_NAME)

function _write_push_ext_signal(gl::GitLink, vtime)
    fn = _push_ext_signal_file(gl)
    _mkdir(fn)
    extime = time() + vtime
    write(fn, string(extime))
    return extime
end

function _read_push_ext_signal(gl::GitLink)
    fn = _push_ext_signal_file(gl)
    !isfile(fn) && return -1.0
    txt = read(fn, String)
    extime = tryparse(Float64, txt)
    extime = isnothing(extime) ? -1.0 : extime
    return extime
end

function _is_push_ext_signal_on(gl::GitLink) 
    curr_signal = _read_push_ext_signal(gl)
    last_signal = get!(gl, :last_push_ext, -1.0)
    set!(gl, :last_push_ext, curr_signal)
    is_new_signal = last_signal != curr_signal
    is_valid = curr_signal > time() 
    return is_new_signal || is_valid
end

function _send_force_push_signal(gl::GitLink, tout; upload_kwargs...)

    ok_sync = upload_wdir(gl; verbose = false, upload_kwargs...) do _
        _write_push_ext_signal(gl, tout)
    end

    return ok_sync
end