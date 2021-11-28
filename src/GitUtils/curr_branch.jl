function _curr_branch(repodir)
    !_check_gitdir(repodir) && return ""
    out = _run("git -C $(repodir) rev-parse --abbrev-ref HEAD 2>&1"; verbose = false, ignorestatus = true)
    return string(strip(out))
end