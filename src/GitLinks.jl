module GitLinks

    import SimpleLockFiles
    import SimpleLockFiles: acquire_lock

    include("Types/GitLink.jl")

    include("Utils/rand_str.jl")
    include("Utils/toml_utils.jl")
    include("Utils/runcmd.jl")
    include("Utils/fileutils.jl")

    include("GitUtils/check_gitdir.jl")
    include("GitUtils/repo_format.jl")
    include("GitUtils/remote_HEAD_hash.jl")
    include("GitUtils/config.jl")
    include("GitUtils/commits_behind_remote.jl")
    include("GitUtils/HEAD_hash.jl")
    include("GitUtils/curr_branch.jl")
    include("GitUtils/curr_remotes.jl")
    include("GitUtils/fetch.jl")
    include("GitUtils/hard_pull.jl")
    include("GitUtils/is_up_to_day.jl")
    include("GitUtils/list_commits.jl")
    include("GitUtils/nuke_remote.jl")
    include("GitUtils/remote_url.jl")
    include("GitUtils/ready_to_push.jl")
    include("GitUtils/soft_push.jl")
    include("GitUtils/url_from_file.jl")

    include("DevLand/create_local_upstream.jl")
    include("DevLand/monkey_delete.jl")

    include("Server/global_signals.jl")
    include("Server/stage_sync.jl")
    include("Server/tokens.jl")
    
    include("Api/config.jl")
    include("Api/dir_and_files.jl")
    include("Api/download.jl")
    include("Api/events.jl")
    include("Api/git_status.jl")
    include("Api/instantiate.jl")
    include("Api/is_pull_required.jl")
    include("Api/is_push_required.jl")
    include("Api/is_uptoday.jl")
    include("Api/lock_file.jl")
    include("Api/ping.jl")
    include("Api/readwdir.jl")
    include("Api/run_sync_loop.jl")
    include("Api/signal.jl")
    include("Api/stage.jl")
    include("Api/state.jl")
    include("Api/sync_link.jl")
    include("Api/upload_stage.jl")
    include("Api/upload_wdir.jl")

    export GitLink, set!
    export instantiate, stage, readwdir, download, upload_stage, upload_wdir, sync_link
    export root_dir, repo_dir, stage_dir
    export clear_wd, clear_stage

    # config
    export config, config!
    
    export run_sync_loop
    export create_local_upstream
    export waitfor_pull, waitfor_stage, waitfor_push
    export if_pull, if_stage, if_push
    export is_push_required, is_pull_required
    export ping, git_status, is_uptoday, has_connection

end
