const _LS_REMOTE_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})\\s+HEAD")
function _check_remote(url::String)
    cmd = Cmd(["git", "ls-remote", url])
    cmd = Cmd(cmd; ignorestatus = true)
    out = read(cmd, String)
    m = match(_LS_REMOTE_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end