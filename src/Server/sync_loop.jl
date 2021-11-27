const _LOOP_FREC = Ref{Float64}(2.0)

function sync_loop(gl::GitLink; niters = typemax(Int), verbose = true)

    for it in 1:niters
        
        ## ---------------------------------------------------
        # ACQUIRE LOCK
        lid, ttag = get_lock(gl::GitLink; tout = 30.0)

    end

end