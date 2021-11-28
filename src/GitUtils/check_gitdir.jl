# Check that the given folder is indead the root of a git repo.
function _check_gitdir(reporoot)
    !isdir(reporoot) && return false
    out = _run("git -C $(reporoot) rev-parse --git-dir 2>&1"; verbose = false, ignorestatus = true)
    reporoot1 = strip(out)
    reporoot1 == ".git" && return true
    reporoot1 == "." && return true
    return false
end