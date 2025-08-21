import os
import numpy as np
import pandas as pd
import argparse

usage = "strain abundance estimate for other tools(except for pantax)"

def abundance_estimate(read_cls_file, read_length_file, samplesID, genome_length_file, output_path, genomes_info_file):
    readinfo=pd.read_csv(read_length_file, sep="\t", header=None, usecols=[0,1], dtype={0:str, 1:int})
    readinfo.columns = ["readID", "readLen"]
    try:
        # centrifuge
        mapinfo=pd.read_csv(read_cls_file, sep="\t", header=None, usecols=[0,2],dtype=object)
    except:
        mapinfo=pd.read_csv(read_cls_file, sep=" ", header=None, usecols=[0,2],dtype=object)
    mapinfo.columns = ["readID","strain_taxid"]

    read_cls = pd.merge(mapinfo, readinfo, on='readID')
    print(len(read_cls), len(mapinfo))
    assert len(read_cls) == len(mapinfo)
    read_cls = read_cls.sort_values(by='readID')
    read_cls = read_cls.drop_duplicates(subset='readID', keep='first')
    read_cls.loc[:, "strain_taxid"] = read_cls["strain_taxid"].fillna("0")
    read_cls = read_cls[~(read_cls[["strain_taxid"]] == "0").any(axis=1)]
    result_df = read_cls.groupby('strain_taxid', as_index=False).agg({'readLen': lambda x: list(x), 'readID': lambda x: list(x)})
    result_df['spyReads_Len'] = result_df['readLen'].apply(sum)
    result_df = pd.DataFrame(result_df)
    if genomes_info_file and genomes_info_file != "-":
        genomes_info = pd.read_csv(genomes_info_file, sep="\t", usecols=[0])
        genomes_info.columns = ["strain_taxid"]
        result_df = pd.merge(result_df, genomes_info)
    genome_len = pd.read_csv(genome_length_file, sep="\t", usecols=[0, 2], header=None)
    genome_len.columns = ["strain_taxid", "genome_length"]
    genome_len["strain_taxid"] = genome_len["strain_taxid"].str.replace('_genomic.fna', '')
    new_result_df = pd.merge(result_df, genome_len, on='strain_taxid')
    # assert len(new_result_df) == len(result_df)
    new_result_df = new_result_df.iloc[ : ,[0,3,4] ]
    
    new_result_df['coverage'] = new_result_df['spyReads_Len'] / new_result_df['genome_length']
    new_result_df['abundance'] = new_result_df['coverage'] / new_result_df['coverage'].sum()
    new_result_df = new_result_df.sort_values(by="abundance", ascending=False)
    new_result_df = pd.DataFrame(new_result_df[["strain_taxid", "abundance", "coverage"]])    
    new_result_df.to_csv(os.path.join(output_path, "strain_abundance.txt"), index=False, sep="\t")

def abundance_estimate2(read_cls_file, read_length, genome_length_file, output_path, genomes_info_file):
    try:
        # centrifuge
        mapinfo=pd.read_csv(read_cls_file, sep="\t", header=None, usecols=[0,2],dtype=object)
    except:
        mapinfo=pd.read_csv(read_cls_file, sep=" ", header=None, usecols=[0,2],dtype=object)
    mapinfo.columns = ["readID","strain_taxid"] 
    read_cls = mapinfo[~(mapinfo[["strain_taxid"]] == "0").any(axis=1)].copy()
    read_cls.loc[:, "read_len"] = read_length * 2
    result_df = read_cls.groupby('strain_taxid', as_index=False).agg({'read_len': lambda x: list(x), 'readID': lambda x: list(x)})
    result_df['sum_read_len'] = result_df['read_len'].apply(sum)
    result_df = pd.DataFrame(result_df)
    if genomes_info_file and genomes_info_file != "-":
        genomes_info = pd.read_csv(genomes_info_file, sep="\t", usecols=[0])
        genomes_info.columns = ["strain_taxid"]
        result_df = pd.merge(result_df, genomes_info)
    genome_len = pd.read_csv(genome_length_file, sep="\t", usecols=[0, 2], header=None)
    genome_len.columns = ["strain_taxid", "genome_length"]  
    genome_len["strain_taxid"] = genome_len["strain_taxid"].str.replace('_genomic.fna', '')  
    new_result_df = pd.merge(result_df, genome_len, on='strain_taxid')
    assert len(new_result_df) == len(result_df)
    new_result_df['coverage'] = new_result_df['sum_read_len'] / new_result_df['genome_length']
    new_result_df['abundance'] = new_result_df['coverage'] / new_result_df['coverage'].sum()
    new_result_df = new_result_df.sort_values(by="abundance", ascending=False)
    new_result_df = pd.DataFrame(new_result_df[["strain_taxid", "abundance", "coverage"]])    
    new_result_df.to_csv(os.path.join(output_path, "strain_abundance.txt"), index=False, sep="\t")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='python strain_abundance_estimate.py', description='predict abundances and evaluate.')
    parser.add_argument("-rc", "--read_classification", dest='read_classification', type=str, required=True, help="Input file for read predict classification.")
    parser.add_argument("-rl", "--read_length", dest='read_length', type=str, required=True, help="Input file for read length.")
    parser.add_argument("-gl", "--genome_length", dest='genome_length', type=str, required=True, help="Input file for genome length.")
    parser.add_argument("-s", "--samplesID", dest='samplesID', type=str, required=True, help="samplesID.")
    parser.add_argument("-o", "--output_path", dest='output_path', type=str, required=True, help="output path.")
    parser.add_argument("-f", "--genomes_info", dest="genomes_info_file", type=str, default=None)
    
    args = parser.parse_args()
    read_cls_file = args.read_classification
    read_length_file =  args.read_length
    genome_file = args.genome_length
    samplesID = args.samplesID
    output_path = args.output_path
    genomes_info_file = args.genomes_info_file

    try:
        read_length = int(read_length_file)
        abundance_estimate2(read_cls_file, read_length, genome_file, output_path, genomes_info_file)
    except:
        abundance_estimate(read_cls_file, read_length_file, samplesID, genome_file, output_path, genomes_info_file)