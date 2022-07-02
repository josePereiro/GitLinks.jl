"""
    create_local_upstream(rootdir = tempname(); verbose = true, branch_name = "main")

Creates a local repo usable as a remote for testing.
Returns a tuple (;url, upstream_repo)
"""
function create_local_upstream(
        rootdir = tempname(); 
        verbose = true,
        branch_name = "main"
    )
    
    # home dirs
    upstream_repo = joinpath(rootdir, "upstream")
    _rm(upstream_repo)
    mkpath(upstream_repo)
    
    # create upstream
    verbose && @info("setting up upstream")
    url = _url_from_file(upstream_repo)
    _read_bash("git -C $(upstream_repo) --bare init 2>&1"; verbose)
    verbose && println(read(joinpath(upstream_repo, "config"), String))
    verbose && println("\n")
    
    # make first commit
    cdir = tempname()
    mkpath(cdir)
    _read_bash("git clone $(url) $(cdir) 2>&1"; verbose)
    dumpfile = joinpath(cdir, "README.md")
    write(dumpfile, "# TEST")
    _read_bash("git -C $(cdir) add -A 2>&1"; verbose)
    commit_msg = "Test upstream created"
    user_name = get_global_config("user.name", "GitLink")
    user_email = get_global_config("user.email", "fake@email.com")
    _read_bash("git -C $(cdir) -c user.name='$(user_name)' -c user.email='$(user_email)' commit -am '$(commit_msg)' 2>&1"; verbose)
    _read_bash("git -C $(cdir) push 2>&1"; verbose)

    # rename branch
    curr_branch = _curr_branch(upstream_repo)
    if curr_branch != branch_name
        _read_bash("git -C $(upstream_repo) branch -m $(curr_branch) $(branch_name) 2>&1"; verbose)
    end
    
    verbose && println("\n", "-"^60, "\n")
    _read_bash("git -C $(upstream_repo) --no-pager log 2>&1"; verbose)

    _rm(cdir)

    return (;url, upstream_repo)
end