using LittleManComputer
using Test

@testset "All Tests" begin

include("assem_tests.jl")
include("disassem_tests.jl")
include("simulator_tests.jl")

end