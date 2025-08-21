
import sys
import pandas as pd

genomes_info_file = sys.argv[1]
tax2genome_file = sys.argv[2]
designated_species = sys.argv[3]

genomes_info = pd.read_csv(genomes_info_file, sep="\t", usecols=[0,2], dtype=object)
tax2genome = pd.read_csv(tax2genome_file, sep="\t")
merged = pd.merge(tax2genome,genomes_info)

assert len(merged) == len(genomes_info) == len(tax2genome)

designated_species_merged = merged[merged["species_taxid"]==designated_species]
designated_species_merged = designated_species_merged.drop(columns=["species_taxid"])

designated_species_merged.to_csv(f"kraken2_strain_taxid_{designated_species}.tsv", sep="\t", index=False)