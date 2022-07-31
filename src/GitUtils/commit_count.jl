function _HEAD_commit_count(repodir)
    _check_gitdir(repodir) || return -1
    out = _read_bash("git -C $(repodir) rev-list --count HEAD 2>&1"; verbose = false, ignorestatus = true)
    return _tryparse(Int, string(strip(out)), -1)
end
_HEAD_commit_count(gl::GitLink) = _HEAD_commit_count(repo_dir(gl))

function _remote_HEAD_commit_count(repodir)
    _check_gitdir(repodir) || return -1
    out = _read_bash("git -C $(repodir) rev-list --count remotes/origin/HEAD 2>&1"; verbose = false, ignorestatus = true)
    return _tryparse(Int, string(strip(out)), -1)
end
_remote_HEAD_commit_count(gl::GitLink) = _remote_HEAD_commit_count(repo_dir(gl))