import shutil
import os
dir = "1282"
if not os.path.exists(dir):
    os.mkdir(dir)
with open("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/1282.txt", "r") as f:
    genomes = f.read().strip().split("\n")
for genome in genomes:
    shutil.copy(genome, dir)