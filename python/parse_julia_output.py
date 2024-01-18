from msa import MSA

def parse_julia_output(filename):
    with open(filename, "r") as file:
        lines = file.readlines()

    sequences = []
    current_sequence = ""

    for line in lines:
        if line.startswith(">"):
            if current_sequence:
                sequences.append(current_sequence)
            current_sequence = ""
        else:
            current_sequence += line.strip()

    if current_sequence:
        sequences.append(current_sequence)

    return sequences

def format_sequence(sequence, gap_character='-'):
    return ''.join([c if c != gap_character else '-' for c in sequence])

def print_msa(sequences, ids):
    for i in range(len(sequences)):
        print(f">{ids[i]}\n{format_sequence(sequences[i])}\n")