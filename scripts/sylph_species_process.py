
import sys
import pandas as pd

strain_abund_file = sys.argv[1]
genomes_info_file = sys.argv[2]

strain_abund = pd.read_csv(strain_abund_file, sep="\t")
genomes_info = pd.read_csv(genomes_info_file, sep="\t", dtype=object)

strain_abund.columns = ["genome_ID", "abund"]
merged_df = pd.merge(genomes_info, strain_abund)

selected_merged_df = merged_df.iloc[:, [2, 5]]

result = selected_merged_df.groupby('species_taxid', as_index=False)['abund'].sum().sort_values(by='abund', ascending=False)

result.to_csv("species_abundance.txt", index=False, sep="\t")
