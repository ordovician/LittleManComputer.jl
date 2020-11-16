datadir = joinpath(dirname(@__FILE__), "data")
examples = joinpath(dirname(@__FILE__), "../examples")

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
        target = [100, 200, 300, 500, 600, 700, 800, 901, 902, 000]
        mem = assemble(joinpath(datadir, "instructionset.lmc"))
        for (i, t) in enumerate(target)
            @test mem[i] == t
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
end
