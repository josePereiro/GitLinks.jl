## ---------------------------------------------------------
# force signal
const _PUSH_EXTERNAL_SIGNAL_NAME = "gl-push-signal"
_push_ext_signal_file(gl::GitLink) = 
    joinpath(global_state_dir(gl), _PUSH_EXTERNAL_SIGNAL_NAME)

function _write_push_ext_signal(gl::GitLink, com::Int)
    fn = _push_ext_signal_file(gl)
    _mkdir(fn)
    signal = string(_rand_token(), "," , com)
    write(fn, signal)
    return signal
end

function _read_push_ext_signal(gl::GitLink)
    fn = _push_ext_signal_file(gl)
    !isfile(fn) && return ("", -1)
    dig = split(read(fn, String), ",")
    length(dig) != 2 && return ("", -1)
    return (dig[1], _tryparse(Int, dig[2], -1))
end

function _is_push_ext_signal_on(gl::GitLink) 
    sig_token, sig_count = _read_push_ext_signal(gl)
    isempty(sig_token) && return false
    st_token, st_count = state(gl, :push_signal)
    
    is_new = sig_token != st_token
    is_new && (st_count = min(sig_count, 10)) # force max 10
    _state!(gl, :push_signal, (sig_token, max(0, st_count - 1)))
    is_alive = st_count > 0

    # # Deb
    # @info("_is_push_ext_signal_on: ", 
    #     sig_token, sig_count,
    #     st_token, st_count,
    #     is_new,
    #     is_alive, 
    # )

    return is_new || is_alive
end

function _send_force_push_signal(gl::GitLink, ncommits::Int; upload_kwargs...)

    @assert ncommits < 50

    ok_sync = upload_wdir(gl; verbose = false, upload_kwargs...) do _
        ncommits =  max(ncommits, 1)
        # # Deb
        # @info("_send_force_push_signal ++ : ", 
        #     curr_cc, 
        #     ncommits = max(ncommits + 1, 1), 
        #     target_cc
        # )
        _write_push_ext_signal(gl, ncommits)
    end

    return ok_sync
end