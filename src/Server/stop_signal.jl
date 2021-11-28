const _STOP_SIGNAL_KEY = :stop_dignal
_get_stop_signal(gl::GitLink) = get!(gl, _STOP_SIGNAL_KEY, false)
_set_stop_signal!(gl, sig::Bool) = set!(gl, _STOP_SIGNAL_KEY, sig)