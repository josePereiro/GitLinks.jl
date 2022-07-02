## ---------------------------------------------------------
state(gl::GitLink) = get!(() -> Dict{Symbol, Any}(), gl, :gl_state) 
state(gl::GitLink, key::Symbol) = getindex(state(gl), key)

_state!(gl::GitLink, key::Symbol, val) = setindex!(state(gl), val, key)

## ---------------------------------------------------------
const GL_STATE_KEYS = [
    :loop_iter, 
]
    
## ---------------------------------------------------------
function _init_state!(gl::GitLink)
    _state!(gl, :loop_iter, 0)
end
