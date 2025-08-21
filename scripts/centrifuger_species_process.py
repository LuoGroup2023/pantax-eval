
import sys

report_file = sys.argv[1]

species2abund = {}

with open(report_file, "r") as f:
    for line in f:
        if line.strip().startswith("name"):
            continue
        tokens = line.strip().split("\t")
        if tokens[2] == "species":
            species2abund[tokens[1]] = float(tokens[6])
sorted_species2abund = dict(sorted(species2abund.items(), key=lambda item: item[1], reverse=True))

with open("species_abundance.txt", "w") as f_out:
    f_out.write("species_taxid\tpredicted_abundance\n")
    for key,value in sorted_species2abund.items():
        f_out.write(f"{key}\t{value}\n")

