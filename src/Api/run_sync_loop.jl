function _loop_sleep(gl)
    wt = state(gl, :loop_wt)
    wt = clamp(wt, config(gl, :loop_wt_min), config(gl, :loop_wt_max))
    wt = max(0, wt)
    _state!(gl, :loop_wt, wt)
    sleep(wt)
end

_run_sync_loop_penalty_wrapper(f::Function) = (gl::GitLink) -> begin

    # add_loopwt_penalty
    wt = state(gl, :loop_wt)
    p = config(gl, :loop_wt_penalty)
    _state!(gl, :loop_wt, wt + p)

    f(gl)
end

_run_sync_loop_success_wrapper(f::Function) = (gl::GitLink) -> begin
    
    # reset_loopwt
    min_wt = config(gl, :loop_wt_min)
    _state!(gl, :loop_wt, min_wt)

    f(gl)
end

"""
    run_sync_loop(gl::GitLink; loop_iters = typemax(Int), verbose = true)

Run sucesive `sync_link` operations over the `GilLink`.
It will stop if `niter` or `stop_time` is reached.
It is a lazy method, if no action is require no action will be made (use `force` to avoid it).
A server might call this method asynchronously.
"""
function run_sync_loop(gl::GitLink; 
        # loop control
        loop_iters = config(gl, :loop_iters), 
        loop_tout = config(gl, :loop_tout),
        verbose = config(gl, :verbose), 
        # sync
        tries = config(gl, :sync_tries),
        wdir_clear = config(gl, :wdir_clear), 
        stage_clear = config(gl, :stage_clear),
        # lock
        lk_force = config(gl, :lk_force),
        lk_tout = config(gl, :lk_tout), 
        # callbacks
        on_iter::Function = _do_nothing,
        on_lock::Function = _do_nothing,
        before_push::Function = _do_nothing,
        on_pull_fail::Function = _do_nothing,
        on_pull_success::Function = _do_nothing,
        on_push_fail::Function = _do_nothing,
        on_push_success::Function = _do_nothing,
        on_connection_fail::Function = _do_nothing,
        on_no_action::Function = _do_nothing,
        on_unlock::Function = _do_nothing,
        on_success::Function = _do_nothing,
    )

    # init
    t0 = time()
    it = 0

    
    while true
        
        ## ---------------------------------------------------
        # WAIT
        _loop_sleep(gl)

        ## ---------------------------------------------------
        # ITER CONTROL
        it += 1;
        _state!(gl, :loop_iter, it)
        (it > loop_iters) && return gl
        (time() - t0) > loop_tout && return gl

        ## ---------------------------------------------------
        # STOP SIGNAL (Dev)
        signal(gl, :loop_stop) && return gl
        
        ## ---------------------------------------------------
        # INFO
        if verbose
            msg = string(
                "Loop iter: ", it, ", ", 
                "pid: ", getpid(), ", ", 
                "wait time: ", state(gl, :loop_wt)
            )
            @info(msg)
        end

        ## ---------------------------------------------------
        # HANDLE EXTERNAL SIGNALS
        ext_force_push = _is_push_ext_signal_on(gl)

        ## ---------------------------------------------------
        # FORCE FLAG
        force = ext_force_push
        
        ## ---------------------------------------------------
        # SYNC LINK
        sync_link(gl; 
            verbose, force, wdir_clear, stage_clear,
            tries, stage_merge = true,
            # lock
            lk_force, lk_tout,
            # calbacks
            on_iter, on_lock, before_push, on_pull_success, on_push_success, on_unlock,
            on_success = _run_sync_loop_success_wrapper(on_success),
            on_pull_fail = _run_sync_loop_penalty_wrapper(on_pull_fail), 
            on_push_fail = _run_sync_loop_penalty_wrapper(on_push_fail),  
            on_connection_fail = _run_sync_loop_penalty_wrapper(on_connection_fail),
            on_no_action = _run_sync_loop_penalty_wrapper(on_no_action),
        )
        
    end

    return gl

end
