
"""
seqid mapping to species taxid
"""

import pandas as pd
import os, sys
import subprocess
import concurrent.futures

def main():
    genomes_info_file = sys.argv[1]
    genome2strain_taxid_file = sys.argv[2]
    prepare_bacteria_genomes_for_centrifuge(genomes_info_file)
    reference_strains = get_ref(genomes_info_file, genome2strain_taxid_file)
    parallel_map(reference_strains)

def prepare_bacteria_genomes_for_centrifuge(genomes_info_file):
    genomes = pd.read_csv(genomes_info_file, sep="\t",usecols=[4]).iloc[:,0].tolist()
    with open("input_genomes.txt", "w") as f:
        f.write("\n".join(genomes) + "\n")
    # subprocess.run("xargs cat < input_genomes.txt > reference_genomes.fna", shell=True)

def get_ref(genomes_info_file, genome2strain_taxid_file):
    genomes_info = pd.read_csv(genomes_info_file, sep="\t",usecols=[0,2,4],dtype=object)
    genome2strain_taxid = pd.read_csv(genome2strain_taxid_file, sep="\t", dtype=object)
    merged = pd.merge(genomes_info, genome2strain_taxid, on="genome_ID")
    taxid = merged["taxid"].tolist()
    id = merged["id"].tolist()
    reference_strains = list(zip(taxid, id))
    return reference_strains

def map_process(reference_strain):
    map_list = []
    with open(reference_strain[1], "r") as f:
        for line in f:
            if line.startswith(">"):
                seqID = line.split(" ", 1)[0][1:]
                map_list.append(f"{seqID}\t{reference_strain[0]}")
    return map_list

def parallel_map(reference_strains):
    result_list = []
    with concurrent.futures.ThreadPoolExecutor() as executor:
        results = executor.map(map_process, reference_strains)
    for result in results:
        result_list.extend(result)
    with open("seqid2taxid.map", "w") as f:
        for result in result_list:
            f.write(result + "\n")

if __name__ == "__main__":
    sys.exit(main())