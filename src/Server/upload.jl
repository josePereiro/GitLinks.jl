function upload(upfun::Function, gl::GitLink; verbose, tout = 60.0)
    stage(upfun, gl; tout) || return false
    return sync(gl; verbose, force = true)
end