
import sys
import pandas as pd

species_taxid2name_file = sys.argv[1]

species_taxid2name = pd.read_csv(species_taxid2name_file, sep="\t")
species_taxid2name.columns = ["query_species_taxid", "reference_species_taxid", "name"]
for index, row in species_taxid2name.iterrows():
    if row["query_species_taxid"] != row["reference_species_taxid"]:
        print(row)