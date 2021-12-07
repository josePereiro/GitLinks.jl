function _run(cmd::Cmd; ignorestatus = true, verbose = true)
    cmd = Cmd(cmd; ignorestatus)
    out = read(cmd, String)
    verbose && _printcmd(out)
    return out
end

function _run(cmd::String; ignorestatus = true, verbose = true)
    cmd = Cmd(`bash -c $(cmd)`)
    _run(cmd; ignorestatus, verbose)
end

# For logging
function _printcmd(str::String; len = 60)
    isempty(str) && return
    str = strip(str)
    if length(str) > len
        @info(string("\n", str, "\n", " "))
    else
        @info(str)
    end
end
