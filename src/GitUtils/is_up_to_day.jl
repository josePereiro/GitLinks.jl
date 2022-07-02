function _is_up_to_day(repodir, url)
    rhash = _remote_HEAD_hash(url)
    chash = _HEAD_hash(repodir)
    return !isempty(rhash) && (rhash == chash)
end