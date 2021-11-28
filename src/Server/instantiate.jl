"""
    instantiate(gl::GitLink; verbose = false)

Create the file structure and clone the `GitLink` locally.
Returns `true` if the action was succeful.
"""
function instantiate(gl::GitLink; verbose = true)

    ok_flag = false
    lock(gl) do
        # clone
        ok_flag = hard_pull(gl; verbose, clearwd = true)
    end
    
    return ok_flag
end