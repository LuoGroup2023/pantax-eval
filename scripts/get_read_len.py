import os
import numpy as np
import pandas as pd
import argparse
# from Bio import SeqIO
import gzip
from concurrent.futures import ProcessPoolExecutor
from functools import partial
from datetime import datetime

def open_file(file_path):
    if file_path.endswith(".gz"):
        return gzip.open(file_path, 'rt')
    else:
        return open(file_path, 'r')

def process_record(record):
    read_id = record.id
    read_length = len(record.seq)
    return (read_id, read_length)

def read_length_statistics_parallel(fq_file, num_processes):
    lengths = []
    print("%%%%%%%%%%%Calculate reads length:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"),"%%%%%%%%%%%%%%%%%")

    with open_file(fq_file) as file:
        records = list(SeqIO.parse(file, "fastq"))

    process_record_partial = partial(process_record)

    with ProcessPoolExecutor(max_workers=num_processes) as executor:
        lengths = list(executor.map(process_record_partial, records))

    rl = pd.DataFrame(lengths, columns=["readID", "readLen"])
    print("%%%%%%%%%%% Calculate reads length completed:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"),"%%%%%%%%%%%%%%%%%")
    return rl

def fa_read_length_statistics_parallel(fa_file, num_processes):
    lengths = []
    print("%%%%%%%%%%%Calculate reads length:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"),"%%%%%%%%%%%%%%%%%")

    with open_file(fa_file) as file:
        records = list(SeqIO.parse(file, "fasta"))

    process_record_partial = partial(process_record)

    with ProcessPoolExecutor(max_workers=num_processes) as executor:
        lengths = list(executor.map(process_record_partial, records))

    rl = pd.DataFrame(lengths, columns=["readID", "readLen"])
    print("%%%%%%%%%%% Calculate reads length completed:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"),"%%%%%%%%%%%%%%%%%")
    return rl

def fa_read_length_statistics(fa_file, samplesID):
    read_len_info = []
    with open(fa_file, "r") as f:
        read_id = None
        for i, line in enumerate(f):
            if i % 2 == 0 and line.startswith(">"):
                read_id = line.strip()[1:].split(" ")[0]
            elif i % 2 == 1 and read_id:
                read_length = len(line.strip())
                read_len_info.append((read_id, read_length))
                read_id = None
    # read_len_info_df = pd.DataFrame(read_len_info)
    # read_len_info_df.columns = ["readID", "readLen"]
    with open(f"{samplesID}_read_length.txt", "w") as f:
        for _read_len_info in read_len_info:
            _readID, _readLen = _read_len_info
            f.write(f"{_readID}\t{_readLen}\n")

def fq_read_length_statistics(file_path, samplesID):
    read_len_info = []
    with open_file(file_path) as f:
        read_id = None
        for i, line in enumerate(f):
            if i % 4 == 0 and line.startswith("@"):
                read_id = line.strip()[1:].split(" ")[0]
            elif i % 4 == 1 and read_id:
                read_length = len(line.strip())
                read_len_info.append((read_id, read_length))
                read_id = None
    # read_len_info_df = pd.DataFrame(read_len_info)
    # read_len_info_df.columns = ["readID", "readLen"]
    with open(f"{samplesID}_read_length.txt", "w") as f:
        for _read_len_info in read_len_info:
            _readID, _readLen = _read_len_info
            f.write(f"{_readID}\t{_readLen}\n")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='python get_read_len.py', description='get read length.')
    parser.add_argument("-fq", "--fq_file", dest='fq_file', type=str, default=None, help="Input file for read length.")
    parser.add_argument("-fa", "--fa_file", dest='fa_file', type=str, default=None, help="Input file for read length.")
    parser.add_argument("-s", "--samplesID", dest='samplesID', type=str, required=True, help="samplesID.")
    parser.add_argument("-t", "--threads", dest='threads', type=int, default=64, help="threads.")
    parser.add_argument("-p", "--parallel", dest='parallel', action="store_true", help="whether parallel.")
    args = parser.parse_args()
    if args.parallel:
        if args.fq_file:
            read_length = read_length_statistics_parallel(args.fq_file, args.threads)
        elif args.fa_file:
            read_length = fa_read_length_statistics_parallel(args.fa_file, args.threads)
        read_length.to_csv(f"{args.samplesID}_read_length.txt",index=False, sep="\t",header=None)
    else:
        if args.fq_file:
            fq_read_length_statistics(args.fq_file, args.samplesID)
        elif args.fa_file:
            fa_read_length_statistics(args.fa_file, args.samplesID)

    