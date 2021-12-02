struct GitLink
    # Git stuff
    root_dir::String
    remote_url::String

    # System data
    dat::Dict{Any, Any}

    GitLink(root_dir, remote_url) = new(string(root_dir), string(remote_url), Dict{Any, Any}())
    GitLink(;root_dir, remote_url) = GitLink(root_dir, remote_url)
end

# overwrite base
import Base.show 

function Base.show(io::IO, gl::GitLink) 
    println(io, "GitLink(;")
    println(io, "   root_dir = \"", gl.root_dir, "\",")
    println(io, "   remote_url = \"", gl.remote_url, "\"")
    println(io, ")")
end

import Base.get!
get!(f::Function, gl::GitLink, key) = get!(f, gl.dat, key)
get!(gl::GitLink, key, val) = get!(gl.dat, key, val)

import Base.get
get(f::Function, gl::GitLink, key) = get(f, gl.dat, key)
get(gl::GitLink, key, val) = get(gl.dat, key, val)

set!(gl::GitLink, key, val) = (gl.dat[key] = val)
set!(f::Function, gl::GitLink, key) = (gl.dat[key] = f())

remote_url(gl::GitLink) = gl.remote_url