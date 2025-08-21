import os
import shutil
import argparse

VERSION = 0.1
new_name_unique=""
new_name_class = 'scientific name'
inherited_div_flag = '1'
genetic_code_id = '1'
inherited_GC_flag = '1'
mito_gen_code_id = '1'
inherited_MGC_flag = '1'
gb_hidden_flag = '1'
hidden_subtree_root_flag = '1'
embl_code = ''
comments = ''

def help_message(verbose=False):
    divisions = {
        "0": "Bacteria", "1": "Invertebrates", "2": "Mammals", "3": "Phages",
        "4": "Plants and Fungi", "5": "Primates", "6": "Rodents", "7": "Synthetic and Chimeric",
        "8": "Unassigned - Do Not Use", "9": "Viruses", "10": "Vertebrates", "11": "Environmental Samples"
    }
    genetic_codes = {
        "0": "Unspecified", "1": "Standard", "2": "Vertebrate Mitochondrial", 
        "3": "Yeast Mitochondrial", "4": "Mold Mitochondrial", "5": "Invertebrate Mitochondrial",
        "6": "Ciliate Nuclear", "9": "Echinoderm Mitochondrial", "10": "Euplotid Nuclear",
        "11": "Bacterial, Archaeal and Plant Plastid", "12": "Alternative Yeast Nuclear"
    }
    name_classes = ["Acronym", "Anamorph", "Authority", "Blast Name", "Common Name", "Equivalent Name", 
                    "Genbank Acronym", "Genbank Anamorph", "Genbank Common Name", "Genbank Synonym",
                    "Includes", "In-part", "Misnomer", "Misspelling", "Scientific Name", "Synonym",
                    "Teleomorph", "Type Material"]
    taxonomic_ranks = [
        "no rank", "superkingdom", "kingdom", "subkingdom", "superphylum", "phylum",
        "subphylum", "superclass", "class", "subclass", "infraclass", "cohort", "superorder",
        "order", "suborder", "infraorder", "parvorder", "superfamily", "family", "subfamily",
        "tribe", "subtribe", "genus", "subgenus", "species group", "species", "species subgroup",
        "subspecies", "varietas", "forma"
    ]
    if verbose:
        print("Divisions:", divisions)
        print("Genetic Codes:", genetic_codes)
        print("Name Classes:", name_classes)
        print("Taxonomic Ranks:", taxonomic_ranks)

def get_largest_tax_id(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
        if lines:
            last_line = lines[-1]
            return int(last_line.split("\t")[0].strip())
    return 0

def process_files(input_files, nodes, names, output_file, override=None):
    largest_taxid = get_largest_tax_id(nodes)

    if override:
        new_taxid = override
    else:
        new_taxid = largest_taxid + (10 ** (len(str(largest_taxid)) - 1))

    nodes_backup = f"{os.path.splitext(nodes)[0]}_backup.dmp"
    names_backup = f"{os.path.splitext(names)[0]}_backup.dmp"
    shutil.copy(nodes, nodes_backup)
    shutil.copy(names, names_backup)
    print(f"Backups created: {nodes_backup} and {names_backup}")

    with open(nodes, 'a') as nodes_file, open(names, 'a') as names_file, open(output_file, 'w') as out_file:
        out_file.write("taxid\ttaxa\tgenome_ID\n")
        for input_file in input_files:
            with open(input_file, 'r') as file:
                for line in file:
                    # extract parent, rank, division columns
                    tokens = line.strip().split()
                    if line.strip().startswith("taxa"):
                        continue
                    
                    taxa = tokens[0]
                    parent_tax_id = tokens[1]
                    if len(tokens) > 3:
                        rank = tokens[2]
                        division_id = tokens[3]
                    else:
                        rank = "strain"
                        division_id = "0"
                    # names.dmp
                    names_file.write(f"{new_taxid}\t|\t{taxa}\t|\t\t|\t{new_name_class}\t|\n")
                    
                    # nodes.dmp
                    nodes_file.write(
                        f"{new_taxid}\t|\t{parent_tax_id}\t|\t{rank}\t|\t{embl_code}\t|\t{division_id}\t|\t"
                        f"{inherited_div_flag}\t|\t{genetic_code_id}\t|\t{inherited_GC_flag}\t|\t"
                        f"{mito_gen_code_id}\t|\t{inherited_MGC_flag}\t|\t{gb_hidden_flag}\t|\t"
                        f"{hidden_subtree_root_flag}\t|\t{comments}\n"
                    )
                    taxa_tokens = taxa.split("_")
                    idx = taxa_tokens.index("GCF")
                    genome_id = "_".join(taxa_tokens[idx:])
                    out_file.write(f"{new_taxid}\t{taxa}\t{genome_id}\n")
                    print(f"Processed {new_taxid} for parent: {parent_tax_id}, rank: {rank}, division: {division_id}")
                    
                    new_taxid += 1

    print("All files processed successfully.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process files and generate new TaxIDs.")
    parser.add_argument('--nodes', required=True, help="Path to nodes.dmp")
    parser.add_argument('--names', required=True, help="Path to names.dmp")
    parser.add_argument('--output', required=True, help="Output file to save generated TaxIDs")
    parser.add_argument('--override', type=int, help="Override TaxID start value")
    parser.add_argument('input_files', nargs='+', help="List of input files to process")

    args = parser.parse_args()
    process_files(args.input_files, args.nodes, args.names, args.output, args.override)