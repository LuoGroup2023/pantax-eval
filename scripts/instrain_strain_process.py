

import sys
import pandas as pd

instrain_profile_file = sys.argv[1]
if len(sys.argv) == 3:
    genomes_info_file = sys.argv[2]
else:
    genomes_info_file = None
if genomes_info_file and genomes_info_file != "-":
    genomesID = pd.read_csv(genomes_info_file, sep="\t", usecols=[0])
    genomesID.columns = ["strain_taxid"]
else:
    genomesID = None
instrain_profile = pd.read_csv(instrain_profile_file, sep="\t", usecols=[0,1])
instrain_profile.columns = ["strain_taxid", "abundance"]
instrain_profile["strain_taxid"] = instrain_profile["strain_taxid"].str.replace("_genomic.fna", "")
instrain_profile["abundance"] = instrain_profile["abundance"] / instrain_profile["abundance"].sum()
if isinstance(genomesID, pd.DataFrame) and not genomesID.empty:
    instrain_profile = pd.merge(instrain_profile, genomesID)
    instrain_profile["abundance"] = instrain_profile["abundance"] / instrain_profile["abundance"].sum()
instrain_profile_sorted = instrain_profile.sort_values(by="abundance", ascending=False)
instrain_profile_sorted.to_csv("strain_abundance.txt", sep="\t", index=False)


