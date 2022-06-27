# ---------------------------------------------------------
# Up event registry
# Set the events to its current state
# you can use a key to identify the events (or the global one)

const _GL_STAGE_EVENT_DFLT_KEY = :_stage_event
up_stage_reg!(gl::GitLink; idkey = _GL_STAGE_EVENT_DFLT_KEY) = 
    set!(gl, idkey, _get_stage_token(gl))

const _GL_PULL_EVENT_DFLT_KEY = :_pull_event
up_pull_reg!(gl::GitLink; idkey = _GL_PULL_EVENT_DFLT_KEY) = 
    set!(gl, idkey, _get_pull_token(gl))

const _GL_PUSH_EVENT_DFLT_KEY = :_push_event
up_push_reg!(gl::GitLink; idkey = _GL_PUSH_EVENT_DFLT_KEY) = 
    set!(gl, idkey, _get_push_token(gl))

# ---------------------------------------------------------
# Do if event
# execute a function if the state of the event is different
# from the current one

function _if_event(fun::Function, gl::GitLink, idkey::Symbol, curr_state_fun::Function)
    reg_state = get!(gl, idkey, nothing)
    isnothing(reg_state) && return false
    curr_state = curr_state_fun(gl)
    if reg_state != curr_state
        fun()
        return true
    end
    return false
end

if_stage(fun::Function, gl::GitLink; idkey::Symbol = _GL_STAGE_EVENT_DFLT_KEY) = 
    _if_event(fun, gl, idkey, _get_stage_token)

if_pull(fun::Function, gl::GitLink; idkey::Symbol = _GL_PULL_EVENT_DFLT_KEY) = 
    _if_event(fun, gl, idkey, _get_pull_token)

if_push(fun::Function, gl::GitLink; idkey::Symbol = _GL_PUSH_EVENT_DFLT_KEY) = 
    _if_event(fun, gl, idkey, _get_push_token)

# ---------------------------------------------------------
# Wait for event

function _waitfor_event(gl::GitLink, idkey::Symbol, if_event::Function;
        tout = 60.0, wt = 1.0
    )

    t0 = time()
    event_flag = false

    while true
        sleep(wt)
        if_event(gl; idkey) do
            event_flag = true
        end
        event_flag && break
        (time() - t0) > tout && return event_flag
    end

    return event_flag

end

"""
    waitfor_pull(gl::GitLink; idkey = $(_GL_PULL_EVENT_DFLT_KEY), tout = 60.0, wt = 1.0)
"""
waitfor_pull(gl::GitLink; idkey::Symbol = _GL_PULL_EVENT_DFLT_KEY, kwargs...) = 
    _waitfor_event(gl, idkey, if_pull; kwargs...)

"""
    waitfor_push(gl::GitLink; idkey = $(_GL_PUSH_EVENT_DFLT_KEY), tout = 60.0, wt = 1.0)
"""
waitfor_push(gl::GitLink; idkey::Symbol = _GL_PUSH_EVENT_DFLT_KEY, kwargs...) = 
    _waitfor_event(gl, idkey, if_push; kwargs...)

"""
    waitfor_stage(gl::GitLink; idkey = $(_GL_STAGE_EVENT_DFLT_KEY), tout = 60.0, wt = 1.0)
"""
waitfor_stage(gl::GitLink; idkey::Symbol = _GL_STAGE_EVENT_DFLT_KEY, kwargs...) = 
    _waitfor_event(gl, idkey, if_stage; kwargs...)
