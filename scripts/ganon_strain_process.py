
import sys
import pandas as pd
tax_profile_file = sys.argv[1]
if len(sys.argv) == 3:
    genomes_info_file = sys.argv[2]
else:
    genomes_info_file = None
if genomes_info_file and genomes_info_file != "-":
    genomesID = pd.read_csv(genomes_info_file, sep="\t")["genome_ID"].tolist()
else:
    genomesID = None
tax_profile_dict = {}
with open(tax_profile_file, "r") as f_in:
    for line in f_in:
        if line.strip().startswith("strain"):
            tokens = line.strip().split("\t")
            name = tokens[3][3:]
            # name_tokens = name.split("_")
            # idx = name_tokens.index("GCF")
            # genome_ID = "_".join(name_tokens[idx:])
            start = name.find("GCA")
            if start < 0:
                start = name.find("GCF")
            genome_ID = name[start:]
            abundance = float(tokens[8]) / 100
            if genomesID:
                if genome_ID in genomesID:
                    tax_profile_dict[genome_ID] = abundance
            else:
                tax_profile_dict[genome_ID] = abundance
if genomesID:
    abundance_sum = sum(list(tax_profile_dict.values()))
    for k,v in tax_profile_dict.items():
        tax_profile_dict[k] = v / abundance_sum
sorted_tax_profile_dict = dict(sorted(tax_profile_dict.items(), key=lambda item: item[1], reverse=True))
with open("strain_abundance.txt", "w") as f_out:          
    f_out.write("strain_taxid\tabundance\n")    
    for k,v in sorted_tax_profile_dict.items():
        f_out.write(f"{k}\t{v}\n")
        