import sys
import pandas as pd

distribution_file = sys.argv[1]
cluster_file = sys.argv[2]
tool = sys.argv[3]


if tool == "pantax":
    ref_genomes = pd.read_csv("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/hclsMap_Rep.txt", header=None, sep="\t").iloc[:,2].tolist()
    ref_genomes = [genome.replace("_genomic.fna", "") for genome in ref_genomes]
    ref2genomes = {}
    i = 0
    with open(cluster_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            genomes = tokens[-1].split(",")
            genomes = [genome.replace("_genomic.fna", "") for genome in genomes]
            ref = ref_genomes[i]
            for genome in genomes:
                ref2genomes[genome] = ref
            i += 1

elif tool == "strainscan":
    pass
elif tool == "straingst":
    ref2genomes = {}
    with open(cluster_file, "r") as f:
        for line in f:
            genomes = line.strip().split("\t")
            ref = genomes[0]
            for genome in genomes:
                ref2genomes[genome] = ref
elif tool == "strainest":
    ref2genomes = {}
    with open(cluster_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            tokens = [genome.replace("_genomic.fna", "") for genome in tokens]
            genome = tokens[0]
            ref = tokens[1] 
            ref2genomes[genome] = ref  

distribution = pd.read_csv(distribution_file, header=None, sep="\t")
distribution.columns = ["genomeID", "abundance"]
distribution["genomeID"] = distribution["genomeID"].replace(ref2genomes)
distribution.to_csv("distribution.txt", header=None, index=False, sep="\t")