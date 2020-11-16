datadir = joinpath(dirname(@__FILE__), "data")
examples = joinpath(dirname(@__FILE__), "../examples")

@testset "Disassembler tests" begin    
    @testset "Individual instructions" begin
        @test disassemble(901) == "INP"
        @test disassemble(902) == "OUT"
        @test disassemble(0) == "HLT"
        @test disassemble(105) == "ADD 5"
        @test disassemble(112) == "ADD 12"
        @test disassemble(243) == "SUB 43"
        @test disassemble(399) == "STA 99"
        @test disassemble(510) == "LDA 10"
        @test disassemble(600) == "BRA 0"
        @test disassemble(645) == "BRA 45"
        @test disassemble(782) == "BRZ 82"                                        
    end    
end
