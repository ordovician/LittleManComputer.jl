datadir = joinpath(@__DIR__, "data")
examples = joinpath(@__DIR__, "../examples")

@testset "Assembler tests" begin
    @testset "Symbol table" begin
        syms = symboltable(joinpath(datadir, "labels.lmc"))
        target = Dict("zero" => 0, "one" => 1, "two" => 2, "three" => 3)
        for (k, v) in target
            @test haskey(syms, k)
            @test syms[k] == v
        end
    end
    
    @testset "Instruction set" begin
        instructions = [100, 200, 300, 500, 600, 
                        700, 800, 901, 902, 000]
        filepath = joinpath(datadir, "instructionset.lmc")
        program = assemble(filepath)
        for (i, expected) in enumerate(instructions)
            @test program[i] == expected
        end
    end
    
	@testset "Regression test" begin
		files = map(filter(endswith(".machine"), readdir(examples))) do filename
			splitext(filename)[1]
		end
		for file in files
			machinefile = joinpath(examples, string(file, ".machine"))
			srcfile 	= joinpath(examples, string(file, ".lmc"))
			@test isfile(machinefile)
			@test isfile(srcfile)
		 
			target = parse.(Int, filter(!isempty, readlines(machinefile)))
			memory = assemble(srcfile)
			@test memory == target
		end
	end
    
    @testset "Assemble mnemonic" begin
        using LittleManComputer: assemble_mnemonic

        labels = Dict("foo" => 42, "bar" => 7)
        
        @test assemble_mnemonic(["ADD", "12"]) == 112 
        @test assemble_mnemonic(["SUB", "4"]) == 204
        @test assemble_mnemonic(["ADD", "foo"], labels) == 142
        @test assemble_mnemonic(["SUB", "bar"], labels) == 207        
        
        @test assemble_mnemonic(["BRZ", "bar"], labels) == 707
        @test assemble_mnemonic(["BRZ", "foo"], labels) == 742
        @test assemble_mnemonic(["BRZ", "55"]) == 755
        @test assemble_mnemonic(["LDA", "37"]) == 537
        @test assemble_mnemonic(["LDA", "foo"], labels) == 542
    end
       
end
