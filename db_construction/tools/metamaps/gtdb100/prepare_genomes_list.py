

import sys
import pandas as pd
from pathlib import Path
import re

def main():
    genomes_info_file = sys.argv[1]
    taxa_info_file = sys.argv[2]
    out_genomes_dir = sys.argv[3]
    get_genomes_list(genomes_info_file, taxa_info_file, out_genomes_dir)

def get_genomes_list(genomes_info_file, taxa_info_file, out_genomes_dir):
    genomes_info = {}
    with open(genomes_info_file, "r") as f:
        next(f)
        for line in f:
            tokens = line.strip().split("\t")
            genome_ID = tokens[0]
            genome_id = tokens[4]
            # genome_id = Path(out_genomes_dir) / Path(genome_id).name.replace(".gz", "")
            genome_id = Path(out_genomes_dir) / Path(genome_id).name
            genome_id = re.sub(r'\.gz$', '', str(genome_id))
            genomes_info[genome_ID] = genome_id
    taxa_info = {}
    with open(taxa_info_file, "r") as f:
        next(f)
        for line in f:
            tokens = line.strip().split("\t")
            taxa = tokens[0][3:]
            start = taxa.find("GCF")
            if start < 0:
                start = taxa.find("GCA")
            genome_ID = taxa[start:]     
            species_taxid = tokens[1]
            taxa_info[genome_ID] = species_taxid
    assert len(genomes_info) == len(taxa_info)
    with open("genomes.txt", "w") as f:
        for genome_ID in genomes_info:
            f.write(f"{taxa_info[genome_ID]}\t{genomes_info[genome_ID]}\n")


if __name__  == "__main__":
    sys.exit(main())