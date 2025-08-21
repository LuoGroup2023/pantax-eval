import sys

def main():
    uniqsketch_strain_report = sys.argv[1]
    process(uniqsketch_strain_report)

def process(uniqsketch_strain_report):
    with open(uniqsketch_strain_report, "r") as f_in, open("strain_abundance.txt", "w") as f_out:
        f_out.write("strain_taxid\tabundance\n")
        next(f_in)
        for line in f_in:
            tokens = line.strip().split("\t")
            genome_name = tokens[0].replace("_genomic", "")
            abund = tokens[1]
            f_out.write(f"{genome_name}\t{abund}\n")


if __name__ == "__main__":
    sys.exit(main())