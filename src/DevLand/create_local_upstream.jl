function _create_local_upstream(rootdir = tempname(); verbose = true)
    
    # home dirs
    upstream_repo = joinpath(rootdir, "upstream_repo")
    mkpath(upstream_repo)
    
    # create upstream
    verbose && @info("setting up upstream")
    url = _url_from_file(upstream_repo)
    _run("git -C $(upstream_repo) --bare init 2>&1"; verbose)
    verbose && println(read(joinpath(upstream_repo, "config"), String))
    verbose && println("\n")
    
    # make first commit
    cdir = tempname()
    mkpath(cdir)
    _run("git clone $(url) $(cdir) 2>&1"; verbose)
    dumpfile = joinpath(cdir, "README.md")
    write(dumpfile, "# TEST")
    _run("git -C $(cdir) add -A 2>&1"; verbose)
    commit_msg = "Test upstream created"
    user_name = get_global_config("user.name", "GitLink")
    user_email = get_global_config("user.email", "fake@email.com")
    _run("git -C $(cdir) -c user.name='$(user_name)' -c user.email='$(user_email)' commit -am '$(commit_msg)' 2>&1"; verbose)
    _run("git -C $(cdir) push 2>&1"; verbose)

    # rename branch
    _run("git -C $(upstream_repo) branch -m master main"; verbose)
    
    verbose && println("\n", "-"^60, "\n")
    _run("git -C $(upstream_repo) --no-pager log 2>&1"; verbose)

    _rm(cdir)

    return (;url, upstream_repo)
end