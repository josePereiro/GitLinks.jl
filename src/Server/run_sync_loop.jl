const _STOP_SIGNAL_KEY = :stop_dignal
_get_stop_signal(gl::GitLink) = get!(gl, _STOP_SIGNAL_KEY, false)
_set_stop_signal!(gl::GitLink, sig::Bool) = set!(gl, _STOP_SIGNAL_KEY, sig)

"""
    run_sync_loop(gl::GitLink; niters = typemax(Int), verbose = true)

Run sucesive `sync_link` operations over the `GilLink`.
It will stop if `niter` or` stop_time` is reached.
It is a lazy method, if no action is require no action will be made (use `force` to avoid it).
A server might call this method asynchronously.
"""
function run_sync_loop(gl::GitLink; 
        niters = typemax(Int), 
        tout = Inf,
        verbose = true
    )

    t0 = time()
    tout = _LOCK_FORCE_TIME

    for it in 1:niters

        ## ---------------------------------------------------
        # WAIT
        sleep(loop_frec(gl))

        ## ---------------------------------------------------
        # TIME OUT
        (time() - t0) > tout && return gl

        ## ---------------------------------------------------
        # STOP SIGNAL (Dev)
        _get_stop_signal(gl) && return gl
        
        ## ---------------------------------------------------
        # NEW ITER
        verbose && println("-"^60)
        verbose && @info("Loop iter", it, loop_frec = loop_frec(gl))

        ## ---------------------------------------------------
        # FORCE
        force = _do_ping(gl)

        ## ---------------------------------------------------
        # SYNC LINK
        sync_link(gl; verbose, force, tout)

    end

    return gl

end