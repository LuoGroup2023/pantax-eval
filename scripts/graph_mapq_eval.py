
import sys, subprocess
from pathlib import Path
import pandas as pd


dst = sys.argv[1]
sample_id = sys.argv[2]
gfa_file = sys.argv[3]
read_cls = sys.argv[4]
stat_file = sys.argv[5]

# result = subprocess.run(
#     ["vg", "stats", "-z", f"{gfa_file}"],
#     stdout=subprocess.PIPE,
#     stderr=subprocess.PIPE,
#     text=True, 
#     check=True
# )

# output = result.stdout
# stats = {}
# for line in output.strip().splitlines():
#     key, value = line.strip().split()
#     stats[key] = int(value)
# print(stats) # {'nodes': 2475727, 'edges': 3325936}

subprocess.run(f"~/miniconda3/envs/pantax_eval/bin/gretl stats -g {gfa_file} -t 128 -o graph_stats", shell=True)
graph_stats = pd.read_csv("graph_stats", sep="\t")
graph_nodes = graph_stats["Nodes"].tolist()[0]
graph_edges = graph_stats["Edges"].tolist()[0]
graph_degree = graph_stats["Node degree (total)"].tolist()[0]

data = pd.read_csv(read_cls, sep="\t", header = None)
data.columns = ["read_id", "mapq", "species_taxid", "read_len"]

min_mapq = data["mapq"].min()
max_mapq = data["mapq"].max()

mapq_counts = data["mapq"].value_counts().to_dict()

mapq_stat = {mq: mapq_counts.get(mq, 0) for mq in range(min_mapq, max_mapq + 1)}

mean_mapq = data["mapq"].mean()
median_mapq = data["mapq"].median()
var_mapq = data["mapq"].std()


stat_dict = {}
if Path(stat_file).exists():
    print(stat_file)
    with open(stat_file, "r") as f:
        for line in f:
            tokens = line.strip().split("\t")
            stat_dict[f"{tokens[0]}#{tokens[1]}"] = line

stat_dict[f"{dst}#{sample_id}"] = f"{dst}\t{sample_id}\t{graph_nodes}\t{graph_edges}\t{graph_degree}\t{min_mapq}\t{max_mapq}\t{mean_mapq}\t{median_mapq}\t{var_mapq}\t{mapq_stat}\n"
with open(stat_file, "w") as f:
    for _k, v in stat_dict.items():
        # print(_k, v)
        f.write(v)
    
