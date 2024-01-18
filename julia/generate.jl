module Generate

export generate_sequences

# Generates t sequences all of length l, and returns an array of strings
function generate_sequences(t::Int64, l::Int64)
    # t is the number of sequences to create
     # l is the length of the sequences
     DNA = Array{String,1}(undef,0)
     base_arr = ["A", "T", "G", "C"]
 
     for t_index in 1:t
         push!(DNA, "")
         for l_value in 1:l
             r = convert(Int64, floor(Random.rand() * 4) + 1)
             DNA[t_index] = string(DNA[t_index], base_arr[r])
         end
     end
     return DNA    
end

end # module Generate