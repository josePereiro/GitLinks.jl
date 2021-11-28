function _commits_behind_remote(repodir::String, url::String, remote_branch::String; deep = 10)
    _fetch(repodir, url; verbose = false) || return -1
    clist = _list_commits(repodir, remote_branch; count = deep)    
    ch = GitLinks._HEAD_hash(repodir)
    chidx = findfirst(isequal(ch), clist)
    return isnothing(chidx) ? -1 : chidx - 1
end
_commits_behind_remote(gl::GitLink, remote_branch::String; kwargs...) = 
    _commits_behind_remote(repo_dir(gl), remote_url(gl), remote_branch; kwargs...)