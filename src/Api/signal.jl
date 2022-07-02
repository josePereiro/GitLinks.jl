## ---------------------------------------------------------
signal(gl::GitLink) = get!(() -> Dict{Symbol, Any}(), gl, :gl_signal) 
signal(gl::GitLink, key::Symbol) = getindex(signal(gl), key)

signal!(gl::GitLink, key::Symbol, val) = setindex!(signal(gl), val, key)

## ---------------------------------------------------------
const GL_SIGNAL_KEYS = [
    :loop_stop,
    :force_sync
]

## ---------------------------------------------------------
function _init_signal!(gl::GitLink)
    signal!(gl, :loop_stop, false)
    signal!(gl, :force_sync, false)
end