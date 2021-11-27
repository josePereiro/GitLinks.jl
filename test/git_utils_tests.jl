let

    # upstream
    url, upstream_repo = GitLinks._create_local_upstream(tempname(); verbose = false)

    @test !isempty(GitLinks._check_remote(url))
    @test !isempty(GitLinks._curr_hash(upstream_repo))
    @test GitLinks._check_remote(url) == GitLinks._curr_hash(upstream_repo)

    @test GitLinks._check_gitdir(upstream_repo)
    @test !GitLinks._check_gitdir(tempname())

    # local repo
    local_root = tempname()
    rm(local_root; recursive = true, force = true)
    gl = GitLinks.GitLink(local_root, url)
    
    # hard pull
    @test !isdir(local_root)
    pull_ok = GitLinks.hard_pull(gl; verbose = false, clearwd = true) # clone
    @test pull_ok
    @test isdir(local_root)
    
    pull_ok = GitLinks.hard_pull(gl; verbose = false, clearwd = true) # pull
    @test pull_ok
    @test isdir(local_root)
    
    rm(joinpath(local_root, ".git"); recursive = true, force = true) # break repo
    @test !GitLinks._check_gitdir(local_root)
    pull_ok = GitLinks.hard_pull(gl; verbose = false, clearwd = true) # must recover
    @test pull_ok
    @test isdir(local_root)

    # soft push
    push_ok = GitLinks.soft_push(gl; verbose = false)
    @test push_ok
    
    # clear
    rm(local_root; recursive = true, force = true)
    rm(upstream_repo; recursive = true, force = true)
end
