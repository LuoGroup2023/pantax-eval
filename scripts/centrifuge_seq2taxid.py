
"""
This script is used to generate fna_seqID_taxid.txt file from genomes_info file and seqid2taxid.map for centrifuge.
"""

import sys
import pandas as pd

genomes_info_file = sys.argv[1]
seqid2taxid_file = sys.argv[2]
output = sys.argv[3]

genomes_info = pd.read_csv(genomes_info_file, sep="\t")
seqid2taxid = pd.read_csv(seqid2taxid_file, sep="\t", header=None)
seqid2taxid.columns = ["seqid", "genome_ID"]

merged = pd.merge(genomes_info, seqid2taxid, on="genome_ID")
assert len(merged) == len(seqid2taxid)

merged.to_csv(f"{output}_fna_seqID_taxid.txt", index=False, sep="\t")


