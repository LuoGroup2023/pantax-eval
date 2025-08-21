

"""
prepare genome for kraken database construction.
"""

import concurrent.futures
import sys, subprocess
import pandas as pd
from pathlib import Path

def main():
    genomes_info = sys.argv[1]
    wd = sys.argv[2]
    if len(sys.argv) > 3:
        strain_taxid = sys.argv[3]
    else:
        strain_taxid = None
    reference_genomes = get_ref(genomes_info, strain_taxid)
    # fa_format_process((reference_genomes[0], wd))
    parallel(reference_genomes, wd)

def get_ref(genomes_info, strain_taxid_file):
    reference_genomes_df = pd.read_csv(genomes_info, sep="\t")
    reference_genomes = []
    if strain_taxid_file:
        strain_taxid_df = pd.read_csv(strain_taxid_file, sep="\t")
        merge_df = pd.merge(reference_genomes_df, strain_taxid_df, on="genome_ID", how="outer")
        assert len(merge_df) == len(strain_taxid_df) == len(reference_genomes_df)
        strain_taxid = merge_df["taxid"].astype(str).tolist()
        idx = merge_df["id"].tolist()
        for i in range(len(strain_taxid)):
            reference_genomes.append([strain_taxid[i], idx[i]])        
    else:
        species_taxid = reference_genomes_df["species_taxid"].astype(str).tolist()
        idx = reference_genomes_df["id"].tolist()
        for i in range(len(species_taxid)):
            reference_genomes.append([species_taxid[i], idx[i]])
    print(len(reference_genomes))
    # print(reference_genomes[:10])
    return reference_genomes

def fa_format_process(args):
    reference_strain, wd = args
    genomes_output_dir = Path(wd) / "prepare_genomes"
    genomes_output_dir.mkdir(exist_ok=True)
    output_file_path = Path(genomes_output_dir) / Path(reference_strain[1]).name 
    if not output_file_path.exists():  
        with open(reference_strain[1], 'r') as input_file, open(output_file_path, 'w') as output_file:
            for line in input_file:
                if line.startswith('>'):
                    split_result = line.split(' ', 1)                
                    if len(split_result) == 2:
                        modified_line = split_result[0] + "|kraken:taxid|" + reference_strain[0] + " " + split_result[1]
                        output_file.write(modified_line)
                    else:
                        output_file.write(line)
                else:
                    output_file.write(line)
    # gz_output_file_path = str(output_file_path) + ".gz"
    # if not Path(gz_output_file_path).exists():
    #     subprocess.run(f"gzip {output_file_path}", shell=True)
          

def parallel(reference_strains, wd):
    with concurrent.futures.ThreadPoolExecutor() as executor:
        executor.map(fa_format_process, [(reference_strain, wd) for reference_strain in reference_strains])

if __name__ == "__main__":
    sys.exit(main())
