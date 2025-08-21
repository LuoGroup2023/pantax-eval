
import sys
import pandas as pd
centrifuger_report_file = sys.argv[1]
if len(sys.argv) == 3:
    genomes_info_file = sys.argv[2]
    if genomes_info_file == "-":
        genomes_info_file = None
else:
    genomes_info_file = None
if genomes_info_file:
    genomesID = pd.read_csv(genomes_info_file, sep="\t")["genome_ID"].tolist()
else:
    genomesID = None
count = 0
# with open(centrifuger_report_file, "r") as f, open("strain_abundance.txt", "w") as f_out:
#     f_out.write("strain_taxid\tabundance\n")
#     for line in f:
#         if line.strip().startswith("name"):
#             continue
#         tokens = line.strip().split("\t")
#         if tokens[2] == "strain":
#             name = tokens[0]
#             name_tokens = name.split("_")
#             try:
#                 idx = name_tokens.index("GCF")
#             except:
#                 count += 1
#                 continue
#             genome_ID = "_".join(name_tokens[idx:])
#             abundance = tokens[6]
#             f_out.write(f"{genome_ID}\t{abundance}\n")
abundance_list = []
with open(centrifuger_report_file, "r") as f:
    for line in f:
        if line.strip().startswith("name"):
            continue
        tokens = line.strip().split("\t")
        if tokens[2] == "strain":
            name = tokens[0][3:]
            # name_tokens = name.split("_")
            try:
                start = name.find("GCA")
                if start < 0:
                    start = name.find("GCF")
            except:
                count += 1
                continue
            # genome_ID = "_".join(name_tokens[idx:])
            genome_ID = name[start:]
            abundance = tokens[6]
            if genomesID:
                if genome_ID in genomesID:
                    abundance_list.append((genome_ID, float(abundance)))
            else:
                abundance_list.append((genome_ID, abundance))
abundance_df = pd.DataFrame(abundance_list)
abundance_df.columns = ["strain_taxid", "abundance"]
if genomes_info_file:
    abundance_df["abundance"] = abundance_df["abundance"] / abundance_df["abundance"].sum()
abundance_df.to_csv("strain_abundance.txt", sep="\t", index=False)
print(f"multi strains:{count}")

