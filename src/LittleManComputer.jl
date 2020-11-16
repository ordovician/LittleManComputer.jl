"""
The LittleManComputer module used to assemble, disassamble and run code
written for the imaginary little man computer. This is a computer used
for educational purposed, to teach beginner assembly code programming.

# Example
    code = assemble("counter.lmc")
    inputs = [4, 3]
    outputs = execute(code, inputs)
       
Runs code stored in "counter.lmc" file with input `[4, 3]`.
"""
module LittleManComputer

export assemble, disassemble, symboltable
export CPU, execute

mutable struct CPU
   accumulator::Int
   pc::Int
end

"""
    execute(mem = [0], inputs = Int[])    
Executes a program stored in `mem`, where each entry in an integer array is a numeric code
for the little man computer.
"""
function execute(mem::Vector{Int} = [0], inputs::Vector{Int} = Int[])
    cpu = CPU(0, 0)
    outputs = Int[]
    
    address(IR::Int) = rem(IR, 100) + 1
    data(IR::Int) = mem[address(IR)]
    
    # limit to 1000 instructions to avoid getting trapped
    for i in 1:50
        IR = mem[cpu.pc+1]
        println("$(cpu.pc): $IR\tAccu: ", rpad(cpu.accumulator, 3), "// ", disassemble(IR))
        cpu.pc += 1
        
        opcode = div(IR, 100)
        if     opcode == 1
            cpu.accumulator += data(IR)
        elseif opcode == 2
            cpu.accumulator -= data(IR)           
        elseif opcode == 3
            mem[address(IR)] = cpu.accumulator
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
            input = popfirst!(inputs)
            cpu.accumulator = input
        elseif IR == 902
            push!(outputs, cpu.accumulator)
        else
            error("Unknown instruction found on address $(cpu.pc)")
        end      
    end
    outputs
end


const numeric_dict = Dict(
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

mnemonic_dict = Dict(value => key for (key, value) in numeric_dict)

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
        
        if !haskey(numeric_dict, label)
            labels[label] = address
        end
        
        address += 1
    end
    labels
end

"Remove comment from source code line"
remove_comment(line) = split(line, "//") |> first |> strip
    
"""
     assemble(filename)
Turn assembly code found in `filename` into numeric codes (machine code).
Returned as an array of 3-digit decimal numbers.
"""
function assemble(filename::AbstractString)
    lines = readlines(filename)
    memory = Int[]
    
    labels = symboltable(lines)
    
    for line in lines
        codeline = remove_comment(line)
        words = split(codeline)
        
        if isempty(words)
            continue
        end
        
        # Assume first word is mnemonic until disproven
        i = 1   
        if haskey(labels, words[1])
            if length(words) == 1
                continue
            end
            i = 2
        end
        
        # Check if we have a data directive and handle it
        if words[i] == "DAT"
			if length(words) > 2
                push!(memory, parse(Int, words[i+1]))
			else
				push!(memory, 0) # If you value is set default is 0
			end
            continue
        end
        
        # Deal with regular assembly code
        mnemonic = words[i]
        opcode = numeric_dict[mnemonic]
        if opcode != 0 && rem(opcode, 100) == 0
            arg = words[i+1]
            operand = if haskey(labels, arg)
                labels[arg]
            else
                parse(Int, arg)
            end
            
            push!(memory, opcode + operand)
        else
            push!(memory, opcode)
        end
    end
    memory
end

"""
     assemble(filename, outfile)
Turn assembly code found in `filename` and store result in `outfile`
"""
function assemble(filename::AbstractString, outfile::AbstractString)
    mem = assemble(filename)
    open(outfile, "w") do io
        for m in mem
            println(io, m)
        end
    end
    mem
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
    disassemble(code::Integer)
Disassemble single instruction.
"""
function disassemble(code::Integer)
    if code == 0
        "HLT"
    elseif code < 100
        "DAT $code"
    elseif code > 900
        mnemonic_dict[code]
    else
        opcode = div(code, 100) * 100
        m = mnemonic_dict[opcode]
        operand = rem(code, 100) 
        
        string(m, " ", operand)       
    end
end

"""
    disassemble(mem::Vector{Int})
Disassemble array of numerical codes for Little Man Computer.    
"""
function disassemble(mem::Vector{<:Integer})
    lines = map(disassemble, mem)
    
    for (i, line) in enumerate(lines)
       println(lpad(i-1, 3), " ", line) 
    end
end

end # module
