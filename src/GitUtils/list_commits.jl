function _list_commits(repodir::String, branch::String = "main"; count = 10)
    !_check_gitdir(repodir) && return String[]
    out = _run("git -C $(repodir) rev-list $(branch) --max-count=$(count) 2>&1"; verbose = false, ignorestatus = true)
    return split(strip(out))
end