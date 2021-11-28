let
    verbose = false
    upstream_repo = ""
    server_root = ""
    client_root = ""
    server_gl = nothing
    client_gl = nothing

    try

        ## ------------------------------------------------------------
        println("\n", "-"^60)
        println("Testing client server roles")
        println("-"^60, "\n")

        ## ------------------------------------------------------------
        # Remote
        url, upstream_repo = GitLinks._create_local_upstream(;verbose)

        ## ------------------------------------------------------------
        # Server
        server_root = tempname()
        GitLinks._rm(server_root)
        server_gl = GitLinks.GitLink(server_root, url)
        @test GitLinks.instantiate(server_gl; verbose)

        ## ------------------------------------------------------------
        # Client
        client_root = tempname()
        GitLinks._rm(client_root)
        client_gl = GitLinks.GitLink(client_root, url)
        @test GitLinks.instantiate(client_gl; verbose)
        
        ## ------------------------------------------------------------
        # Tests

        # Stage something
        dummy_name = "test-dymmy.txt"
        staged_dummy = joinpath(GitLinks.stage_dir(client_gl), dummy_name)
        target_dummy = joinpath(GitLinks.repo_dir(server_gl), dummy_name)
        @test !isfile(staged_dummy)
        @test !isfile(target_dummy)
        stage_test = false
        GitLinks.stage(client_gl) do sdir
            println("\n", "-"^60)
            @info("stage")
            @test sdir == GitLinks.stage_dir(client_gl)
            @show sdir
            staged_dummy = joinpath(sdir, dummy_name)
            write(staged_dummy, rand())
            stage_test = true
        end
        @test isfile(staged_dummy)
        @test !isfile(target_dummy)
        @test !GitLinks._is_stage_up_to_day(client_gl)
        @test GitLinks.is_push_required(client_gl)

        @async begin
            sleep(5.0) # To retard first iter
            @info("Starting client loop")
            GitLinks.run_sync_loop(client_gl; niters = 500, verbose, tout = 60.0)
        end
        
        @info("waitfor_push")
        @test GitLinks.waitfor_push(client_gl; wt = 0.5, tout = 15.0)
        @test isfile(staged_dummy)
        @test GitLinks._is_stage_up_to_day(client_gl)

        @async begin
            sleep(5.0) # To retard first iter
            @info("Starting server loop")
            @async GitLinks.run_sync_loop(server_gl; niters = 500, verbose, tout = 60.0)
        end

        # check target arrived
        @info("waitfor_pull")
        @test GitLinks.waitfor_pull(server_gl; wt = 0.5, tout = 15.0)
        @test isfile(target_dummy)

        # Client
        # test readwdir
        readwdir_test = false
        GitLinks.readwdir(server_gl; tout = 8.0) do wdir
            println("\n", "-"^60)
            @info("Reading wdir")
            @test wdir == GitLinks.repo_dir(server_gl)
            target_dummy = joinpath(wdir, dummy_name)
            @test isfile(target_dummy)
            readwdir_test = true
        end
        @test readwdir_test

        # clear
        GitLinks._set_stop_signal!(client_gl, true)
        GitLinks._rm(client_root)

        @info("Testing upload")
        # Set other client
        client_root = tempname()
        GitLinks._rm(client_root)
        client_gl = GitLinks.GitLink(client_root, url)
        @test GitLinks.instantiate(client_gl; verbose)
        dummy_name = "dummy2.txt"
        staged_dummy = joinpath(GitLinks.stage_dir(client_gl), dummy_name)
        target_dummy = joinpath(GitLinks.repo_dir(server_gl), dummy_name)
        @test !isfile(staged_dummy)
        @test !isfile(target_dummy)
        upload_test = false
        @test GitLinks.upload(client_gl; verbose, tout = 10.0) do sdir
            println("\n", "-"^60)
            @info("upload")
            @test sdir == GitLinks.stage_dir(client_gl)
            staged_dummy = joinpath(sdir, dummy_name)
            write(staged_dummy, rand())
            upload_test = true
        end
        @test isfile(staged_dummy)
        @test GitLinks._is_stage_up_to_day(client_gl)
        @test !GitLinks.is_pull_required(client_gl)
        @test !GitLinks.is_push_required(client_gl)

        # check target
        for _ in 1:10
            sleep(1.0)
            gool = isfile(target_dummy)
            gool && break
        end
        @test isfile(target_dummy)

        @info("Testing ping")
        @test GitLinks.ping(client_gl; verbose = false, tout = 20.0)

        @info("Done")
        
    finally
        # kill loops
        @info("_set_stop_signal!")
        !isnothing(client_gl) && GitLinks._set_stop_signal!(client_gl, true)
        !isnothing(server_gl) && GitLinks._set_stop_signal!(server_gl, true)

        # clear
        GitLinks._rm(server_root)
        GitLinks._rm(client_root)
        GitLinks._rm(upstream_repo)

    end
end