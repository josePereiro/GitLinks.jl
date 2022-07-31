# ---------------------------------------------------------
# Up event registry
# Set the events to its current state
# you can use a key to identify the events (or the global one)

up_stage_reg!(gl::GitLink; idkey = :_stage_event) = 
    set!(gl, idkey, _get_stage_token(gl))

up_pull_reg!(gl::GitLink; idkey = :_pull_event) = 
    set!(gl, idkey, _get_pull_token(gl))

up_push_reg!(gl::GitLink; idkey = :_push_event) = 
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

if_stage(fun::Function, gl::GitLink; idkey::Symbol = :_stage_event) = 
    _if_event(fun, gl, idkey, _get_stage_token)

if_pull(fun::Function, gl::GitLink; idkey::Symbol = :_pull_event) = 
    _if_event(fun, gl, idkey, _get_pull_token)

if_push(fun::Function, gl::GitLink; idkey::Symbol = :_push_event) = 
    _if_event(fun, gl, idkey, _get_push_token)

# ---------------------------------------------------------
# Wait for event

function _waitfor_event(gl::GitLink, idkey::Symbol, if_event::Function;
        loop_tout = 60.0, wt = 1.0
    )

    t0 = time()
    event_flag = false

    while true
        sleep(wt)
        if_event(gl; idkey) do
            event_flag = true
        end
        event_flag && break
        (time() - t0) > loop_tout && return event_flag
    end

    return event_flag

end

"""
    waitfor_pull(gl::GitLink; idkey = $(:_pull_event), loop_tout = 60.0, wt = 1.0)
"""
waitfor_pull(gl::GitLink; idkey::Symbol = :_pull_event, kwargs...) = 
    _waitfor_event(gl, idkey, if_pull; kwargs...)

"""
    waitfor_push(gl::GitLink; idkey = $(:_push_event), loop_tout = 60.0, wt = 1.0)
"""
waitfor_push(gl::GitLink; idkey::Symbol = :_push_event, kwargs...) = 
    _waitfor_event(gl, idkey, if_push; kwargs...)

"""
    waitfor_stage(gl::GitLink; idkey = $(:_stage_event), loop_tout = 60.0, wt = 1.0)
"""
waitfor_stage(gl::GitLink; idkey::Symbol = :_stage_event, kwargs...) = 
    _waitfor_event(gl, idkey, if_stage; kwargs...)
