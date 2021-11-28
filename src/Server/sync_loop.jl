# TODO: Connect with GitLink config
const _LOCK_FORCE_TIME = 360.0
const _LOOP_FREC_FAIL_PENALTY = 5.0
const _LOOP_FREC_IDLE_PENALTY = 0.5

function sync_loop(gl::GitLink; 
        niters = typemax(Int), verbose = true
    )

    # Globals
    lf = lock_file(gl)
    lid = ""
    pull_token = _get_pull_token(gl)
    push_token = _get_push_token(gl)
    stage_token = _get_stage_token(gl)

    for it in 1:niters
        
        ## ---------------------------------------------------
        # NEW ITER
        verbose && println("-"^60)
        verbose && @info("Loop iter", it, loop_frec = loop_frec(gl))

        ## ---------------------------------------------------
        # WAIT
        sleep(loop_frec(gl))
        
        ## ---------------------------------------------------
        # ACQUIRE LOCK
        release_lock(lf, lid) # In case it is mine
        lid, ttag = get_lock(lf; tout = _LOCK_FORCE_TIME)
        if isempty(lid) # if fail force (avoid deadlock)
            _rm(lf)
            add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
            continue
        end

        ## ---------------------------------------------------
        verbose && @info("Lock acquired", lid, ttag)

        ## ---------------------------------------------------
        # RESOLVE ACTION FlAG
        pull_flag = _is_pull_required(gl)
        push_flag = !_is_stage_up_to_day(gl)
        doloop = pull_flag || push_flag
        if !doloop # Handle idle
            add_loop_frec!(gl, _LOOP_FREC_IDLE_PENALTY)
            continue
        end
        
        ## ---------------------------------------------------
        verbose && @info("Doing", pull_flag, stage_flag)

        ## ---------------------------------------------------
        # HARD PULL (Loop)
        pull_ok = hard_pull(gl; verbose, clearwd = true)
        if !pull_ok # Handle fail
            add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
            continue
        end
        pull_token = _set_pull_token(gl) # Aknowlage succeful pull

        ## ---------------------------------------------------
        verbose && @info("Pull info", pull_token, chash = _curr_hash(gl))

        ## ---------------------------------------------------
        if push_flag

            ## ---------------------------------------------------
            # MERGE STAGE
            _merge_stage(gl)

            ## ---------------------------------------------------
            @info("Stage merged")
            println.(readdir(GitLinks.repo_dir(gl)))
            println()    

            ## ---------------------------------------------------
            # SOFT PUSH
            push_ok = soft_push(gl; verbose)
            if !push_ok # Handle fail
                add_loop_frec!(gl, _LOOP_FREC_FAIL_PENALTY)
                continue
            end
            push_token = _set_push_token(gl) # Aknowlage succeful pull

            ## ---------------------------------------------------
            verbose && @info("Push info", push_token, chash = _curr_hash(gl))
            
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
    end

    # Free lock
    release_lock(lf, lid) 

    return nothing

end