import sys


def extract_species(metaphlan_format_report):
    taxid_to_abund ={}
    with open(metaphlan_format_report, "r") as f:
        for line in f:
            if line.startswith("#"):
                continue
            tokens = line.strip().split("\t")
            sample_id = tokens[0].split("|")
            taxid = tokens[1].split("|")
            abund = tokens[2]
            if len(sample_id) == 7 and sample_id[6].startswith("s"):
                # species_name = sample_id[6].replace("s__","").strip()
                taxid_to_abund[taxid[-1]] = float(abund)/100
    sorted_taxid_to_abund = dict(sorted(taxid_to_abund.items(), key=lambda item: item[1], reverse=True))
    return sorted_taxid_to_abund

def write(taxid_to_abund):
    with open("species_abundance.txt", "w") as f:
        f.write("species_taxid\tpredicted_abundance\n")
        for key,value in taxid_to_abund.items():
            f.write(f"{key}\t{value}\n")

def main():
    metaphlan_format_report = sys.argv[1]
    taxid_to_abund = extract_species(metaphlan_format_report)
    write(taxid_to_abund)

if __name__ == "__main__":
    sys.exit(main())
