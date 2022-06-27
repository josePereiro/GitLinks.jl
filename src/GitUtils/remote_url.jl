function _remote_url(repodir::String)
    cmd_str = "git -C $(repodir) remote get-url $(_REMOTE_NAME) 2>&1"
    out = _run(cmd_str; verbose = false, ignorestatus = true)
    return string(strip(out))
end