let
    verbose = false
    upstream_repo = ""
    local_root = ""

    try
        url, upstream_repo = GitLinks._create_local_upstream(;verbose)

        # Server
        # Setup
        local_root = tempname()
        GitLinks._rm(local_root)
        mkpath(local_root)

        gl = GitLinks.GitLink(local_root, url)

        # Start
        GitLinks.instantiate(gl; verbose)

        # Stage something
        dummy_name = "test-dymmy.txt"
        staged_dummy = ""
        repo_dummy0 = joinpath(GitLinks.repo_dir(gl), dummy_name)
        @test !isfile(repo_dummy0)
        GitLinks.stage(gl) do sdir
            println("\n", "-"^60)
            @info("Staging")
            @show sdir
            staged_dummy = joinpath(sdir, dummy_name)
            write(staged_dummy, rand())
        end
        @test !isempty(staged_dummy)

        @show GitLinks._is_stage_up_to_day(gl)

        # Loop
        GitLinks.sync_loop(gl; niters = 2, verbose)

        # Re pull
        GitLinks._rm(local_root)
        GitLinks.sync_loop(gl; niters = 1, verbose)

        # Client
        # check dummy (readwdir)
        GitLinks.readwdir(gl) do wdir
            repo_dummy1 = joinpath(wdir, dummy_name)
            @test isfile(repo_dummy1)
        end

    finally
        # clear
        GitLinks._rm(local_root)
        GitLinks._rm(upstream_repo)
    end
end