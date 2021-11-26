"""
    print the err text
"""
_printerr(io::IO, err) = print(io, _err_str(err))
_printerr(err) = _printerr(stdout, err)

function _dict(d = Dict{String, Any}(); kwargs...) 
	for (k, v) in kwargs
		d[string(k)] = v
	end
	return d
end