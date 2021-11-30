# TODO: Connect with GitLink config
const _LOCK_FORCE_TIME = 360.0
const _LOOP_FREC_FAIL_PENALTY = 5.0
const _LOOP_FREC_IDLE_PENALTY = 0.5

"""
    sync_link(gl::GitLink; verbose = true, force = false)

Try to pull/merge state/push the `GitLink`.
It is a lazy method, if no action is require no action will be made (use `force` to avoid it).
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
Returns `true` if the action was succeful.
"""
function sync_link(gl::GitLink; 
        verbose = true, force = true, 
        before_push::Function = () -> nothing,
        tout = _LOCK_FORCE_TIME
    )

    # Globals
    lf = lock_file(gl)
    lid = ""
    pull_token = _get_pull_token(gl)
    push_token = _get_push_token(gl)
    stage_token = _get_stage_token(gl)
    
    try
        
        ## ---------------------------------------------------
        # ACQUIRE LOCK
        release_lock(lf, lid) # In case it is mine
        lid, ttag = get_lock(lf; tout)
        if isempty(lid) # if fail force (avoid deadlock)
            _rm(lf)
            add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
            return false
        end

        ## ---------------------------------------------------
        verbose && @info("Lock acquired", lid, ttag)

        ## ---------------------------------------------------
        # RESOLVE ACTION FlAG
        pull_flag = force || is_pull_required(gl)
        push_flag = force || is_push_required(gl)
        doloop = pull_flag || push_flag
        if !doloop # Handle idle
            add_loop_frec!(gl, _LOOP_FREC_IDLE_PENALTY)
            return false
        end
        
        ## ---------------------------------------------------
        verbose && @info("Doing", pull_flag, push_flag)

        ## ---------------------------------------------------
        # HARD PULL (Loop)
        pull_ok = hard_pull(gl; verbose, clearwd = true)
        if !pull_ok # Handle fail
            add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
            return false
        end
        pull_token = _set_pull_token(gl) # Aknowlage succeful pull

        ## ---------------------------------------------------
        verbose && @info("Pull info", pull_token, chash = _HEAD_hash(gl))

        ## ---------------------------------------------------
        if push_flag

            ## ---------------------------------------------------
            # MERGE STAGE
            _merge_stage(gl)

            ## ---------------------------------------------------
            # CALLBACK
            before_push()

            ## ---------------------------------------------------
            # SOFT PUSH
            push_ok = soft_push(gl; verbose)
            if !push_ok # Handle fail
                add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
                return false
            end
            push_token = _set_push_token(gl) # Aknowlage succeful pull

            ## ---------------------------------------------------
            verbose && @info("Push info", push_token, chash = _HEAD_hash(gl))
            
            ## ---------------------------------------------------
            stage_token = _set_stage_token(gl, push_token) # Aknowlage succeful upload

        end

        ## ---------------------------------------------------
        # HANDLE SUCCEFUL LOOP
        loop_frec!(gl, _MIN_LOOP_FREC) # Reset loop frec
        is_stage_sync = _is_stage_up_to_day(gl)

        ## ---------------------------------------------------
        verbose && @info("Success!", stage_token, is_stage_sync)
        verbose && println()

        return true

    finally
        # Free lock
        release_lock(lf, lid) 
    end

end