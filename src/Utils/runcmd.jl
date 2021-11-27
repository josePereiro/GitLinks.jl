function _run(cmd::Cmd; ignorestatus = true, verbose = true)
    cmd = Cmd(cmd; ignorestatus)
    out = read(cmd, String)
    verbose && println(out)
    return out
end

function _run(cmd::String; ignorestatus = true, verbose = true)
    cmd = Cmd(`bash -c $(cmd)`)
    _run(cmd::Cmd; ignorestatus, verbose)
end