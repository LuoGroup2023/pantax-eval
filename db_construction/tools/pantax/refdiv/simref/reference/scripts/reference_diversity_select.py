

import sys
import pandas as pd

all_genomes_info_file = sys.argv[1]
sim_genomes_file = sys.argv[2]

sim_genomes = pd.read_csv(sim_genomes_file, sep="\t", header=None).iloc[:,0].tolist()

all_genomes_info = pd.read_csv(all_genomes_info_file, sep="\t")

all_grouped_species = all_genomes_info.groupby("species_taxid")["genome_ID"].apply(list).to_dict()

# first reference (perfect reference)
filtered_genomes_info = all_genomes_info[all_genomes_info["genome_ID"].isin(sim_genomes)]
filtered_genomes_info.to_csv("ref1_genomes.tsv", sep="\t", index=False)
exist_grouped_species = filtered_genomes_info.groupby("species_taxid")["genome_ID"].apply(list).to_dict()
# second reference
# ref2 and ref3
sim_genomes_add10 = sim_genomes.copy()
sim_genomes_add20 = sim_genomes.copy()

for species, genomes_list in exist_grouped_species.items():
    the_species_all_genomes = all_grouped_species[species]
    count = 0
    for genome in the_species_all_genomes:
        if genome not in genomes_list:
            if count < 10:
                sim_genomes_add10.append(genome)
            if count < 20:
                sim_genomes_add20.append(genome)
            count += 1
        if count >= 20: break

filtered_genomes_info_add10 = all_genomes_info[all_genomes_info["genome_ID"].isin(sim_genomes_add10)]
filtered_genomes_info_add20 = all_genomes_info[all_genomes_info["genome_ID"].isin(sim_genomes_add20)]
filtered_genomes_info_add10.to_csv("ref2_genomes.tsv", sep="\t", index=False)
filtered_genomes_info_add20.to_csv("ref3_genomes.tsv", sep="\t", index=False)

# ref4
for species, genomes_list in all_grouped_species.items():
    if species not in exist_grouped_species and len(genomes_list) >= 2:
        sim_genomes_add20.extend(genomes_list)

filtered_genomes_info_same_genus_diff_species = all_genomes_info[all_genomes_info["genome_ID"].isin(sim_genomes_add20)]
filtered_genomes_info_same_genus_diff_species.to_csv("ref4_genomes.tsv", sep="\t", index=False)

# ref5
all_genomes_info.to_csv("ref5_genomes.tsv", sep="\t", index=False)