module Scoring

export calc_sum_pair, calc_sum_pair_include_gap_penalty

# calculate the final score
function calc_sum_pair(sequences) 
    t = length(sequences)
    k = length(sequences[1])
    score = 0
    for i=1:t
        A = sequences[i]
        for j=i+1:t
            B = sequences[j]
            for idx = 1:k
                if A[idx] == B[idx] && A[idx] != '-'
                    score += 1
                end
            end
        end
    end
    return score
end

# calculate the final score to include gap penalty
function calc_sum_pair_include_gap_penalty(sequences) 
    t = length(sequences)
    k = length(sequences[1])
    score = 0
    for i=1:t
        A = sequences[i]
        for j=i+1:t
            B = sequences[j]
            for idx = 1:k
                # Add 1 for match
                if A[idx] == B[idx] && A[idx] != '-'
                    score += 1
                # subtract 1 for mismatch
                elseif A[idx] != B[idx] && A[idx] != '-' && B[idx] != '-'
                    score -= 1
                # subtract 1 for gap
                elseif A[idx] == '-' ||  B[idx] == '-' 
                    score -= 1
                end
            end
        end
    end
    return score
end

end