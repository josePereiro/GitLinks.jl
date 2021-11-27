const _LS_REMOTE_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})\\s+HEAD")
function _check_remote(url::String)
    out = _run("git ls-remote $(url) 2>&1"; verbose = false, ignorestatus = true)
    m = match(_LS_REMOTE_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end