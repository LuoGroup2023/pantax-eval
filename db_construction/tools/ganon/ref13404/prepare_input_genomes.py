
import pandas as pd
import sys

def main():
    genomes_info_file = sys.argv[1]
    genome2strain_taxid_file = sys.argv[2]
    prepare_input_genomes(genomes_info_file, genome2strain_taxid_file)

def prepare_input_genomes(genomes_info_file, genome2strain_taxid_file):
    genomes_info = pd.read_csv(genomes_info_file, sep="\t", usecols=[0,4])
    genome2strain_taxid = pd.read_csv(genome2strain_taxid_file, sep="\t", usecols=[0,2])
    merged = pd.merge(genomes_info, genome2strain_taxid, on="genome_ID")
    merged = merged[["id", "genome_ID", "taxid"]]
    merged.to_csv("input_genomes.txt", sep="\t", index=False, header=None)

if __name__ == "__main__":
    sys.exit(main())

