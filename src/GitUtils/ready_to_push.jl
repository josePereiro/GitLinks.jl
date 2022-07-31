const _DIRTY_TOKEN = "dirty"
const _CLEAN_TOKEN = "clean"
function _ready_to_push(repodir)
    _check_gitdir(repodir) || return true
    out = _read_bash("git -C $(repodir) diff-index --quiet HEAD && echo $(_CLEAN_TOKEN) || echo $(_DIRTY_TOKEN)";
        ignorestatus = false, verbose = false
    )
    return out == _CLEAN_TOKEN
end