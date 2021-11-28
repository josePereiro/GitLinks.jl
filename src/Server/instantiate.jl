# TODO: document this
function instantiate(gl::GitLink; verbose = true)

    lock(gl) do
        # clone
        hard_pull(gl; verbose, clearwd = true)
    end
    return gl
end