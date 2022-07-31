function ping(gl::GitLink; 
        npings = 10,
        offset = 2,
        verbose = config(gl, :verbose),
        self_ping = false,
        tout = 360.0, # max 5 min
        onping::Function = () -> nothing
    )

    # send signal
    verbose && @info("Sending ping signal, npings: $(npings)")
    ncommits = max(npings, npings + offset)
    ok_sync = _send_force_push_signal(gl, ncommits; verbose = false)
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
    _wt = 0.5

    try

        while true

            fb_count_ += 1

            # time out
            ((time() - init_t) > tout) && break
            (ping_count >= npings) && break

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
                        "  Ping ", ping_count, "/", npings, ", " ,
                        "time: ", time_, "(s), ", 
                        "time left: ", left_, "(s)"
                    )
                    @info(msg)
                end

                onping()

                rhash0 = rhash
                fb_count_ = 0
                
            else
                if verbose && iszero(rem(fb_count_, floor(Int, 10.0 / _wt)))
                    msg = string(
                        "Waiting, ", 
                        "time left: ", left_, "(s)"
                    )
                    @info(msg)
                    fb_count_ = 0
                end
            end
            
            
            sleep(_wt)
        
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