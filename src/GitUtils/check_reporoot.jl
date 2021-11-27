function _check_reporoot(reporoot)
    !isdir(reporoot) && return false
    reporoot1 = _run("git -C $(reporoot) rev-parse --git-dir 2>&1"; verbose = false, ignorestatus = true)
    reporoot1 = strip(reporoot1)
    reporoot1 == ".git" && return true
    reporoot1 == "." && return true
    return false
end