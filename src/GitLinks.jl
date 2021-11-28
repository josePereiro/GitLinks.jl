module GitLinks

    include("Types/GitLink.jl")

    include("Utils/rand_str.jl")
    include("Utils/toml_utils.jl")
    include("Utils/runcmd.jl")

    include("GitUtils/check_gitdir.jl")
    include("GitUtils/check_remote.jl")
    include("GitUtils/config.jl")
    include("GitUtils/commits_behind_remote.jl")
    include("GitUtils/curr_branch.jl")
    include("GitUtils/HEAD_hash.jl")
    include("GitUtils/fetch.jl")
    include("GitUtils/hard_pull.jl")
    include("GitUtils/is_up_to_day.jl")
    include("GitUtils/list_commits.jl")
    include("GitUtils/nuke_remote.jl")
    include("GitUtils/ready_to_push.jl")
    include("GitUtils/soft_push.jl")
    include("GitUtils/url_from_file.jl")

    include("TreeStruct/dir_and_files.jl")
    include("TreeStruct/utils.jl")

    include("Lock_system/lock_file.jl")

    include("DevLand/create_local_upstream.jl")

    include("Server/events.jl")
    include("Server/instantiate.jl")
    include("Server/loop_frec.jl")
    include("Server/is_pull_required.jl")
    include("Server/is_push_required.jl")
    include("Server/readwdir.jl")
    include("Server/stage.jl")
    include("Server/signals.jl")
    include("Server/run_sync_loop.jl")
    include("Server/sync_link.jl")
    include("Server/tokens.jl")
    
    include("Client/upload.jl")
    include("Client/ping.jl")
    include("Client/git_status.jl")

    export GitLink, instantiate, stage, readwdir
    export repo_dir, state_dir
    export waitfor_pull, waitfor_stage, waitfor_push
    export is_push_required, is_pull_required
    export sync_link, upload, ping, git_status

end
