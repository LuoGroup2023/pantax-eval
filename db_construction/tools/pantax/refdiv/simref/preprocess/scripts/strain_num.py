
import sys
import pandas as pd

genomes_info = pd.read_csv(sys.argv[1], sep="\t", dtype=object)

species = pd.read_csv(sys.argv[2], sep="\t", header=None, dtype=object).iloc[:,0].tolist()

filtered_df = genomes_info[genomes_info['species_taxid'].isin(species)]

counts = filtered_df.groupby('species_taxid').size().reset_index(name='count')
counts.to_csv('species_counts.csv', index=False)
print(counts)

filtered_counts = counts[counts['count'] > 50]
# print(filtered_counts)

total_count = counts['count'].sum()
print("total count:", total_count)