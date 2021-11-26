_write_toml(fn, dat::Dict) = open(fn, "w") do io
    TOML.print(io, dat; sorted=true)
    return fn
end

_write_toml(fn; kwargs...) = _write_toml(fn, _dict(;kwargs...))

function _read_toml(fn)
    !isfile(fn) && return Dict{String, Any}()
    try; return TOML.parsefile(fn)
    catch err
        (err isa Base.TOML.ParserError) && return Dict{String, Any}()
        rethrow(err)
    end
end

function _has_content(fn; kwargs...)
    dat = _read_toml(fn)
    isempty(kwargs) && return false
    for (k0, v0) in kwargs
        strk = string(k0)
        !haskey(dat, strk) && return false
        v0 != dat[strk] && return false
    end
    return true
end

function _has_key(fn, keys...)
    dat = _read_toml(fn)
    isempty(keys) && return false
    for k0 in keys
        strk = string(k0)
        !haskey(dat, strk) && return false
    end
    return true
end