function is_pull_required(gl::GitLink)
    gl_repo = repo_dir(gl)
    url = remote_url(gl)
    return !_is_up_to_day(gl_repo, url)
end