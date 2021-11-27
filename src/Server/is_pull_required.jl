function _is_pull_required(gl::GitLink)
    gl_repo = repo_dir(gl)
    url = remote_url(gl)
    rhash = _check_remote(url)
    chash = _curr_hash(gl_repo)
    return rhash != chash
end