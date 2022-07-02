is_uptoday(gl::GitLink) = !is_pull_required(gl) && !is_push_required(gl)

has_connection(gl::GitLink) = !isempty(_remote_HEAD_hash(remote_url(gl)))