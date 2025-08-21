
"""
prepare modification files (tree2tax.tsv, genomes_map.tsv) for each species. These files are used to add genomes as strain nodes in nodes.dump and names.dump.
"""

import sys
import pandas as pd
from pathlib import Path

def main():
    genomes_info_file = sys.argv[1]
    species_taxid2name_file = sys.argv[2]
    species = sys.argv[3]
    # print(species)
    output_dir = sys.argv[4]
    mode = sys.argv[5]
    if mode == "single":
        prepare_files(genomes_info_file, species_taxid2name_file, species, output_dir)
    elif mode == "multi":
        prepare_taxa_files(genomes_info_file, species_taxid2name_file, output_dir)

def prepare_taxa_files(genomes_info_file, species_taxid2name_file, output_dir):
    species2name = {}
    merged_species = {}
    with open(species_taxid2name_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            assert len(tokens) == 3
            scientific_name = tokens[2].split(";")
            ## if taxid was merged, taxid was different in columns 1 and columns2
            if tokens[0] != tokens[1]:
                merged_species[tokens[0]] = tokens[1]
            species = tokens[1]
            species_name = scientific_name[-1]  
            species2name[species] = species_name
    # print(merged_species)
    genomes_info = pd.read_csv(genomes_info_file, sep="\t")
    taxa_info = []
    for species, group in genomes_info.groupby("species_taxid"):
        genome_ID = group["genome_ID"].tolist()
        if str(species) not in species2name:
            species = merged_species[str(species)]
        species_name = species2name[str(species)]
        for genome_id in genome_ID:
            taxa = f"{species_name} {genome_id}".replace(" ", "_")
            taxa_info.append((taxa, str(species), "strain", "0"))
            # taxa_info.append((taxa, str(species)))
    taxa_info_df = pd.DataFrame(taxa_info)
    taxa_info_df.columns = ["taxa", "parent", "rank", "division"]
    # taxa_info_df.columns = ["taxa", "parent"]
    taxa_info_df.to_csv(Path(output_dir) / "taxa_info.tsv", index=False, sep="\t")
        

def prepare_files(genomes_info_file, species_taxid2name_file, species, output_dir):
    genome_ID = []
    with open(genomes_info_file, "r") as f:
        for line in f:
            if line.strip().startswith("genome_ID"):
                continue
            tokens = line.strip().split("\t")
            if tokens[2] == species:
                genome_ID.append(tokens[0].rsplit("_", 1)[0])

    with open(species_taxid2name_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            assert len(tokens) == 3
            if tokens[0] == species:
                scientific_name = tokens[2].split(";")
                species_name = scientific_name[-1]
            
    with open(f"{output_dir}/tree2tax.tsv", "w") as f:
        f.write("child\tparent\trank\n")
        for genome_id in genome_ID:
            child = f"{species_name} {genome_id}".replace(" ", "_")
            parent = species_name
            f.write(f"{child}\t{parent}\tstrain\n")
    with open(f"{output_dir}/genomes_map.tsv", "w") as f:
        for genome_id in genome_ID:
            child = f"{species_name} {genome_id}".replace(" ", "_")
            f.write(f"{genome_id}\t{child}\n")            
    print(species_name, end="")


if __name__ == "__main__":
    sys.exit(main())



