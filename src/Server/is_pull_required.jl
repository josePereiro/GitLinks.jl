function is_pull_required(gl::GitLink)
    gl_repo = repo_dir(gl)
    url = remote_url(gl)
    rhash = _remote_HEAD_hash(url)
    chash = _HEAD_hash(gl_repo)
    return rhash != chash
end