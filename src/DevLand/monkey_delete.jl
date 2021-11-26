function _monkey_delete(dir::AbstractString, frec::Float64; verb = true)
    frec < rand() || return
    for (root, _, files) in walkdir(dir)
        for file in files
            frec > rand() && continue
            rfile = joinpath(root, file)
            _gwrm(rfile)
            verb && println("monkey deleted!! ", rfile)
        end
    end
end