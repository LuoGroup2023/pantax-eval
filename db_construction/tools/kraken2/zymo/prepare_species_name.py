


"""
prepare species scientific name from genomes_info file
"""


import sys, subprocess
from pathlib import Path

def main():
    genomes_info_file = sys.argv[1]
    output_dir = sys.argv[2]
    prepare_species_scientific_name(genomes_info_file, output_dir)


def prepare_species_scientific_name(genomes_info_file, output_dir):
    output_file_path = Path(output_dir) / "species_taxid2name.tsv"
    species_taxid2name = {}
    with open(genomes_info_file, "r") as f_in:
        for line in f_in:
            if line.strip().startswith("genome_ID"):
                continue
            tokens = line.strip().split("\t")
            species_taxid = tokens[2]
            if species_taxid not in species_taxid2name:
                result = subprocess.run(f"echo {species_taxid} | taxonkit lineage", shell=True, text=True, capture_output=True)
                taxid_info = result.stdout.strip().split("\t")
                assert len(taxid_info) == 2
                scientific_name = taxid_info[1].split(";")
                species_scientific_name = scientific_name[-1]
                species_taxid2name[species_taxid] = species_scientific_name
    with open(f"{output_file_path}", "w") as f_out:
        f_out.write("species_taxid\tname\n")
        for species_taxid, species_scientific_name in species_taxid2name.items():
            f_out.write(f"{species_taxid}\t{species_scientific_name}\n")


if __name__ == "__main__":
    sys.exit(main())