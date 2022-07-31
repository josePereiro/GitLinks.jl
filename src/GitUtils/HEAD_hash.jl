const _HEAD_HASH_OK_REGEX = Regex("(?<hash>[0-9a-f]{40})")
function _HEAD_hash(repodir)
    _check_gitdir(repodir) || return ""
    out = _read_bash("git -C $(repodir) rev-parse HEAD 2>&1"; verbose = false, ignorestatus = true)
    m = match(_HEAD_HASH_OK_REGEX, out)
    isnothing(m) ? "" : m[:hash]
end
_HEAD_hash(gl::GitLink) = _HEAD_hash(repo_dir(gl))