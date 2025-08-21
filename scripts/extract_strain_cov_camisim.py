
"""
    extract strain coverage from camisim simulate log file.
"""
import sys

sequence_type = None
strain2coverage = dict()
with open(sys.argv[1], "r") as f:
    strain = None
    coverage = None
    record = False
    for line in f:
        if not sequence_type:
            if "ART_Illumina" in line:
                sequence_type = "short"
            elif "pbsim" in line:
                sequence_type = "long"
        if sequence_type == "short":
            if line.strip().startswith("Fold Coverage"):
                coverage = line.split(":")[1].strip().split("X")[0]

            if line.strip().startswith("the 1st reads"):
                strain = line.split(":")[1].strip().split("/")[-1].replace("1.fq", "")
        elif sequence_type == "long":
            if "Simulation parameters" in line:
                record = True
            if line.strip().startswith("prefix") and not strain and record:
                strain = line.split(":")[1].strip().split("/")[-1] 
            if line.strip().startswith("depth") and not coverage and record:
                coverage = line.split(":")[1].strip().split("X")[0]
                record = False
               
        if strain and coverage and strain not in strain2coverage:
            strain2coverage[strain] = coverage
            strain = None
            coverage = None

with open("sim_cov.tsv", "w") as f:
    for strain, coverage in strain2coverage.items():
        f.write(f"{strain}\t{coverage}\n")

