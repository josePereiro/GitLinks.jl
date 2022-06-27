function ping(gl::GitLink; 
        tout = 30.0, 
        verbose = false,
        onping::Function = () -> nothing
    )

    # send signal
    @info("Sending ping signal")
    ok_sync = upload_wdir(gl; verbose) do wdir_
        _write_ping_signal(gl, tout)
    end
    !ok_sync && (@error("Sync fail"); return false)
    @info("Ping signal sended")
    
    rhash0 = _remote_HEAD_hash(gl)
    
    # globals
    tot_t = time()
    ping_t = time()
    ping_count = 0

    client_tout = tout + min(tout * 0.5, 15.0)

    try
        @info("Waiting for response...", )

        while true
            for _ in 1:3
                if (time() - tot_t) > client_tout 
                    tot_time = round(time() - tot_t; sigdigits = 3)
                    @info("Time out, total time: $(tot_time)(s)")
                    return ping_count > 0
                end

                chash = _HEAD_hash(gl)
                rhash = _remote_HEAD_hash(gl)

                # ping!
                new_remote_hash = rhash0 != rhash
                remote_ahead = rhash != chash
                if new_remote_hash && remote_ahead
                    time_ = round(time() - ping_t; sigdigits = 3)
                    ping_count += 1
                    @info("Ping $(ping_count) succeeded, time: $(time_)(s)")
                    onping()
                    ping_t = time()
                    rhash0 = rhash
                end

                sleep(1.0)
            end
        end
        
    catch err
        (err isa InterruptException) && return
        rethrow(err)
    end

    return ping_count > 0
end