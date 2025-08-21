import pandas as pd
import os
import subprocess
import concurrent.futures
import sys,gzip


def get_ref(genomes_info_file):
    genomes_info = pd.read_csv(genomes_info_file, sep="\t",usecols=[0,4],dtype=object)
    genome_ID = genomes_info.iloc[:,0].tolist()
    id = genomes_info.iloc[:,1].tolist()
    reference_strains = list(zip(genome_ID, id))
    return reference_strains

def open_file(file_path):
    if file_path.endswith(".gz"):
        return gzip.open(file_path, "rt")
    else:
        return open(file_path, "r")

def map_process(reference_strain):
    map_list = []
    with open_file(reference_strain[1]) as f:
        for line in f:
            if line.startswith(">"):
                seqID = line.split(" ", 1)[0][1:]
                map_list.append(f"{seqID}\tN\tN\t{reference_strain[0]}")
    return map_list

def parallel_map(reference_strains, output):
    result_list = []
    with concurrent.futures.ThreadPoolExecutor() as executor:
        results = executor.map(map_process, reference_strains)
    for result in results:
        result_list.extend(result)
    with open(f"{output}_fna_seqID_taxid.txt", "w") as f:
        for result in result_list:
            f.write(result + "\n")

if __name__ == "__main__":
    genomes_info_file = sys.argv[1]
    output = sys.argv[2]
    reference_strains = get_ref(genomes_info_file)
    parallel_map(reference_strains, output)            