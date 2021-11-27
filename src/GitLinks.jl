module GitLinks

import TOML

include("Types/GitLink.jl")

include("Utils/rand_str.jl")
include("Utils/toml_utils.jl")
include("Utils/runcmd.jl")

include("GitUtils/config.jl")
include("GitUtils/check_remote.jl")
include("GitUtils/check_gitdir.jl")
include("GitUtils/curr_branch.jl")
include("GitUtils/curr_hash.jl")
include("GitUtils/url_from_file.jl")
include("GitUtils/hard_pull.jl")
include("GitUtils/nuke_remote.jl")
include("GitUtils/soft_push.jl")
include("GitUtils/ready_to_push.jl")

include("TreeStruct/dir_and_files.jl")
include("TreeStruct/utils.jl")

include("Lock_system/lock_file.jl")

include("DevLand/create_local_upstream.jl")

end
