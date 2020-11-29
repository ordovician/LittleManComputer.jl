export assemble, symboltable

"Thrown if assembler doesn't know the mnemonic parsed"
struct InvalidMnemonicError <: Exception
    mnemonic::String
end

"Remove comment from source code line"
remove_comment(line) = split(line, "//") |> first |> strip

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
    possible_used_labels = Set{String}()
    
    address = 0
    
    for line in lines
        codeline = remove_comment(line)
        words = split(codeline)
        
        if isempty(words) continue end
        
        if length(words) > 1
            if haskey(opcodes, words[2]) || words[2] == "DAT"
                label = words[1]
                labels[label] = address
            end
            if isletter(words[end][1])
                push!(possible_used_labels, words[end])
            end
        end
        
        address += 1
    end
    
    # We don't need labels which are never used
    filter(labels) do (k, _)
        k in possible_used_labels 
    end
end

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
    i = findfirst(words) do word
        in(word, keys(opcodes)) || word == "DAT"
    end
    
    if i == nothing
        for word in words
            if word ∉ keys(labels) 
                throw(InvalidMnemonicError(word))
            end
        end
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
    @debug "found labels" labels
    
    for (i, line) in enumerate(lines)
        codeline = remove_comment(line)
        words = split(codeline)
        
        if isempty(words)
            continue
        end
        
        try
            instruction = assemble_mnemonic(words, labels)
            if instruction == nothing
                continue
            else
                @debug "parsed line $i:" line words instruction                
                push!(program, instruction)
            end            
        catch ex
            if isa(ex, InvalidMnemonicError)
                @error "Line $i: Encountered invalid mnemonic '$(ex.mnemonic)'"
            else
                rethrow()
            end
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
