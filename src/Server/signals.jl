## ---------------------------------------------------------
# Ping
const _PING_SIGNAL_FILE_NAME = "gl-ping-signal"
_ping_signal_file(gl::GitLink) = 
    joinpath(global_state_dir(gl), _PING_SIGNAL_FILE_NAME)

function _write_ping_signal(gl::GitLink, vtime = 60.0)
    fn = _ping_signal_file(gl)
    _mkdir(fn)
    extime = time() + vtime
    write(fn, string(extime))
    return extime
end

function _read_ping_signal(gl::GitLink)
    fn = _ping_signal_file(gl)
    !isfile(fn) && return -1.0
    txt = read(fn, String)
    extime = tryparse(Float64, txt)
    extime = isnothing(extime) ? -1.0 : extime
    return extime
end

_do_ping(gl::GitLink) = _read_ping_signal(gl) > time()
