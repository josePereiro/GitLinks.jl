module GitLinks

import TOML

include("GitUtils/check_remote.jl")
include("GitUtils/check_reporoot.jl")
include("GitUtils/curr_hash.jl")
include("GitUtils/url_from_file.jl")

include("Utils/rand_str.jl")
include("Utils/toml_utils.jl")
include("Utils/runcmd.jl")

include("Types/GitLink.jl")

include("TreeStruct/dir_and_files.jl")
include("TreeStruct/utils.jl")

include("Lock_system/lock_file.jl")

include("DevLand/create_local_upstream.jl")

end
