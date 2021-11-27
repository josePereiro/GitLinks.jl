function _is_up_to_day(repodir, url)
    rhash = _check_remote(url)
    chash = _curr_hash(repodir)
    return rhash == chash
end