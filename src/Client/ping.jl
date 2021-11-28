function ping(gl::GitLink; 
        tout = 30.0, 
        verbose = true,
        atping::Function = () -> nothing
    )

    # send signal
    @info("Sending ping signal")
    before_push = () -> _write_ping_signal(gl, tout)
    ok_sync = sync_link(gl::GitLink; verbose, force = true, before_push)
    !ok_sync && error("Sync fail")
    @info("Ping signal sended")

    try

        # init time
        t0 = time()
        
        # wait response
        @info("Waiting for response...")
        while true
            is_pull_required(gl) && break
            (time() - t0) > 1.5 * tout && break
            sleep(1.0)
        end
        ok_flag = is_pull_required(gl)
        
        # show results
        if ok_flag
            @info("Ping succeded", time = round(time() - t0; sigdigits = 3))
            atping()
            return true
        else
            @error("Ping fail", tout)
            return false
        end
    
    catch err
        (err isa InterruptException) && return
        rethrow(err)
    end
    
end