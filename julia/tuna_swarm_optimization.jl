module TunaSwarmOptimization

export initialize_tuna_swarm, calculate_alignment_fitness, evaluate_swarm_fitness, update_tuna_positions, find_best_swarm_solution, best_solution_order, etso_main, initialize_tuna_swarm_with_ga

using Random

# Function to initialize the tuna swarm
function initialize_tuna_swarm(num_tunas, num_sequences)
    swarm = Array{Any}(undef, num_tunas)
    for i in 1:num_tunas
        position = randperm(num_sequences)
        swarm[i] = Dict("position" => position, "fitness" => 0.0)
    end
    return swarm
end

# Function to calculate alignment fitness
function calculate_alignment_fitness(position, distance_matrix)
    fitness = 0.0
    for i in 1:length(position)-1
        for j in i+1:length(position)
            fitness += distance_matrix[position[i], position[j]]
        end
    end
    return fitness
end

# Function to evaluate the fitness of each tuna in the swarm
function evaluate_swarm_fitness(swarm, distance_matrix)
    for tuna in swarm
        position = tuna["position"]
        fitness = calculate_alignment_fitness(position, distance_matrix)
        tuna["fitness"] = fitness
    end
end

# Function to update positions of tunas in the swarm
function update_tuna_positions(swarm, global_best, distance_matrix)
    for tuna in swarm
        current_position = tuna["position"]
        new_position = deepcopy(current_position)
        for i in eachindex(new_position)
            if rand() < 0.5
                j = rand(1:length(new_position))
                new_position[i], new_position[j] = new_position[j], new_position[i]
            end
        end

        new_fitness = calculate_alignment_fitness(new_position, distance_matrix)
        if new_fitness > tuna["fitness"]
            tuna["position"] = new_position
            tuna["fitness"] = new_fitness
        end
    end
end

# Function to find the best solution in the swarm
function find_best_swarm_solution(swarm)
    best_solution = swarm[1]
    for tuna in swarm
        if tuna["fitness"] > best_solution["fitness"]
            best_solution = tuna
        end
    end
    return best_solution
end

# Function to get the best solution order from the best solution
function best_solution_order(best_solution)
    return best_solution["position"]
end

# Implementing the Enhanced Tuna Swarm Optimization (ETSO) with GA initialization
function etso_main(num_tunas, num_sequences, distance_matrix, iterations, initial_solution)
    # Initialize the tuna swarm with the GA's best solution as a reference
    swarm = initialize_tuna_swarm_with_ga(num_tunas, num_sequences, initial_solution, distance_matrix)

    # Set the global best to the GA's solution
    global_best = Dict("position" => initial_solution, "fitness" => calculate_alignment_fitness(initial_solution, distance_matrix))

    for i in 1:iterations
        evaluate_swarm_fitness(swarm, distance_matrix)

        current_best = find_best_swarm_solution(swarm)
        if current_best["fitness"] > global_best["fitness"]
            global_best = deepcopy(current_best)
        end

        update_tuna_positions(swarm, global_best, distance_matrix)
    end

    return best_solution_order(global_best)
end

# Initialize the tuna swarm with the GA's best solution
function initialize_tuna_swarm_with_ga(num_tunas, num_sequences, ga_solution, distance_matrix)
    swarm = Array{Any}(undef, num_tunas)
    
    # Initialize the first tuna with the GA solution
    swarm[1] = Dict("position" => ga_solution, "fitness" => calculate_alignment_fitness(ga_solution, distance_matrix))

    # Initialize the rest of the swarm
    for i in 2:num_tunas
        position = randperm(num_sequences)
        swarm[i] = Dict("position" => position, "fitness" => calculate_alignment_fitness(position, distance_matrix))
    end

    return swarm
end

end
