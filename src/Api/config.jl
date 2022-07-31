## ---------------------------------------------------------
config(gl::GitLink) = get!(() -> Dict{Symbol, Any}(), gl, :gl_config) 
config(gl::GitLink, key::Symbol) = getindex(config(gl), key)

config!(gl::GitLink, key::Symbol, val) = setindex!(config(gl), val, key)
function config!(gl::GitLink; kwargs...) 
    for (key, val) in kwargs
        config!(gl, key, val)
    end
    return gl
end

## ---------------------------------------------------------
const GL_CONFIG_KEYS = [
    :verbose,
    :wdir_clear,
    :loop_iters,
    :loop_tout,
    :sync_tries,
    :stage_clear,
    :lk_force,
    :force_sync,
    :lk_tout,
    :loop_wt_max,
    :loop_wt_min,
    :loop_wt_penalty
]

## ---------------------------------------------------------
function _set_deft_config!(gl::GitLink)
    config!(gl, :verbose, false)
    config!(gl, :wdir_clear, true)
    config!(gl, :loop_iters, Inf)
    config!(gl, :loop_tout, Inf)
    config!(gl, :sync_tries, 3)
    config!(gl, :stage_clear, false)
    config!(gl, :lk_force, false)
    config!(gl, :force_sync, false)
    config!(gl, :lk_tout, 80.0)
    config!(gl, :loop_wt_max, 60.0)
    config!(gl, :loop_wt_min, 1.0)
    config!(gl, :loop_wt_penalty, 0.5)
end

