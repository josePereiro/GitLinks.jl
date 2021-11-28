module GitLinks

import TOML

include("Types/GitLink.jl")

include("Utils/rand_str.jl")
include("Utils/toml_utils.jl")
include("Utils/runcmd.jl")

include("GitUtils/check_gitdir.jl")
include("GitUtils/check_remote.jl")
include("GitUtils/config.jl")
include("GitUtils/curr_branch.jl")
include("GitUtils/curr_hash.jl")
include("GitUtils/hard_pull.jl")
include("GitUtils/is_up_to_day.jl")
include("GitUtils/nuke_remote.jl")
include("GitUtils/ready_to_push.jl")
include("GitUtils/soft_push.jl")
include("GitUtils/url_from_file.jl")

include("TreeStruct/dir_and_files.jl")
include("TreeStruct/utils.jl")

include("Lock_system/lock_file.jl")

include("DevLand/create_local_upstream.jl")

include("Server/instantiate.jl")
include("Server/loop_frec.jl")
include("Server/is_pull_required.jl")
include("Server/readwdir.jl")
include("Server/stage.jl")
include("Server/sync_loop.jl")
include("Server/tokens.jl")

export GitLink, instantiate, stage, readwdir

end
