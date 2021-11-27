function get_global_config(configtag, dfl = "")
    out = _run("git config $(configtag)"; verbose = false, ignorestatus = true)
    out = strip(out)
    isempty(out) ? dfl : out
end