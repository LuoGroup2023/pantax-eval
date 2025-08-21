
"""
This script is used to convert the result of metamaps to common format like centrifuge.
"""

import sys
import pandas as pd

def main():
    cls_result = sys.argv[1]
    seqid2genome = sys.argv[2]
    # read2taxon = sys.argv[3]
    process(cls_result, seqid2genome)

def process2(cls_result, seqid2genome, read2taxon):
    read2taxon_dict = {}
    with open(read2taxon, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            read_id = tokens[0]
            mapq = float(tokens[2])
            if read_id not in read2taxon_dict:
                read2taxon_dict[read_id] = mapq
            else:
                raise ValueError(f"{read_id} already exists.")

    read_id2seqid = {}
    with open(cls_result, "r") as f:
        for line in f:
            tokens = line.strip().split(" ")
            read_id = tokens[0]
            mapq = tokens[-1]
            seqid = tokens[5].split("|")[-1]
            record = read_id2seqid.get(read_id, None)  
            if not record and float(mapq) == read2taxon_dict[read_id]:
                read_id2seqid[read_id] = (seqid, mapq)
    # print(len(read_id2seqid), len(read2taxon_dict))
    # for read_id in read2taxon_dict:
    #     if read_id not in read_id2seqid:
    #         print(read_id)
    # assert len(read_id2seqid) == len(read2taxon_dict)
    read_id2seqid_list = []
    for _read_id, _record in read_id2seqid.items():
        read_id2seqid_list.append((_read_id, _record[0]))
    read_id2seqid_df = pd.DataFrame(read_id2seqid_list, columns=["read_id", "seqid"])
    seqid2genome_df = pd.read_csv(seqid2genome, sep="\t", header=None)
    seqid2genome_df.columns = ["genome_ID", "strain_taxid", "species_taxid", "seqid"]
    merged = pd.merge(read_id2seqid_df, seqid2genome_df, on="seqid")
    assert len(read_id2seqid_df) == len(merged)
    merged.to_csv("strain_classification_test.csv", index=False, header=None, sep="\t")


def process(cls_result, seqid2genome):
    read_id2seqid = {}
    with open(cls_result, "r") as f:
        for line in f:
            tokens = line.strip().split(" ")
            read_id = tokens[0]
            mapq = tokens[-1]
            seqid = tokens[5].split("|")[-1]
            record = read_id2seqid.get(read_id, None)
            if record:
                prev_mapq = record[1]
                if float(mapq) > float(prev_mapq):
                    read_id2seqid[read_id] = (seqid, mapq)
            else:
                read_id2seqid[read_id] = (seqid, mapq)
    read_id2seqid_list = []
    for _read_id, _record in read_id2seqid.items():
        read_id2seqid_list.append((_read_id, _record[0]))
    read_id2seqid_df = pd.DataFrame(read_id2seqid_list, columns=["read_id", "seqid"])
    seqid2genome_df = pd.read_csv(seqid2genome, sep="\t", header=None)
    seqid2genome_df.columns = ["genome_ID", "strain_taxid", "species_taxid", "seqid"]
    merged = pd.merge(read_id2seqid_df, seqid2genome_df, on="seqid")
    assert len(read_id2seqid_df) == len(merged)
    merged.to_csv("strain_classification.csv", index=False, header=None, sep="\t")


if __name__ == "__main__":
    sys.exit(main())

