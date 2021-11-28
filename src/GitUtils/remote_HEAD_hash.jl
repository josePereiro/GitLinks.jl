const _LS_REMOTE_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})\\s+HEAD")
function _remote_HEAD_hash(url::String)
    out = _run("git ls-remote $(url) 2>&1"; verbose = false, ignorestatus = true)
    m = match(_LS_REMOTE_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end
_remote_HEAD_hash(gl::GitLink) = _remote_HEAD_hash(remote_url(gl))