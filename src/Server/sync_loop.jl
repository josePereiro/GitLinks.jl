# TODO: Connect with GitLink config
const _LOCK_FORCE_TIME = 360.0
const _LOOP_FREC_FAIL_PENALTY = 2.0
const _LOOP_FREC_IDLE_PENALTY = 0.5

function sync_loop(gl::GitLink; 
        niters = typemax(Int), verbose = true
    )

    # Globals
    lf = lock_file(gl)
    lid = ""
    pull_flag = _is_pull_required(gl)
    push_flag = _is_push_required(gl)
    # _is_push_required()

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
            add_loop_frec!(gl::GitLink, _LOOP_FREC_FAIL_PENALTY)
            continue
        end

        ## ---------------------------------------------------
        verbose && @info("Lock acquired", lid, ttag)

        ## ---------------------------------------------------
        # RESOLVE DOLOOP FlAG
        pull_flag = _is_pull_required(gl)
        push_flag = _is_push_required(gl)
        doloop = pull_flag || push_flag
        if !doloop # Handle idle
            add_loop_frec!(gl::GitLink, _LOOP_FREC_IDLE_PENALTY)
            continue
        end
        
        ## ---------------------------------------------------
        verbose && @info("Doing", pull_flag, push_flag)

        ## ---------------------------------------------------
        # HARD PULL (Loop)
        pull_ok = hard_pull(gl; verbose, clearwd = true)
        if !pull_ok # Handle fail
            add_loop_frec!(gl::GitLink, _LOOP_FREC_FAIL_PENALTY)
            continue
        end

        ## ---------------------------------------------------
        verbose && @info("Pull info", chash = _curr_hash(gl))

        ## ---------------------------------------------------
        # MERGE STAGE
        _merge_stage(gl)

        ## ---------------------------------------------------
        println.(readdir(GitLinks.repo_dir(gl)))
        println()    

        ## ---------------------------------------------------
        # SOFT PUSH
        push_ok = soft_push(gl; verbose)
        if !push_ok # Handle fail
            add_loop_frec!(gl::GitLink, _LOOP_FREC_FAIL_PENALTY)
            continue
        end

        ## ---------------------------------------------------
        verbose && @info("Push info", chash = _curr_hash(gl))

        ## ---------------------------------------------------
        # HANDLE sSUCCEFUL LOOP
        loop_frec!(gl, _MIN_LOOP_FREC) # Reset loop frec
        new_stage_token = _sync_stage_token!(gl) # Aknowlage succeful upload
        is_stage_sync = _is_stage_token_sync(gl)

        ## ---------------------------------------------------
        verbose && @info("Success!", new_stage_token, is_stage_sync)
        

        verbose && println()
    end

    release_lock(lf, lid) # In case it is mine

    return nothing

end