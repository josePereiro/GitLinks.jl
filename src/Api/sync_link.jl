_do_nothing(x...) = nothing

"""
    sync_link(gl::GitLink; verbose = true, force = false, tries = 1)

Try to pull/merge state/push the `GitLink`.
It is a lazy method, if no action is require no action will be made (use `force` to avoid it).
This method will sleep till (or timeout `loop_tout`) the GitLink lock is free (which must by must of the time, but...).
The method will attempt `tries` tries till success.
Returns `true` if the action was successful.
"""
function sync_link(gl::GitLink;
        # loop control
        tries = config(gl, :sync_tries), 
        verbose = config(gl, :verbose), 
        force = config(gl, :force_sync), 
        # action flags
        wdir_clear = config(gl, :wdir_clear), 
        stage_clear = config(gl, :stage_clear),
        stage_merge = get_stage_merge(gl),
        # lock
        lk_force = config(gl, :lk_force),
        lk_tout = config(gl, :lk_tout),
        # callbacks
        on_iter::Function = _do_nothing,
        on_lock::Function = _do_nothing,
        before_push::Function = _do_nothing,
        on_pull_fail::Function = _do_nothing,
        on_pull_success::Function = _do_nothing,
        on_push_fail::Function = _do_nothing,
        on_push_success::Function = _do_nothing,
        on_connection_fail::Function = _do_nothing,
        on_no_action::Function = _do_nothing,
        on_unlock::Function = _do_nothing,
        on_success::Function = _do_nothing,
    )

    it = 0
    
    while true

        # loop control
        it += 1
        (it > tries) && return false

        # Globals
        lf = lock_file(gl)
        lid = ""
        
        try
            
            ## ---------------------------------------------------
            on_iter(gl);

            ## ---------------------------------------------------
            # TEST CONNECTION
            if has_connection(gl)
                if verbose
                    msg = string(
                        "Connected, url: \"", remote_url(gl), "\", ", 
                        "remote hash: ", first(_remote_HEAD_hash(gl), 7)
                    ) 
                    @info(msg)
                end
            else
                if verbose 
                    msg = string("Connection Failed! url = \"", remote_url(gl), "\"")
                    @warn(msg)
                end
                on_connection_fail(gl);
                continue
            end

            ## ---------------------------------------------------
            # ACQUIRE LOCK
            unlock(lf, lid) # In case it is mine, I create a new one
            lid, ttag = acquire_lock(lf; tout = lk_tout, force = lk_force)
            verbose && @info("Lock acquired")
            
            ## ---------------------------------------------------
            on_lock(gl);

            ## ---------------------------------------------------
            # RESOLVE ACTION FlAG
            force_sync_signal = signal(gl, :force_sync)
            pull_flag = force || is_pull_required(gl) || force_sync_signal
            push_flag = force || is_push_required(gl) || force_sync_signal
            doloop = pull_flag || push_flag 
            if !doloop # Handle idle
                verbose && @info("No action required!")
                on_no_action(gl);
                return true
            end
            
            ## ---------------------------------------------------
            verbose && @info("Doing", pull_flag, push_flag)

            ## ---------------------------------------------------
            # HARD PULL (Loop)
            pull_ok = _hard_pull(gl; verbose, wdir_clear, tries)
            if pull_ok
                verbose && @info("Pull succeeded")
                on_pull_success(gl);
            else
                verbose && @warn("Pull failed")
                on_pull_fail(gl);
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
                stage_merge && _merge_stage(gl)

                ## ---------------------------------------------------
                before_push(gl)

                ## ---------------------------------------------------
                # SOFT PUSH
                push_ok = _soft_push(gl; verbose, tries)
                if push_ok
                    verbose && @info("Push succeeded")
                    on_push_success(gl);
                else
                    verbose && @warn("Push failed")
                    on_push_fail(gl);
                    continue
                end

                ## ---------------------------------------------------
                verbose && @info("Push info", 
                    push_token = _get_push_token(gl), 
                    chash = _HEAD_hash(gl)
                )
                
                ## ---------------------------------------------------
                # Aknowlage successful upload
                stage_merge && _set_stage_pushed_token(gl) 

            end
            
            ## ---------------------------------------------------
            stage_clear && clear_stage(gl)
            verbose && stage_clear && @info("Stage cleared")
            verbose && println()
            
            ## ---------------------------------------------------
            verbose && @info("Success!")
            verbose && println()

            break

        finally
            # Free lock
            unlock(lf, lid)
            on_unlock(gl)
        end
    
    end #tries

    ## ---------------------------------------------------
    on_success(gl);
            
    return true

end