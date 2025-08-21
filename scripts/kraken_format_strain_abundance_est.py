

"""
This scripts is used to estimate strain abundance from kraken format report.
"""

import sys
import pandas as pd

def main():
    kraken_report = sys.argv[1]
    kraken_read = sys.argv[2]
    taxonomy = sys.argv[3]
    genome_length_file = sys.argv[4]
    tax2genome_file = sys.argv[5]
    # taxid2count = kraken_report_strain_abundance_est(kraken_report, taxonomy, genome_length_file)
    kraken_read_strain_abundance_est(kraken_read, genome_length_file, tax2genome_file)


def kraken_report_strain_abundance_est(kraken_report, taxonomy, genome_length_file):
    taxid2count = {}
    genome_id2count = []
    with open(kraken_report, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            if tokens[3] == taxonomy and taxonomy == "S1":
                taxonomy_level = "strain"
                read_count = tokens[2]
                taxid = tokens[4]
                species2genomeid = tokens[5].strip()
                species2genomeid_tokens = species2genomeid.split("_")
                idx = species2genomeid_tokens.index("GCF")
                genome_id = "_".join(species2genomeid_tokens[idx:])
                species = " ".join(species2genomeid_tokens[:idx])
                taxid2count[taxid] = int(read_count)
                genome_id2count.append((genome_id, read_count))
    genome_id2count_df = pd.DataFrame(genome_id2count)
    genome_id2count_df.columns = ["genome_id", "read_count"]
    genome_id2count_df["read_count"] = genome_id2count_df["read_count"].astype(int)
    genome_length = pd.read_csv(genome_length_file, sep="\t", header=None, usecols=[0, 2])
    genome_length.columns = ["genome_id", "genome_length"]
    genome_length["genome_id"] = genome_length["genome_id"].str.replace("_genomic.fna", "")
    merged_df = pd.merge(genome_id2count_df, genome_length, on="genome_id")
    merged_df["coverage"] = merged_df["read_count"] / merged_df["genome_length"]
    merged_df["abundance"] = merged_df["coverage"] / merged_df["coverage"].sum()
    merged_df = merged_df.sort_values(by="abundance", ascending=False)
    merged_df = pd.DataFrame(merged_df[["genome_id", "abundance"]])
    merged_df.columns = ["taxonomy", "abundance"]
    merged_df.to_csv(f"{taxonomy_level}_abundance.txt", sep="\t", index=False)
    return taxid2count

def kraken_read_strain_abundance_est(kraken_read, genome_length_file, tax2genome_file, taxid2count=None):
    mapinfo=pd.read_csv(kraken_read, sep="\t", header=None, usecols=[1, 2, 3],dtype=object)
    mapinfo.columns = ["readID", "taxid", "readLen"]
    read_len = mapinfo["readLen"].iloc[0]
    if "|" in read_len:
        mapinfo["readLen"] = mapinfo["readLen"].apply(lambda x: sum(map(int, x.split('|'))))
    else:
        mapinfo["readLen"] = mapinfo["readLen"].astype(int)
    tax2genome = pd.read_csv(tax2genome_file, sep="\t", usecols=[0, 2], dtype=object)
    tax2genome.columns = ["taxid", "genome_ID"]
    mapinfo = pd.merge(mapinfo, tax2genome, on="taxid", how="left")
    # filter the read not mapping to strain
    read_cls = mapinfo.dropna(subset=["genome_ID"])
    if taxid2count:
        for taxid, group in read_cls.groupby("taxid"):
            read_count = len(group)
            if read_count != taxid2count[taxid]:
                print(taxid, read_count, taxid2count[taxid])
                sys.exit(0)
    result_df = read_cls.groupby("genome_ID", as_index=False).agg({"readLen": lambda x: list(x), "readID": lambda x: list(x)})
    result_df["sum_read_len"] = result_df["readLen"].apply(sum)
    genome_len = pd.read_csv(genome_length_file, sep="\t", usecols=[0, 2], header=None)
    genome_len.columns = ["genome_ID", "genome_length"]
    genome_len["genome_ID"] = genome_len["genome_ID"].str.replace("_genomic.fna", "")
    result_df2 = pd.merge(result_df, genome_len, on="genome_ID")    
    assert len(result_df2) == len(result_df)
    result_df2["coverage"] = result_df2["sum_read_len"] / result_df2["genome_length"]
    result_df2["abundance"] = result_df2["coverage"] / result_df2["coverage"].sum()
    result_df2 = result_df2.sort_values(by="abundance", ascending=False)
    result_filter = pd.DataFrame(result_df2[["genome_ID", "abundance", "coverage"]])
    result_filter.columns = ["strain_taxid", "abundance", "coverage"]
    result_filter.to_csv("strain_abundance.txt", sep="\t", index=False)
    


if __name__ == "__main__":
    sys.exit(main())


