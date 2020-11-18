examples = joinpath(@__DIR__, "../examples")

@testset "Simulator tests" begin
   
    @testset "Add two numbers" begin
        program = load(joinpath(examples, "add-two-inputs.machine"))
        
        output = simulate!(copy(program), [3, 4])
        @test output[1] == 3 + 4
        
        output = simulate!(copy(program), [12, 8])
        @test output[1] == 12 + 8        
    end
    

    @testset "Count down" begin
        program = load(joinpath(examples, "count-down.machine"))
        
        output = simulate!(copy(program), [3])
        @test output == [3, 2, 1, 0] 
        
        output = simulate!(copy(program), [6])
        @test output == [6, 5, 4, 3, 2, 1, 0]
    end
    
    # @testset "Factorial" begin
    #     program = load(joinpath(examples, "factorial.machine"))
    #
    #     output = simulate!(copy(program), [3])
    #     @test_broken  output == [6]
    #
    #     output = simulate!(copy(program), [4])
    #     @test_broken  output == [24]
    # end
    
end
