# TODO: Connect with GitLink config
const _LOCK_FORCE_TIME = 360.0
const _LOOP_FREC_FAIL_PENALTY = 5.0
const _LOOP_FREC_IDLE_PENALTY = 0.5

"""
    _sync_link(gl::GitLink; verbose = true, force = false, tries = 1)

Try to pull/merge state/push the `GitLink`.
It is a lazy method, if no action is require no action will be made (use `force` to avoid it).
This method will sleep till (or timeout `tout`) the GitLink lock is free (which must by must of the time, but...).
The method will attempt `tries` tries till success.
Returns `true` if the action was successful.
"""
function _sync_link(gl::GitLink; 
        verbose = true, 
        force = true, 
        before_push::Function = () -> nothing,
        tout = _LOCK_FORCE_TIME, 
        tries = 1, 
        merge_stage = true,
        clearwd = true, 
        clearstage = false,
    )

    for t in 1:max(tries, 0)

        # Globals
        lf = lock_file(gl)
        lid = ""
        
        try
            
            ## ---------------------------------------------------
            # ACQUIRE LOCK
            unlock(lf, lid) # In case it is mine, I create a new one
            lid, ttag = acquire_lock(lf; tout, force = true)

            ## ---------------------------------------------------
            verbose && @info("Lock acquired", lid, ttag)

            ## ---------------------------------------------------
            # RESOLVE ACTION FlAG
            pull_flag = force || is_pull_required(gl)
            push_flag = force || is_push_required(gl)
            doloop = pull_flag || push_flag
            if !doloop # Handle idle
                add_loop_frec!(gl, _LOOP_FREC_IDLE_PENALTY)
                continue
            end
            
            ## ---------------------------------------------------
            verbose && @info("Doing", pull_flag, push_flag)

            ## ---------------------------------------------------
            # HARD PULL (Loop)
            pull_ok = _hard_pull(gl; verbose, clearwd, tries = 1)
            if !pull_ok # Handle fail
                add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
                continue
            end

            ## ---------------------------------------------------
            verbose && @info("Pull info", 
                pull_token = _get_pull_token(gl), 
                chash = _HEAD_hash(gl)
            )

            ## ---------------------------------------------------
            if push_flag

                ## ---------------------------------------------------
                # MERGE STAGE
                merge_stage && _merge_stage(gl)

                ## ---------------------------------------------------
                # CALLBACK
                before_push()

                ## ---------------------------------------------------
                # SOFT PUSH
                push_ok = _soft_push(gl; verbose, tries = 1)
                if !push_ok # Handle fail
                    add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
                    continue
                end

                ## ---------------------------------------------------
                verbose && @info("Push info", 
                    push_token = _get_push_token(gl), 
                    chash = _HEAD_hash(gl)
                )
                
                ## ---------------------------------------------------
                # Aknowlage successful upload
                merge_stage && _set_stage_pushed_token(gl) 

            end

            ## ---------------------------------------------------
            # HANDLE SUCCEFUL LOOP
            loop_frec!(gl, _MIN_LOOP_FREC) # Reset loop frec
            
            ## ---------------------------------------------------
            clearstage && clear_stage(gl)
            verbose && clearstage && @info("stage cleared")
            verbose && println()
            
            ## ---------------------------------------------------
            verbose && @info("Success!")
            verbose && println()
            
            return true

        finally
            # Free lock
            unlock(lf, lid) 
        end
    
    end #tries

    return false

end