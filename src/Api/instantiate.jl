"""
    instantiate(gl::GitLink; verbose = false)

Create the file structure and clone the `GitLink` locally.
Returns `true` if the action was successful.
"""
function instantiate(gl::GitLink; 
        verbose = config(gl, :verbose), 
        lk_tout = config(gl, :lk_tout),
        tries = config(gl, :sync_tries), 
        wdir_clear = config(gl, :wdir_clear), 
        stage_clear = config(gl, :stage_clear),
    )

    # Sync GitLink
    return sync_link(gl; 
        verbose, lk_tout,
        force = true, 
        stage_merge = false,
        tries, 
        wdir_clear, 
        stage_clear,
    )
end