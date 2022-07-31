function _HEAD_commit_count(repodir)
    _check_gitdir(repodir) || return -1
    out = _read_bash("git -C $(repodir) rev-list --count HEAD 2>&1"; verbose = false, ignorestatus = true)
    println(out)
    return _tryparse(Int, string(strip(out)), -1)
end