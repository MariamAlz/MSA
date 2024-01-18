import os
import pandas as pd
from tabulate import tabulate
import matplotlib.pyplot as plt
import seaborn as sns

def read_scores_from_directory(directory):
    """Read all score files from a directory and return a DataFrame."""
    all_scores = []
    for file in os.listdir(directory):
        if file.endswith("_scores.csv"):
            filepath = os.path.join(directory, file)
            scores = pd.read_csv(filepath)
            scores['File'] = os.path.splitext(file)[0]
            all_scores.append(scores)
    return pd.concat(all_scores, ignore_index=True) if all_scores else pd.DataFrame()

if __name__ == '__main__':
    # Base directory for the score files
    base_score_directory = "MSA/GATSO_scores_tfa"

    # List of subdirectories to process
    subdirectories = ["RV11", "RV12", "RV20", "RV40", "RV50"]

    # Aggregate scores from all subdirectories
    aggregated_scores = []
    for subdir in subdirectories:
        score_directory = os.path.join(base_score_directory, subdir)
        df = read_scores_from_directory(score_directory)
        if not df.empty:
            df['RV'] = subdir  # Add a column for the RV category
            aggregated_scores.append(df)

    # Concatenate all DataFrames
    final_df = pd.concat(aggregated_scores, ignore_index=True) if aggregated_scores else pd.DataFrame()
    if not final_df.empty:
        # Select only numeric columns for mean calculation
        numeric_cols = final_df.select_dtypes(include=['number']).columns
        grouped_df = final_df.groupby('RV')[numeric_cols].mean()

        # Print the table
        print(tabulate(grouped_df, headers='keys', tablefmt='grid'))
    else:
        print("No score files found.")

    
    if not final_df.empty:
        # Select only numeric columns for visualization
        numeric_cols = final_df.select_dtypes(include=['number']).columns
        grouped_df = final_df.groupby('RV')[numeric_cols].mean()

        # Setting seaborn style
        sns.set(style="whitegrid")

        # Plotting and saving figures
        for col in numeric_cols:
            plt.figure(figsize=(10, 6))
            sns.barplot(x=grouped_df.index, y=grouped_df[col])
            plt.title(f'Average {col} Scores by RV')
            plt.ylabel(f'{col} Score')
            plt.xlabel('RV Category')
            plt.savefig(f'{col}_scores_by_RV.png')
            plt.close()
    else:
        print("No score files found.")

    if not final_df.empty:
        # Set seaborn style
        sns.set(style="whitegrid")

        # Preparing data for grouped bar plot
        plot_data = grouped_df.reset_index().melt(id_vars='RV', var_name='Score Type', value_name='Value')

        # Creating the grouped bar plot
        plt.figure(figsize=(15, 8))
        sns.barplot(x='RV', y='Value', hue='Score Type', data=plot_data)

        # Adding title and labels
        plt.title('Average Scores by RV and Score Type')
        plt.ylabel('Average Score')
        plt.xlabel('RV Category')

        # Saving the plot
        plt.savefig('combined_scores_plot.png')

        plt.show()
    else:
        print("No score files found.")