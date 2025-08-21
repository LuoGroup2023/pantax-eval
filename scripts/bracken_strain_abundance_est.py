
"""
This scripts is used to estimate strain abundance from bracken report.
"""

import sys
import pandas as pd


def main():
    bracken_query_report_file = sys.argv[1]
    genome_length_file = sys.argv[2]
    read_len = sys.argv[3]
    tax2genome_file = sys.argv[4]
    abundance_est(bracken_query_report_file, genome_length_file, read_len, tax2genome_file)

def abundance_est(bracken_query_report_file, genome_length_file, read_len, tax2genome_file):
    bracken_query_report = pd.read_csv(bracken_query_report_file, sep="\t", usecols=[1,5])
    bracken_query_report.columns = ["taxid", "read_count"]
    bracken_query_report["taxid"] = bracken_query_report["taxid"].astype(str)
    tax2genome = pd.read_csv(tax2genome_file, sep="\t", usecols=[0, 2], dtype=object)
    tax2genome.columns = ["taxid", "genome_ID"]
    bracken_query_report_merged = pd.merge(bracken_query_report, tax2genome, on="taxid")
    # assert len(bracken_query_report_merged) == len(bracken_query_report)
    genome_len = pd.read_csv(genome_length_file, sep="\t", usecols=[0, 2], header=None)
    genome_len.columns = ["genome_ID", "genome_length"] 
    genome_len["genome_ID"] = genome_len["genome_ID"].str.replace("_genomic.fna", "")
    bracken_query_report_merged2 = pd.merge(bracken_query_report_merged, genome_len, on="genome_ID") 
    assert len(bracken_query_report_merged2) == len(bracken_query_report_merged)
    bracken_query_report_merged2["read_len"] = bracken_query_report_merged2["read_count"] * int(read_len) * 2
    bracken_query_report_merged2["coverage"] = bracken_query_report_merged2["read_len"] / bracken_query_report_merged2["genome_length"]
    bracken_query_report_merged2["abundance"] = bracken_query_report_merged2["coverage"] / bracken_query_report_merged2["coverage"].sum()
    bracken_query_report_merged2 = bracken_query_report_merged2.sort_values(by="abundance", ascending=False)
    result_filter = pd.DataFrame(bracken_query_report_merged2[["genome_ID", "abundance", "coverage"]])
    result_filter.columns = ["strain_taxid", "abundance", "coverage"]
    result_filter.to_csv("strain_abundance.txt", sep="\t", index=False) 


if __name__ == "__main__":
    sys.exit(main())
