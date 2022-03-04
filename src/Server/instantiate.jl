"""
    instantiate(gl::GitLink; verbose = false)

Create the file structure and clone the `GitLink` locally.
Returns `true` if the action was successful.
"""
function instantiate(gl::GitLink; verbose = true)

    # Sync GitLink
    return sync_link(gl; verbose, force = true)
end