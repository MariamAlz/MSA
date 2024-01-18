module Alignment

export MSA_to_TSP, produce_global_alignment, find_gap_indices, insert_gaps, align_output_sequences

# perform the needleman-wunsch on two sequences v and w, returns the score and algined sequences
function produce_global_alignment(v, w, match_penalty=1, mismatch_penalty=-1, deletion_penalty=-1)
    rows = length(v)+1
    cols = length(w)+1
    dp = zeros(Float64, rows, cols)
    direction = zeros(Float64, rows, cols)
    for i in 1:(rows)
        dp[i,1] = (i-1) * deletion_penalty
        direction[i,1] = 2
    end
    for i in 1:(cols)
        dp[1,i] = (i-1) * deletion_penalty
        direction[1,i] = 3
    end
    for i in 2:(rows)
        for j in 2:(cols)
            if v[i-1] == w[j-1]
                ms = dp[i-1,j-1] + match_penalty
            else
                ms = dp[i-1,j-1] + mismatch_penalty
            end
            score = [ms, dp[i-1,j] + deletion_penalty, dp[i,j-1] + deletion_penalty]
            max_element = findmax(score)
            dp[i,j] = max_element[1]
            direction[i,j] = max_element[2]
        end
    end
    i = rows
    j = cols
    aligned_v = []
    aligned_w = []
    while(i > 1 || j > 1)
        dir = direction[i,j]
        if dir == 1
            i = i-1
            j = j-1
            push!(aligned_v, v[i])
            push!(aligned_w, w[j])
        end
        if dir == 2
            i=i-1
            push!(aligned_v, v[i])
            push!(aligned_w, "-")
        end
        if dir == 3
            j = j-1
            push!(aligned_v, "-")
            push!(aligned_w, w[j])
        end
    end
    return (dp[rows,cols], join(reverse(aligned_v)), join(reverse(aligned_w)))
end

# convert the msa to tsp graph. Takes sequences and input and returns the distance matrix
function MSA_to_TSP(sequences)
    node = []
    for i in eachindex(sequences)
      push!(node,sequences[i])
    end
  
    graph = Array{Float64, 2}(undef, length(node), length(node))
    max_score = 0
    for i in eachindex(node)
      graph[i,i] = 0
      for j in i+1:length(node)
        score, align1, align2 = produce_global_alignment(node[i],node[j]) 
        graph[i,j] = score
        graph[j,i] = score
        if max_score < score 
          max_score = score
        end
      end
    end
    # convert score to distance, more the score lesser the distance
    for i in 1:length(node)
      for j in i+1:length(node)
        graph[i,j] = max_score - graph[i,j] + 1
        graph[j,i] = max_score - graph[j,i] + 1
      end
    end    
    return graph
  end
end

function find_gap_indices(A, alignedA)
    i = 1
    j = 1
    pointer = []
    while j <= length(alignedA)
        if alignedA[j] == '-' && (i > length(A) || A[i] != '-')
            push!(pointer, j)
            j += 1
        else
            j += 1
            i += 1
        end
    end
    return pointer
end

function insert_gaps(S,gap_indices_for_A)
    copy_of_S = S
    if length(gap_indices_for_A) > 0 && length(gap_indices_for_A) > 0
        gap_indices_for_A = sort(gap_indices_for_A)
        for i in gap_indices_for_A
            copy_of_S = string(string(copy_of_S[1:i-1],'-'),copy_of_S[i:end])
        end
    end
    return copy_of_S
end

# this function takes two params: sequences is the original array of input sequences, order is the array output of tsp algorithm of the order of sequences
# notice that the index in both the params are relative to each other
function align_output_sequences(sequences, order) 
    ordered_sequences = Array{String,1}(undef,0)
    for i in eachindex(order)
        push!(ordered_sequences,sequences[order[i]])
    end
    aligned_sequences = Array{String,1}(undef,0)
    for i=1:length(ordered_sequences)
        push!(aligned_sequences,ordered_sequences[i])
    end
    for i=1:length(aligned_sequences)-1
        A = aligned_sequences[i]
        B = aligned_sequences[i+1]
        score, alignedA, alignedB = produce_global_alignment(A,B)
        gap_indices_for_A = find_gap_indices(A, alignedA)
        # go to all predecessors of A and insert the gaps at same place
        for j = 1:i-1
            S = aligned_sequences[j]
            newly_alinged_S = insert_gaps(S,gap_indices_for_A)
            aligned_sequences[j] = newly_alinged_S
        end
        aligned_sequences[i] = alignedA
        aligned_sequences[i+1] = alignedB
    end  
    ordered_aligned_sequences = Array{String,1}(undef,length(order))
    for i in eachindex(order)
        ordered_aligned_sequences[order[i]] = aligned_sequences[i]
    end
    return ordered_aligned_sequences
end
