function _commits_behind_remote(repodir::String, url::String, remote_branch = "origin/main"; deep = 10)
    _fetch(repodir, url; verbose = false) || return -1
    clist = _list_commits(repodir, remote_branch; count = deep)    
    ch = GitLinks._HEAD_hash(repodir)
    chidx = findfirst(isequal(ch), clist)
    return isnothing(chidx) ? -1 : diff - 1
end
_fetch(gl::GitLink, remote_branch = "origin/main"; kwargs...) = 
    _fetch(repo_dir(gl), remote_url(gl), remote_branch = "origin/main"; kwargs...)