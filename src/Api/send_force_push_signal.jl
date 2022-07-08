function send_force_push_signal(gl::GitLink; tout = 1.0, upload_kwargs...)

    ok_sync = _send_force_push_signal(gl, tout; upload_kwargs...)

    return ok_sync
end