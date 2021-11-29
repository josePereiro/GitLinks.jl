let
    verbose = false
    upstream_repo = ""
    local_root = ""

    try

        println("\n", "-"^60)
        println("Testing git utils")
        println("-"^60, "\n")

        # upstream
        branch_name = "test_branch"
        url, upstream_repo = GitLinks.create_local_upstream(tempname(); verbose, branch_name)
        @assert isdir(upstream_repo)

        @test !isempty(GitLinks._remote_HEAD_hash(url))
        @test !isempty(GitLinks._HEAD_hash(upstream_repo))
        @test GitLinks._remote_HEAD_hash(url) == GitLinks._HEAD_hash(upstream_repo)

        @test GitLinks._check_gitdir(upstream_repo)
        @test !GitLinks._check_gitdir(tempname())
        @test GitLinks._curr_branch(upstream_repo) == branch_name

        # local repo
        local_root = tempname()
        GitLinks._rm(local_root)
        
        gl = GitLinks.GitLink(local_root, url)
        local_repo = GitLinks.repo_dir(gl)
        local_repo_git = joinpath(local_repo, ".git")
        
        # hard pull
        @test !isdir(local_root)
        pull_ok = GitLinks.hard_pull(gl; verbose, clearwd = true) # clone
        @test pull_ok
        @test isdir(local_root)
        @test isdir(local_repo_git)
        
        pull_ok = GitLinks.hard_pull(gl; verbose, clearwd = true) # pull
        @test pull_ok
        @test isdir(local_root)
        @test isdir(local_repo_git)
        
        GitLinks._rm(joinpath(local_repo, ".git")) # break repo
        @test !GitLinks._check_gitdir(local_root)
        pull_ok = GitLinks.hard_pull(gl; verbose, clearwd = true) # must recover
        @test pull_ok
        @test isdir(local_root)
        @test isdir(local_repo_git)

        # soft push
        upsize0 = GitLinks._foldersize(upstream_repo)
        for it in 1:10
            # create 'big' files
            dummy = joinpath(local_repo, "dummy$it")
            write(dummy, GitLinks.rand_str(1000))
            push_ok = GitLinks.soft_push(gl; verbose)
            @test push_ok
        end
        upsize1 = GitLinks._foldersize(upstream_repo)
        @test upsize0 < upsize1

        println("\n", "-"^60)
        println("Before nuking", "\n")
        run(`git -C $(upstream_repo) --no-pager log -l10 --pretty=oneline`)

        # TODO: test that nuking actually reduce size
        # nuke
        # upsize2 = GitLinks._foldersize(upstream_repo)
        # upsize3 = GitLinks._foldersize(local_root)

        nuke_ok = GitLinks.nuke_remote(gl; verbose)
        @test nuke_ok
        
        GitLinks._rm(local_root)
        pull_ok = GitLinks.hard_pull(gl; verbose, clearwd = true) # clone again
        @test pull_ok
        @test isdir(local_root)
        @test isdir(local_repo_git)

        # upsize4 = GitLinks._foldersize(local_root)
        # upsize5 = GitLinks._foldersize(upstream_repo)
        # GitLinks._run("git -C $(upstream_repo) gc")
        # upsize6 = GitLinks._foldersize(upstream_repo)
        # @test upsize2 < upsize1
        # @show upsize0 upsize1 upsize2 upsize3 upsize4 upsize5 upsize6
        # @show upsize2 upsize5
        # @show upsize3 upsize4
        # @test upsize2 < upsize1
        
        println("\n", "-"^60)
        println("After nuking", "\n")
        run(`git -C $(upstream_repo) --no-pager log -l10 --pretty=oneline`)
        println()


    finally
        # clear
        GitLinks._rm(local_root)
        GitLinks._rm(upstream_repo)
    end
end
