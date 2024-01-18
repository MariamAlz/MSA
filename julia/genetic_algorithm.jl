module GeneticAlgorithm

export initialize_ga_population, evaluate_population_fitness, select_parents, crossover, mutate, genetic_algorithm

include("tuna_swarm_optimization.jl")

using Random
using .TunaSwarmOptimization

# Function to initialize the GA population
function initialize_ga_population(pop_size, num_sequences)
    population = [randperm(num_sequences) for _ in 1:pop_size]
    return population
end

# Function to calculate fitness for each individual in the population
function evaluate_population_fitness(population, distance_matrix)
    fitnesses = [calculate_alignment_fitness(individual, distance_matrix) for individual in population]
    return fitnesses
end

function select_parents(population, fitnesses)
    tournament_size = 3  # You can adjust this size
    selected_parents = []

    for _ in 1:2  # Selecting two parents
        contenders = rand(1:length(population), tournament_size)
        best = contenders[1]
        for i in contenders
            if fitnesses[i] > fitnesses[best]
                best = i
            end
        end
        push!(selected_parents, population[best])
    end

    return selected_parents
end

function crossover(parent1, parent2)
    len = length(parent1)
    cxpoint1 = rand(1:len-1)
    cxpoint2 = rand(cxpoint1+1:len)
    
    child1 = copy(parent1)
    child2 = copy(parent2)
    
    for i in cxpoint1:cxpoint2
        val1, val2 = child1[i], child2[i]
        pos1, pos2 = findfirst(isequal(val2), child1), findfirst(isequal(val1), child2)
        child1[i], child1[pos1] = child1[pos1], child1[i]
        child2[i], child2[pos2] = child2[pos2], child2[i]
    end

    return child1, child2
end

function mutate(individual)
    mutation_rate = 0.05  # Adjust mutation rate as needed
    len = length(individual)

    for i in 1:len
        if rand() < mutation_rate
            j = rand(1:len)
            individual[i], individual[j] = individual[j], individual[i]
        end
    end

    return individual
end

# Find the best individual in the population
function find_best_individual(population, distance_matrix)
    best_fitness = -Inf
    best_individual = nothing
    for individual in population
        fitness = calculate_alignment_fitness(individual, distance_matrix)
        if fitness > best_fitness
            best_fitness = fitness
            best_individual = individual
        end
    end
    return best_individual
end

# Main GA loop
function genetic_algorithm(num_sequences, distance_matrix, pop_size, num_generations)
    population = initialize_ga_population(pop_size, num_sequences)
    for generation in 1:num_generations
        fitnesses = evaluate_population_fitness(population, distance_matrix)
        new_population = []
        while length(new_population) < pop_size
            parent1, parent2 = select_parents(population, fitnesses)
            offspring1, offspring2 = crossover(parent1, parent2)
            push!(new_population, mutate(offspring1))
            push!(new_population, mutate(offspring2))
        end
        population = new_population
    end
    return find_best_individual(population, distance_matrix)
end

end
