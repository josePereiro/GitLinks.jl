# lock_file
const _LOCK_FILE_NAME = ".gl.lock"
_lock_path(gl::GitLink) = joinpath(local_state_dir(gl), _LOCK_FILE_NAME)

lock_file(gl::GitLink) = get!(gl, _LOCK_FILE_NAME) do
    SimpleLockFiles.SimpleLockFile(_lock_path(gl))
end

import SimpleLockFiles.lock_path
lock_path(gl::GitLink) = lock_path(lock_file(gl))

import SimpleLockFiles.lock
lock(f::Function, gl::GitLink, lkid = _rand_token(); kwargs...) = 
    lock(f, lock_file(gl), lkid; kwargs...)

