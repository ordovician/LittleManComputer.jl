# Just for demontration purposes to show how you can configure what
# tests to run. This is for when you run tests from the shell rather
# than inside the Julia package manager.
# shell> julia test/testrunner.jl disassem

using LittleManComputer
using Test

tests = ["assem", "disassem", "simulator"]
if !isempty(ARGS)
	tests = ARGS  # Set list to same as command line args
end

@testset "All Tests" begin
    for t in tests
        include("$(t)_tests.jl")
    end
end
