"""
    instantiate(gl::GitLink; verbose = false)

Create the file structure and clone the `GitLink` locally.
Returns `true` if the action was succeful.
"""
function instantiate(gl::GitLink; verbose = true)

    # One full iter
    run_sync_loop(gl::GitLink; 
        niters = 1, verbose, force = true
    )
    
    # check success
    rhash = _check_remote(remote_url(gl))
    chash = _curr_hash(repo_dir(gl))
    return rhash == chash
end