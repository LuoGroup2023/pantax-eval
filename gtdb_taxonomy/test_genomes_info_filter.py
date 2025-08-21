

import sys
import pandas as pd

def main():
    genomes_info_file = sys.argv[1]
    genome2strain_taxid_file = sys.argv[2]
    filter_genomes_info(genomes_info_file, genome2strain_taxid_file)

def filter_genomes_info(genomes_info_file, genome2strain_taxid_file):
    genomes_info = pd.read_csv(genomes_info_file, sep="\t", dtype=object)
    genome2strain_taxid = pd.read_csv(genome2strain_taxid_file, sep="\t", usecols=[2], dtype=object)
    filter_genomes_info = pd.merge(genomes_info, genome2strain_taxid, on="genome_ID")
    filter_genomes_info.to_csv("filter_genomes_info.txt", sep="\t", index=False)

if __name__ == "__main__":
    sys.exit(main())