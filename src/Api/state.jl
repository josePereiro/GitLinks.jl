## ---------------------------------------------------------
state(gl::GitLink) = get!(() -> Dict{Symbol, Any}(), gl, :gl_state) 
state(gl::GitLink, key::Symbol) = getindex(state(gl), key)

_state!(gl::GitLink, key::Symbol, val) = setindex!(state(gl), val, key)

## ---------------------------------------------------------
const GL_STATE_KEYS = [
    :loop_iter, 
    :loop_wt, 
    :last_push,
    :last_pull,
    :push_signal
]
    
## ---------------------------------------------------------
function _init_state!(gl::GitLink)
    _state!(gl, :loop_iter, 0)
    _state!(gl, :loop_wt, 1.0)
    _state!(gl, :push_signal, ("", -1))
    _state!(gl, :last_push, DateTime(1,1,1))
    _state!(gl, :last_pull, DateTime(1,1,1))
end
