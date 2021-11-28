function _curr_remotes(repodir::String)
    !_check_gitdir(repodir) && return String[]
    out = _run("git -C $(repodir) remote 2>&1"; verbose = false, ignorestatus = true)
    return split(out, "\n"; keepempty = false)
end