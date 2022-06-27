"""
    instantiate(gl::GitLink; verbose = false)

Create the file structure and clone the `GitLink` locally.
Returns `true` if the action was successful.
"""
function instantiate(gl::GitLink; 
        verbose = true, 
        tries = 1,
        clearwd = false, 
        clearstage = false,
    )

    # Sync GitLink
    return _sync_link(gl; 
        verbose, 
        force = true, 
        merge_stage = false,
        tries, 
        clearwd, 
        clearstage,
    )
end