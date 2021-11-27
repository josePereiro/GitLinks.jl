# ------------------------------------------------------------------------
# UTILS


# ------------------------------------------------------------------------
# DIRS

# root_dir
root_dir(gl::GitLink) = gl.root_dir

# repo_dir
const _REPO_DIR_NAME = ".gl-repo"
repo_dir(gl::GitLink) = joinpath(root_dir(gl), _REPO_DIR_NAME)

# state dirs
# glob_state_dir
const _GLOBAL_STATE_DIR_NAME = ".gl-glob-state"
global_state_dir(gl::GitLink) = joinpath(repo_dir(gl), _GLOBAL_STATE_DIR_NAME)

# local_state_dir
const _LOCAL_STATE_DIR_NAME = ".gl-local-state"
local_state_dir(gl::GitLink) = joinpath(root_dir(gl), _LOCAL_STATE_DIR_NAME)

# stage_dir
const _STAGE_DIR_NAME = ".gl-stage"
stage_dir(gl::GitLink) = joinpath(root_dir(gl), _STAGE_DIR_NAME)

