let
    url, upstream_repo = GitLinks._create_local_upstream(tempname(); verbose = false)

    @assert !isempty(GitLinks._check_remote(url))
    @assert !isempty(GitLinks._curr_hash(upstream_repo))
    @assert GitLinks._check_remote(url) == GitLinks._curr_hash(upstream_repo)
    
    # clear
    rm(upstream_repo; recursive = true, force = true)
end
