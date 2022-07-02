function _list_commits(repodir::String, branch::String; count = 10)
    !_check_gitdir(repodir) && return String[]
    out = _read_bash("git -C $(repodir) rev-list $(branch) --max-count=$(count) 2>&1"; verbose = false, ignorestatus = true)
    return split(strip(out))
end