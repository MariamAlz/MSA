using Pkg
using PyCall

ENV["PYTHON"] = "scoring.py"
using Pkg
Pkg.build("PyCall")

# Import Python scoring module
py_scoring = pyimport("scoring")

# Create Python objects and call methods as needed
# Example: Create an instance of the MSA class from the scoring module
msa = py_scoring.MSA(["ACGTTGCA", "ACGTTCGA", "ACGTTGCG"])

# Example: Calculate the Entropy score
entropy = py_scoring.Entropy(msa)
entropy_score = entropy.compute()
println("Entropy score: $entropy_score")

# Example: Calculate the SumOfPairs score using PAM250
sum_of_pairs = py_scoring.SumOfPairs(msa, py_scoring.PAM250())
sum_of_pairs_score = sum_of_pairs.compute()
println("Sum of Pairs score: $sum_of_pairs_score")

# Example: Calculate the Star score
star = py_scoring.Star(msa, py_scoring.PAM250())
star_score = star.compute()
println("Star score: $star_score")

# Example: Calculate the Percentage of Non-Gaps
percentage_of_non_gaps = py_scoring.PercentageOfNonGaps(msa)
percentage_of_non_gaps_score = percentage_of_non_gaps.compute()
println("Percentage of Non-Gaps: $percentage_of_non_gaps_score")

# Example: Calculate the Percentage of Totally Conserved Columns
percentage_of_totally_conserved_columns = py_scoring.PercentageOfTotallyConservedColumns(msa)
percentage_of_totally_conserved_columns_score = percentage_of_totally_conserved_columns.compute()
println("Percentage of Totally Conserved Columns: $percentage_of_totally_conserved_columns_score")

