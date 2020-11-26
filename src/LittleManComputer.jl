"""
The LittleManComputer module used to assemble, disassamble and run code
written for the imaginary little man computer. This is a computer used
for educational purposed, to teach beginner assembly code programming.

# Example
    code = assemble("counter.lmc")
    inputs = [4, 3]
    outputs = simulate!(code, inputs)
       
Runs code stored in "counter.lmc" file with input `[4, 3]`.
"""
module LittleManComputer


const opcodes = Dict(
    "ADD" => 100,
    "SUB" => 200,
    "STA" => 300,
    "LDA" => 500,
    "BRA" => 600,
    "BRZ" => 700,
    "BRP" => 800,
    "INP" => 901,
    "OUT" => 902,
    "HLT" => 000
)

const mnemonics = Dict(value => key for (key, value) in opcodes)

include("assembler.jl")
include("disassembler.jl")
include("simulator.jl")

end # module
