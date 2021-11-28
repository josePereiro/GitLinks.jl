function _waitfor_token_change(fn::String;
        tout = 60.0, wt = 1.0
    )

    t0 = time()
    token0 = _read_token(fn)

    while true
        sleep(wt)
        token = _read_token(fn)
        token0 != token && return true
        (time() - t0) > tout && return false
    end

    return false

end

"""
    waitfor_pull(gl::GitLink; tout = 60.0, wt = 1.0)
"""
waitfor_pull(gl::GitLink; kwargs...) = 
    _waitfor_token_change(_pull_token_file(gl); kwargs...)

"""
    waitfor_stage(gl::GitLink; tout = 60.0, wt = 1.0)
"""
waitfor_stage(gl::GitLink; kwargs...) = 
    _waitfor_token_change(_stage_token_file(gl); kwargs...)

"""
    waitfor_push(gl::GitLink; tout = 60.0, wt = 1.0)
"""
waitfor_push(gl::GitLink; kwargs...) = 
    _waitfor_token_change(_push_token_file(gl); kwargs...)