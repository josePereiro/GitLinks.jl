function send_force_push_signal(gl::GitLink; ncommits = 1, upload_kwargs...)

    ok_sync = _send_force_push_signal(gl, ncommits; upload_kwargs...)

    return ok_sync
end