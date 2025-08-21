import sys
from pathlib import Path
script_path = Path(__file__).resolve()
script_dir = script_path.parent
file_a_path = sys.argv[1]
# file_b_path = Path(script_dir) / 'data/fna_seqID_taxid.txt'
file_b_path = sys.argv[2]
output_file_path = 'strain_classification.csv'

file_b_dict = {}
with open(file_b_path, 'r') as file_b:
    for line in file_b:
        elements_b = line.strip().split()
        file_b_dict[elements_b[3]] = elements_b[:3]

with open(file_a_path, 'r') as file_a, open(output_file_path, 'w') as output_file:
    file_a.readline()
    for line in file_a:    
        elements_a = line.strip().split()
        second_column_value_a = elements_a[1]

        if second_column_value_a in file_b_dict:
            appended_elements_b = '\t'.join(file_b_dict[second_column_value_a])
            output_line = f"{elements_a[0]}\t{elements_a[1]}\t{appended_elements_b}\n"
        else:
            output_line = f"{elements_a[0]}\t{elements_a[1]}\t0\t0\t0\n"  # Assuming default values for non-matching cases

        output_file.write(output_line)

print("Finish")