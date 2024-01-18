module FileIO

export get_sequences_from_file, write_to_file

# get sequences from the input file
function get_sequences_from_file(file_name)
    sequences = []
    flag_first_arrow = true
    open(file_name) do f
        sequence = ""
        for line in eachline(f)
            if startswith(line, '>') 
                if flag_first_arrow
                    flag_first_arrow = false
                    continue
                end
                push!(sequences, sequence)
                sequence = ""
            else
                sequence *= line
            end
        end
        if length(sequence) > 0
            push!(sequences, sequence)
        end
    end
    return sequences
end

# write output to the file
function write_to_file(output_filename, aligned_sequences)
    touch(output_filename)
    f = open(output_filename, "w") 
    for i in eachindex(aligned_sequences)
        seq_num = string(">s",i)
        write(f,string(seq_num,"\n"))
        write(f,aligned_sequences[i])
        write(f,"\n")
    end
    close(f) 
end

end