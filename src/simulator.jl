export CPU, simulate!
export simcallback


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

