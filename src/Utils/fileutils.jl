_mkdir(path) = mkpath(dirname(path))

_readdir(dir; join::Bool = false, sort::Bool = true) = 
    isdir(dir) ? readdir(dir; join, sort) : String[]

function _readdir(f::Function, dir; kwargs...)
    for file in _readdir(dir; kwargs...)
        f(file)
    end
end

function _rm(path)
    try; rm(path; recursive = true, force = true)
    catch err; end
end

function _foldersize(dir)
    size = 0
    for (root, _, files) in walkdir(dir)
        size += sum(filesize.(joinpath.(root, files)))
    end
    return size
end

function _cp(src::AbstractString, dst::AbstractString)
    try; cp(src, dst; force = true)
    catch err; end
end

function _merge_dirs(src::AbstractString, dst::AbstractString)
    src = abspath(src)
    dst = abspath(dst)
    for srci in _readdir(src; join = true)
        desti = replace(srci, src => dst)
        _cp(srci, desti)
    end
end

function _clear_wd(gl_repo)
    for path in _readdir(gl_repo; join = true)
        endswith(path, ".git") && continue
        _rm(path)
    end
end