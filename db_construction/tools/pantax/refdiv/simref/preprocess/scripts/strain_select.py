

import pandas as pd
import sys

data = pd.read_csv(sys.argv[1], sep="\t")
grouped = data.groupby('species_taxid').filter(lambda x: len(x) > 5)

num_groups = grouped['species_taxid'].nunique()

print(f"species number: {num_groups}")

grouped.to_csv('genomes_info.tsv', index=False, sep="\t")
