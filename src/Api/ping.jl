function ping(gl::GitLink; 
        tout = 30.0,
        verbose = config(gl, :verbose),
        self_ping = false,
        onping::Function = () -> nothing
    )

    tout = min(tout, 5 * 60.0) # max 5 min

    # send signal
    verbose && @info("Sending ping signal")
    ok_sync = _send_force_push_signal(gl, tout; verbose = false)
    !ok_sync && (verbose && @error("Sync failed"); return false)
    verbose && @info("Ping signal sended")
    
    rhash0 = _remote_HEAD_hash(gl)
    chash0 = _HEAD_hash(gl)
    
    # globals
    init_t = time()
    ping_t = time()
    ping_count = 0
    acc_t = 0.0
    time_ = Inf
    fb_count_ = 0

    try

        while true

            fb_count_ += 1

            # time out
            if (time() - init_t) > tout 
                break
            end

            left_ = max(round(tout - (time() - init_t); sigdigits = 3), 0.0)
            
            
            # hashes
            chash = _HEAD_hash(gl)
            rhash = _remote_HEAD_hash(gl)
            
            # connection
            if isempty(rhash)

                if verbose 
                    msg = string(
                        "Connection failed, ", 
                        "remote url: ", remote_url(gl), ", ",
                        "time left: ", left_, "(s)"
                    )
                    @warn(msg)
                end
                
                sleep(3.0)
                
                continue
            end

            # ping

            new_remote_hash = rhash0 != rhash
            local_unsync = (chash == chash0) && (chash != rhash)
            if new_remote_hash && (local_unsync || self_ping)

                time_ = round(time() - ping_t; sigdigits = 3)
                ping_t = time()
                ping_count += 1
                acc_t += time_

                if verbose 
                    msg = string(
                        "  Ping ", ping_count, " succeeded, ", 
                        "time: ", time_, "(s), ", 
                        "time left: ", left_, "(s)"
                    )
                    @info(msg)
                end

                onping()
                rhash0 = rhash
                fb_count_ = 0
            else
                if verbose && iszero(rem(fb_count_, 10))
                    msg = string(
                        "Waiting, ", 
                        "remote hash: ", first(rhash, 7), ", ",
                        "time left: ", left_, "(s)"
                    )
                    @info(msg)
                    fb_count_ = 0
                end
            end
            
            
            sleep(0.5)
        
        end # while true
        
    catch err
        (err isa InterruptException) || rethrow(err)
    end

    tot_time_ = round(time() - init_t; sigdigits = 3)
    main_time_ = round(acc_t / ping_count; sigdigits = 3)
    if verbose 
        msg = string(
            "Done!, ", 
            "ping count: ", ping_count, ", ", 
            "ave time: ", main_time_, "(s), ", 
            "total time: ", tot_time_, "(s)"
        )
        @info(msg)
    end

    return ping_count > 0
end