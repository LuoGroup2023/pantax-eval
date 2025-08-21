
import sys

strain2abund = {}
total_abund = 0
with open(sys.argv[1], "r") as f_in:
    for line in f_in:
        tokens = line.strip().split(" : ")
        strain_genome = tokens[0].split("|")[2]
        strain2abund[strain_genome] = float(tokens[1])
        total_abund += float(tokens[1])

with open("madre_abund.txt", "w") as f_out:
    f_out.write("genome_ID\tpredicted_abundance\n")
    for strain_genome, abund in strain2abund.items():
        _abund = abund / total_abund
        f_out.write(f"{strain_genome}\t{_abund}\n")