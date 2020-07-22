module LittleManComputer

export assemble, symboltable
export CPU, execute

mutable struct CPU
   accumulator::Int
   pc::Int
end


function execute(mem::Vector{Int} = Int[0], inputs::Vector{Int} = Int[0])
    cpu = CPU(0, 0)
    outputs = Int[]
    
    operand(IR::Int) = rem(IR, 100)
    data(IR::Int) = mem[operand(IR)+1]
    
    println("Address: Instruction Accu: value")
    # limit to 1000 instructions to avoid getting trapped
    for i in 1:50
        IR = mem[cpu.pc+1]
        println("$(cpu.pc): $IR\tAccu: $(cpu.accumulator)")
        cpu.pc += 1
        
        opcode = div(IR, 100)
        if     opcode == 1
            cpu.accumulator += data(IR)
        elseif opcode == 2
            cpu.accumulator -= data(IR)           
        elseif opcode == 3
            mem[data(IR)] = cpu.accumulator
        elseif opcode == 5
            cpu.accumulator = data(IR)
        elseif opcode == 6
            cpu.pc = operand(IR)
        elseif opcode == 7
            if cpu.accumulator == 0
                cpu.pc = operand(IR)
            end
        elseif opcode == 8
            if cpu.accumulator >= 0
                cpu.pc = operand(IR)
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

function symboltable(filename::AbstractString)
    lines = readlines(filename)
    symboltable(lines)
end

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

function assemble(filename::AbstractString)
    lines = readlines(filename)
    memory = Int[]
    
    labels = symboltable(lines)
    
    for line in lines
        codeline = split(line, "//") |> first |> strip # Get rid of comments
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
            push!(memory, parse(Int, words[i+1]))
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

end # module
