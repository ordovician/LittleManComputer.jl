export disassemble
export load

"""
    load(filename) -> Vector{Int}
Loads machine code file and return as an integer array
"""
function load(filename::AbstractString)
    parse.(Int, filter(!isempty, readlines(filename)))    
end

"""
    disassemble(filename::AbstractString)
Print out the disassembled contents of `filename`. We assume the file
contains Little Man Computer numerical codes (3 digits each).  
"""
function disassemble(filename::AbstractString)
    lines = readlines(filename)
    disassemble(parse.(Int, lines))
end


"""
    disassemble(instruction::Integer)
Disassemble single instruction and produce the mnemonic and operand
"""
function disassemble(instruction::Integer)
    if instruction == 0
        "HLT"
    elseif instruction < 100
        "DAT $code"
    elseif instruction > 900
        mnemonics[instruction]
    else
        opcode   = div(instruction, 100) * 100
        mnemonic = mnemonics[opcode]
        operand  = rem(instruction, 100) 
        
        string(mnemonic, " ", operand)       
    end
end

"""
    disassemble(program::Vector{Int})
Disassemble array of instructions for Little Man Computer.    
"""
function disassemble(program::Vector{<:Integer})
    lines = map(disassemble, program)
    
    for (i, line) in enumerate(lines)
       println(lpad(i-1, 3), " ", line) 
    end
end
