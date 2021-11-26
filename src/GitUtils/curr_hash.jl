const _CURR_HASH_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})")
function _curr_hash()
    cmd = Cmd(["git", "rev-parse", "HEAD"])
    cmd = Cmd(cmd; ignorestatus = true)
    out = read(cmd, String)
    m = match(_CURR_HASH_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end