function _monkey_delete(dir::AbstractString, frec::Float64; verbose = true)
    frec < rand() || return
    for (root, _, files) in walkdir(dir)
        for file in files
            frec > rand() && continue
            rfile = joinpath(root, file)
            _rm(rfile)
            verbose && println("monkey deleted!! ", rfile)
        end
    end
end