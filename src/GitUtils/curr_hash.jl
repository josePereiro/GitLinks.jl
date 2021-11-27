const _CURR_HASH_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})")
function _curr_hash(repodir)
    !_check_gitdir(repodir) && return ""
    out = _run("git -C $(repodir) rev-parse HEAD 2>&1"; verbose = false, ignorestatus = true)
    m = match(_CURR_HASH_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end