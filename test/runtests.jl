using GitLinks
using Test

@testset "GitLinks.jl" begin
    include("git_utils_tests.jl")
    include("lock_file_tests.jl")
end
