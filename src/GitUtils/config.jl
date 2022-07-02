function get_global_config(configtag, dfl = "")
    out = _read_bash("git config $(configtag)"; verbose = false, ignorestatus = true)
    out = string(strip(out))
    isempty(out) ? dfl : out
end