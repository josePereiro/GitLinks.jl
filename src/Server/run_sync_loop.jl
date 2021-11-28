function run_sync_loop(gl::GitLink; 
        niters = typemax(Int), verbose = true
    )

    for it in 1:niters

        ## ---------------------------------------------------
        # WAIT
        sleep(loop_frec(gl))

        ## ---------------------------------------------------
        # Stop signal (mainly for dev purposes)
        _get_stop_signal(gl) && return gl
        
        ## ---------------------------------------------------
        # NEW ITER
        verbose && println("-"^60)
        verbose && @info("Loop iter", it, loop_frec = loop_frec(gl))

        ## ---------------------------------------------------
        # SYNC LINK
        sync_link(gl; verbose, force = false)

    end

    return gl

end