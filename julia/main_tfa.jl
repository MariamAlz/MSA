include("alignment.jl")
include("genetic_algorithm.jl")
include("tuna_swarm_optimization.jl")
include("scoring.jl")
include("file_io.jl")

using .Alignment
using .GeneticAlgorithm
using .TunaSwarmOptimization
using .Scoring
using .FileIO

using Random
using Printf
using Dates
using Statistics
using Printf

# Modify the driver function to take filenames as arguments and return results
function driver(filename, output_filename, log_filename)
    # Existing code to load sequences and convert to TSP format
    input_sequences = get_sequences_from_file(filename)

      # Check if there's only one sequence
    if length(input_sequences) <= 1
        println("Only one sequence found in $filename. Skipping alignment.")
        return nothing
    end

    input_distance_matrix = MSA_to_TSP(input_sequences)

    # Parameters for GA
    pop_size = 100
    num_generations = 50

    # Run GA
    ga_solution = genetic_algorithm(length(input_sequences), input_distance_matrix, pop_size, num_generations)

    # Further optimization with TSA
    num_tunas = max(100, 3 * length(input_sequences))
    iterations = 20
    tsa_solution = etso_main(num_tunas, length(input_sequences), input_distance_matrix, iterations, ga_solution)

    # Align output sequences in the order identified by above algorithm
    aligned_sequences = align_output_sequences(input_sequences, tsa_solution)

    # Get the score of the aligned sequences
    final_score = calc_sum_pair(aligned_sequences)

    # Save the output in fasta format in output1.txt
    write_to_file(output_filename, aligned_sequences)

    # Log the results to a log file
    log_results(log_filename, final_score, ga_solution, tsa_solution)

    # Print the aligned sequences and final score
    println("Score of aligned sequences = ", final_score)
    println("The aligned sequences are saved in ", output_filename)
    for i in eachindex(aligned_sequences)
        println(aligned_sequences[i])
    end

    # Return final_score, aligned_sequences, and any other relevant results
    return final_score, aligned_sequences
end

function log_results(log_filename, final_score, ga_solution, tsa_solution)
    # Open the log file in append mode
    log_file = open(log_filename, "a")

    # Log the final score
    write(log_file, "Final Score: $final_score\n")

    # Log GA solution
    write(log_file, "GA Solution: $(join(ga_solution, " "))\n")

    # Log TSA solution
    write(log_file, "TSA Solution: $(join(tsa_solution, " "))\n")

    # Close the log file
    close(log_file)
end

# Base directory for input files
base_input_directory = "MSA/resources/bb3_release"

# Base directory where output files will be saved
base_output_directory = "MSA/resources/bb3_aligned_tfa"

# List of subdirectories to process
subdirectories = ["RV11", "RV12", "RV20", "RV40", "RV50"]

# Iterate through each subdirectory
for subdir in subdirectories
    # Construct the full path of the current input subdirectory
    input_directory = joinpath(base_input_directory, subdir)

    # Construct the full path of the corresponding output subdirectory
    output_directory = joinpath(base_output_directory, subdir)

    # Create the output subdirectory if it doesn't exist
    mkpath(output_directory)

    # Iterate through all files in the current input subdirectory
    for input_file in readdir(input_directory)
        # Check if the file is a TFA file
        if endswith(input_file, ".tfa")
            # Construct full file paths
            input_path = joinpath(input_directory, input_file)
            output_file = replace(input_file, ".tfa" => "_aligned.tfa")
            output_path = joinpath(output_directory, output_file)
            log_path = joinpath("MSA/txt", "log.txt")

            # Check if the output file already exists
            if isfile(output_path)
                println("Output for $input_file in $subdir already exists. Skipping.")
                continue
            end

            # Call the driver function for the current file
            result = driver(input_path, output_path, log_path)

            # Check if the result is 'nothing', which indicates only one sequence was found
            if result === nothing
                println("Skipped $input_file in $subdir due to only one sequence.")
            else
                # Extract final_score and aligned_sequences from the result
                final_score, aligned_sequences = result

                # Print a message indicating completion for this file
                println("Processed $input_file in $subdir. Final Score: $final_score")
            end
        end
    end
end
