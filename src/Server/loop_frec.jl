const _LOOP_FREC_KEY = :loop_frec_key
const _MIN_LOOP_FREC = 1.0
const _MAX_LOOP_FREC = 120.0

const _LOCAL_STATE_DIR_NAME = ".gl-local-state"
get_loop_frec(gl::GitLink) = joinpath(root_dir(gl), _LOCAL_STATE_DIR_NAME)
const _LOCAL_STATE_DIR_KEY = :local_state_dir_key
# local_state_dir(gl::GitLink) = get!(() -> _lock_file(gl), gl, _LOCK_FILE_KEY)


_set_loop_frec()