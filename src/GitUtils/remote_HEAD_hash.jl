const _LS_REMOTE_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})\\h+HEAD")
function _remote_HEAD_hash(url::String)
    out = _read_bash("git ls-remote $(url) HEAD 2>&1"; verbose = false, ignorestatus = true)
    m = match(_LS_REMOTE_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end
_remote_HEAD_hash(gl::GitLink) = _remote_HEAD_hash(remote_url(gl))