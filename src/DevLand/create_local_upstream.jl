function _create_local_upstream(rootdir; verbose = true)
    
    # home dirs
    upstream_repo = joinpath(rootdir, "upstream_repo")
    mkpath(upstream_repo)
    
    # create upstream
    verbose && @info("setting up upstream")
    url = _url_from_file(upstream_repo)
    _run("git -C $(upstream_repo) --bare init 2>&1"; verbose)
    _run("git -C $(upstream_repo) config user.name jonhdoe 2>&1"; verbose)
    _run("git -C $(upstream_repo) config user.email bla@gmail.com 2>&1"; verbose)
    verbose && println(read(joinpath(upstream_repo, "config"), String))
    verbose && println("\n")

    # make first commit
    cdir = tempname()
    mkpath(cdir)
    _run("git clone $(url) $(cdir) 2>&1"; verbose)
    dumpfile = joinpath(cdir, "README.md")
    write(dumpfile, "# TEST")
    _run("git -C $(cdir) add $(dumpfile) 2>&1"; verbose)
    _run("git -C $(cdir) commit -m 'First commit' 2>&1"; verbose)
    _run("git -C $(cdir) push 2>&1"; verbose)
    
    verbose && println("\n", "-"^60, "\n")
    _run("git -C $(upstream_repo) --no-pager log 2>&1"; verbose)

    rm(cdir; recursive = true, force = true)

    return (;url, upstream_repo)
end