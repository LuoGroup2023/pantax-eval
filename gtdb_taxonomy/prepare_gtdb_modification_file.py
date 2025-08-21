
import sys, subprocess
import pandas as pd


def main():
    gtdb_taxonomy_file = sys.argv[1]
    genomes_info_file = sys.argv[2]
    if len(sys.argv) == 4:
        taxonomy_dir = sys.argv[3]
    else:
        taxonomy_dir = "./"
    prepare_taxa_file(gtdb_taxonomy_file, genomes_info_file, taxonomy_dir)


def prepare_taxa_file(gtdb_taxonomy_file, genomes_info_file, taxonomy_dir):
    genomes_info = pd.read_csv(genomes_info_file, sep="\t")
    all_genomes = set(genomes_info["genome_ID"].tolist())
    taxa = []
    with open(gtdb_taxonomy_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            name = tokens[0].split('_', 1)[-1]
            taxonomy = tokens[1]
            species = taxonomy.split(";")[-1].replace("s__", "")
            if name in all_genomes:
                taxa.append((name, species))
    strings = []
    for _taxa in taxa:
        species_taxid = query_species(_taxa[1], taxonomy_dir)
        name = _taxa[1].replace(" ", "_") + "_" + _taxa[0]
        strings.append(f"{name}\t{species_taxid}\tstrain\t0")
    with open("taxa_info.tsv", "w") as f:
        f.write("taxa\tparent\trank\tdivision\n")
        f.write("\n".join(strings) + "\n")

def query_species(species, taxonomy_dir):
    result = subprocess.run(f"echo {species} | taxonkit name2taxid --data-dir {taxonomy_dir}", shell=True, capture_output=True, text=True)
    return result.stdout.strip().split("\t")[1]

if __name__ == "__main__":
    sys.exit(main())
