# ------------------------------------------------------------------------
# UTILS


# ------------------------------------------------------------------------
# DIRS

# root_dir
root_dir(gl::GitLink) = gl.root_dir

# repo_dir
const _REPO_DIR_NAME = ".gl-repo"
_repo_dir(gl::GitLink) = joinpath(root_dir(gl), _REPO_DIR_NAME)
const _REPO_DIR_KEY = :repo_dir_key
repo_dir(gl::GitLink) = _gl_dat_fun(gl, _REPO_DIR_KEY, _repo_dir)

# state dirs

# glob_state_dir
const _GLOBAL_STATE_DIR_NAME = ".gl-glob-state"
_global_state_dir(gl::GitLink) = joinpath(_repo_dir(gl), _GLOBAL_STATE_DIR_NAME)
const _GLOBAL_STATE_DIR_KEY = :glob_state_dir_key
global_state_dir(gl::GitLink) = _gl_dat_fun(gl, _GLOBAL_STATE_DIR_KEY, _global_state_dir)

# local_state_dir
const _LOCAL_STATE_DIR_NAME = ".gl-local-state"
_local_state_dir(gl::GitLink) = joinpath(root_dir(gl), _LOCAL_STATE_DIR_NAME)
const _LOCAL_STATE_DIR_KEY = :local_state_dir_key
local_state_dir(gl::GitLink) = _gl_dat_fun(gl, _LOCAL_STATE_DIR_KEY, _local_state_dir)

# stage_dir
const _STAGE_DIR_NAME = ".gl-stage"
_stage_dir(gl::GitLink) = joinpath(root_dir(gl), _STAGE_DIR_NAME)
const _STAGE_DIR_KEY = :stage_dir_key
stage_dir(gl::GitLink) = _gl_dat_fun(gl, _STAGE_DIR_KEY, _stage_dir)

