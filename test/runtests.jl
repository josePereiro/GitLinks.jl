using GitLinks
using Test

@testset "GitLinks.jl" begin
    include("lock_file_tests.jl")
    include("git_utils_tests.jl")
end
