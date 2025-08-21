
"""
    Obtain multi zymo1 reference.
"""
import sys
import pandas as pd

all_genomes_info = pd.read_csv(sys.argv[1], sep="\t")
ground_truth_genomes = pd.read_csv(sys.argv[2], sep="\t", header=None).iloc[:,0].tolist()

all_grouped_species = all_genomes_info.groupby("species_taxid")["genome_ID"].apply(list).to_dict()

ground_truth_genomes1 = ground_truth_genomes.copy()
ground_truth_genomes2 = ground_truth_genomes.copy()

for species, genomes_list in all_grouped_species.items():
    if len(genomes_list) <= 10: continue
    add_count = 0
    add_count_limit1 = len(genomes_list) / 3
    add_count_limit2 = len(genomes_list) * 2 / 3
    for genome in genomes_list:
        if genome not in ground_truth_genomes:
            if add_count <= add_count_limit1:
                ground_truth_genomes1.append(genome)
            if add_count <= add_count_limit2:
                ground_truth_genomes2.append(genome)
            add_count += 1
        if add_count > add_count_limit2: break

filtered_genomes_info_add1 = all_genomes_info[all_genomes_info["genome_ID"].isin(ground_truth_genomes1)]
filtered_genomes_info_add2 = all_genomes_info[all_genomes_info["genome_ID"].isin(ground_truth_genomes2)]
filtered_genomes_info_add1.to_csv("ref1_genomes.tsv", sep="\t", index=False)
filtered_genomes_info_add2.to_csv("ref2_genomes.tsv", sep="\t", index=False)




