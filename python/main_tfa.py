from scoring import *
from parse_julia_output import parse_julia_output, print_msa
import os
import pandas as pd

if __name__ == '__main__':
    # Base directory for the aligned output files
    base_output_directory = "MSA/resources/bb3_aligned_tfa"

    # Base directory to save all the scores
    base_score_directory = "MSA/GATSO_scores_tfa"

    # List of subdirectories to process
    subdirectories = ["RV11", "RV12", "RV20", "RV40", "RV50"]

    # Iterate through each subdirectory
    for subdir in subdirectories:
        output_directory = os.path.join(base_output_directory, subdir)

        # Create a folder for the scores of the current subdirectory
        score_subdir = os.path.join(base_score_directory, subdir)
        os.makedirs(score_subdir, exist_ok=True)

        # Iterate through all files in the current output subdirectory
        for output_file in os.listdir(output_directory):
            # Check if the file is a TFA file
            if output_file.endswith(".tfa"):
                # Construct the full file path
                output_filename = os.path.join(output_directory, output_file)

                # Parse the aligned sequences from the output file
                sequences = parse_julia_output(output_filename)

                # Create an instance of the MSA class from the scoring module
                msa = MSA(sequences)

                # Calculate various scores
                entropy = Entropy(msa).compute()
                sum_of_pairs = SumOfPairs(msa, PAM250()).compute()
                star = Star(msa, PAM250()).compute()
                percentage_of_non_gaps = PercentageOfNonGaps(msa).compute()
                score_without_gap_penalty = calc_sum_pair(sequences)
                score_with_gap_penalty = calc_sum_pair_include_gap_penalty(sequences)

                # Create a dictionary to store the scores
                scores = {
                    "Entropy": entropy,
                    "SumOfPairs": sum_of_pairs,
                    "Star": star,
                    "PercentageOfNonGaps": percentage_of_non_gaps,
                    "ScoreWithoutGapPenalty": score_without_gap_penalty,
                    "ScoreWithGapPenalty": score_with_gap_penalty
                }

                # Create a DataFrame from the dictionary
                score_df = pd.DataFrame(scores, index=[0])

                # Get the base filename (without extension)
                base_filename = os.path.splitext(output_file)[0]

                # Save the scores in the subdirectory for the current RV
                score_csv_filename = os.path.join(score_subdir, f"{base_filename}_scores.csv")
                score_df.to_csv(score_csv_filename, index=False)

                score_txt_filename = os.path.join(score_subdir, f"{base_filename}_scores.txt")
                score_df.to_csv(score_txt_filename, index=False, sep='\t')

                # Print a message to indicate that the scores have been saved
                print(f"Scores for {output_file} saved as {score_csv_filename} and {score_txt_filename}")
