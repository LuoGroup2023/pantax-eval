
import sys
import pandas as pd

strain_profile_file = sys.argv[1]
seqid2tax_file = sys.argv[2]

strain_profile = pd.read_csv(strain_profile_file, usecols = [0, 2])
strain_profile.columns = ["seq_id", "abundance"]
seqid2tax = pd.read_csv(seqid2tax_file, sep="\t", header=None, dtype=object, usecols=[0,3])
cols = seqid2tax.columns[[1,0]]
seqid2tax = seqid2tax[cols]
seqid2tax.columns = ["taxonomy", "seq_id"]
merge_df = pd.merge(strain_profile, seqid2tax, on="seq_id", how="left")
selected_df = merge_df[["taxonomy", "abundance"]]
print(len(selected_df))
new_df = selected_df.groupby("taxonomy", as_index=False)["abundance"].sum()
print(len(new_df))
new_df["abundance"] = new_df["abundance"]/100
new_df.columns = ["strain_taxid", "abundance"]
new_df_sorted = new_df.sort_values(by="abundance", ascending=False)
new_df_sorted = new_df_sorted[new_df_sorted["abundance"] > 0]
new_df_sorted.to_csv("strainflair_abundance.txt", index=False, sep="\t")
