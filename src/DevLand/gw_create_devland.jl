## ---------------------------------------------------------------
function gw_create_devland(; 
        sys_root = homedir(),
        clear_repos = true, clear_scripts = false
    )

    _set_root!(sys_root)
    testdir = _gitworkers_homedir(".devland")

    reposdir = joinpath(testdir, "repos")
    clear_repos && _rm(reposdir)
    mkpath(reposdir)
    url, client_root, server_root = _create_test_repos(reposdir)

    # client script
    client_script = joinpath(testdir, "client.jl")
    server_script = joinpath(testdir, "server.jl")

    clear_scripts && rm(client_script; force = true)
    write(client_script, 
        join([
            "using GitLinks", 
            "",
            "## ---------------------------------------------------------------",
            "# cmd for run the server",
            "# julia '$(server_script)'",
            "",
            "## ---------------------------------------------------------------",
            "# run to reset all",
            "# GitLinks.gw_create_devland()",
            "",
            "## ---------------------------------------------------------------",
            "gw_setup_gitworker(;",
                """\tsys_root = "$(client_root)",""",
                """\turl = "$(url)",""",
            ")"
        ], "\n")
    )

    # server script
    clear_scripts && rm(server_script; force = true)
    write(server_script, 
        join([
            "using GitLinks", 
            "",
            "## ---------------------------------------------------------------",
            "run_gitworker_server(;",
                """\tsys_root = "$(server_root)", """,
                """\turl = "$(url)",""",
                """\tdeb = true """,
            ")"
        ], "\n")
    )
    
    @info("DevLand setup", client_script, server_script)
end