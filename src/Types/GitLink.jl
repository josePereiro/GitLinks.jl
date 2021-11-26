struct GitLink
    # Git stuff
    root_dir::String
    remote_url::String

    # System data
    dat::Dict{Symbol, Any}

    GitLink(root_dir, remote_url) = new(string(root_dir), string(remote_url), Dict{Symbol, Any}())
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

_gl_dat_fun(gl, key, _fun) = haskey(gl.dat, key) ?
    gl.dat[key] :
    gl.dat[key] = _fun(gl)

