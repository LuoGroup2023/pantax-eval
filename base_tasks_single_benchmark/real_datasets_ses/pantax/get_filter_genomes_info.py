
import sys
import pandas as pd

hcls_file = sys.argv[1]
strain_abund_file = sys.argv[2]
genomes_info_all = sys.argv[3]

strain_abund = pd.read_csv(strain_abund_file, sep="\t")
represent_genomes = strain_abund["genome_ID"].tolist()
        
genome_cluster = []
with open(hcls_file, "r") as f:
    for line in f:
        tokens = line.strip().split("\t")
        genomes = tokens[2].split(",")
        genomes = [genome.replace("_genomic.fna", "") for genome in genomes]
        for genome in represent_genomes:
            if genome in genomes:
                genome_cluster.extend(genomes)

genomes_info = pd.read_csv(genomes_info_all, sep="\t")
filtered_genomes_info = genomes_info[genomes_info["genome_ID"].isin(genome_cluster)]
print(len(filtered_genomes_info))
filtered_genomes_info.to_csv("filtered_genomes_info.txt", sep="\t", index=False)
