export assemble, symboltable

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
