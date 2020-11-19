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

export assemble, disassemble, symboltable
export CPU, simulate!
export simcallback
export load

"""
    load(filename) -> Vector{Int}
Loads machine code file and return as an integer array
"""
function load(filename::AbstractString)
    parse.(Int, filter(!isempty, readlines(filename)))    
end

mutable struct CPU
   accumulator::Int
   pc::Int
end


"""
    simcallback(cpu::CPU, instruction::Integer)
A callback function for `simulate!` to visualize
instructions executed.
"""
function simcallback(cpu::CPU, instruction::Integer)
    println(cpu.pc, ":", instruction, 
            "\tAccu: ", rpad(cpu.accumulator, 3), 
            "// ", disassemble(instruction))    
end

function donothing(cpu::CPU, instruction::Integer) end

"""
    simulate!(mem = [0], inputs = Int[], callback = donothing)    
Executes a program stored in `mem`, where each entry in an integer array is a numeric code
for the little man computer. The callback is a function with the following signature:
    
    callback(cpu::CPU, instruction::Integer)
    
It tells what the current state of the virtual LMC CPU is before the `instruction`
is executed.
"""
function simulate!(mem::Vector{Int}=[0], inputs::Vector{Int}=Int[]; callback=donothing)
    cpu = CPU(0, 0)
    outputs = Int[]
    j = 1 # keep track of what input data should be read
    
    address(IR::Int) = rem(IR, 100)
    data(IR::Int) = mem[begin + address(IR)]
    
    # limit to 1000 instructions to avoid getting trapped
    for i in 1:50
        IR = mem[begin + cpu.pc]
        callback(cpu, IR)
        cpu.pc += 1
        
        opcode = div(IR, 100)
        if     opcode == 1
            cpu.accumulator += data(IR)
        elseif opcode == 2
            cpu.accumulator -= data(IR)           
        elseif opcode == 3
            mem[begin + address(IR)] = cpu.accumulator
        elseif opcode == 5
            cpu.accumulator = data(IR)
        elseif opcode == 6
            cpu.pc = address(IR)
        elseif opcode == 7
            if cpu.accumulator == 0
                cpu.pc = address(IR)
            end
        elseif opcode == 8
            if cpu.accumulator >= 0
                cpu.pc = address(IR)
            end
        elseif opcode == 0
            break
        elseif IR == 901
            if j > length(inputs)
                break
            end
            cpu.accumulator = inputs[j]
            j += 1
        elseif IR == 902
            push!(outputs, cpu.accumulator)
        else
            error("Unknown instruction found on address $(cpu.pc)")
        end      
    end
    outputs
end


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

"""
    symboltable(filename::AbstractString)
Parse `filename` and find all labels used in assembly program.
"""
function symboltable(filename::AbstractString)
    lines = readlines(filename)
    symboltable(lines)
end

"""
    symboltable(lines::AbstractArray{<:AbstractString})
Record address of labels used in code in a symbol table. 
Return this as a dictionary.

    symtable = symboltable("foobar.lmc")

    # Get address of LOOP label
    address = symtable["LOOP"]
"""
function symboltable(lines::AbstractArray{<:AbstractString})
    labels = Dict{String, Int}()
    address = 0
    
    for line in lines
        words = split(line)
        if isempty(words)
            continue
        end
        
        label = words[1]
        
        if !haskey(opcodes, label)
            labels[label] = address
        end
        
        address += 1
    end
    labels
end

"Remove comment from source code line"
remove_comment(line) = split(line, "//") |> first |> strip

"""
    assemble_mnemonic(words, labels) -> Union{Int, Nothing}
Assemble a single mnemonic split into multiple parts. Assume `words` is non-empty.
Words could contain only a label in which case `nothing` would be returned.

```julia-repl
julia> assemble_mnemonic(["somelabel"], Dict("somelabel" => 4))

julia> assemble_mnemonic(["ADD", "42"])
142
```
"""
function assemble_mnemonic(words::Vector{<:AbstractString}, labels=Dict{String, Int}())
    # Assume first word is mnemonic until disproven
    i = 1   
    if haskey(labels, words[1])
        if length(words) == 1
            return nothing
        end
        i = 2
    end
    
    # Check if we have a data directive and handle it
    if words[i] == "DAT"
		if length(words) > 2
            return parse(Int, words[i+1])
		else
			return 0 # If you value is set default is 0
		end
    end
    
    # Deal with regular assembly code
    mnemonic = words[i]
    if !haskey(opcodes, mnemonic)
        error("'$mnemonic' is an unknown mnemonic")
    end
    opcode = opcodes[mnemonic]
    if opcode != 0 && rem(opcode, 100) == 0
        arg = words[i+1]
        operand = if haskey(labels, arg)
            labels[arg]
        else
            parse(Int, arg)
        end
        
        return opcode + operand
    else
        return opcode
    end    
end
    
"""
     assemble(filename)
Turn assembly code found in `filename` into numeric codes (machine code).
Returned as an array of 3-digit decimal numbers.
"""
function assemble(filename::AbstractString)
    lines = readlines(filename)
    program = Int[]
    
    labels = symboltable(lines)
    
    for line in lines
        codeline = remove_comment(line)
        words = split(codeline)
        
        if isempty(words)
            continue
        end
        
        instruction = assemble_mnemonic(words, labels)
        if instruction == nothing
            continue
        else
            push!(program, instruction)
        end
    end
    program
end

"""
     assemble(filename, outfile)
Turn assembly code found in `filename` and store result in `outfile`
"""
function assemble(filename::AbstractString, outfile::AbstractString)
    program = assemble(filename)
    open(outfile, "w") do io
        for instruction in program
            println(io, instruction)
        end
    end
    program
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

end # module
