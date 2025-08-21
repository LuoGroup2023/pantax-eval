

import sys, re

dataset = sys.argv[1]
report = sys.argv[2]
# print(dataset)
caption = {
    "simlow": """
    Benchmarking results of strain-level taxonomic profiling on the sim-low datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-low PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "simhigh": """
    Benchmarking results of strain-level taxonomic profiling on the sim-high datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-high PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "simlow-sub0.001": """
    Benchmarking results of strain-level taxonomic profiling on the sim-low-mut1 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-low-mut1 PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "simhigh-sub0.001": """
    Benchmarking results of strain-level taxonomic profiling on the sim-high-mut1 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-high-mut1 PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "simlow-sub0.01": """
    Benchmarking results of strain-level taxonomic profiling on the sim-low-mut2 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-low-mut2 PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "simhigh-sub0.01": """
    Benchmarking results of strain-level taxonomic profiling on the sim-high-mut2 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-high-mut2 PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "zymo1": """
    Benchmarking results of strain-level taxonomic profiling on the Zymo datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run KMCP on Zymo1 ONT and Zymo2 ONT dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "spiked_in_eight_species666_large_pangenome": """
    Benchmarking results of strain-level taxonomic profiling on the spiked-in datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on spiked-in PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "refdiv": """
    Benchmarking results of strain-level taxonomic profiling by PanTax across different databases.
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve.
    """,
    "asm2prof": """
    Benchmarking results of strain-level taxonomic profiling compared to assembly tools.
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. 
    """,
    "single-species": """
    Benchmarking results of strain-level taxonomic profiling on the S. epidermidis strain mixtures datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics.
    """,
    "simlow-subsample0.5": """
    Benchmarking results of strain-level taxonomic profiling on the sim-low-sub1 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-low-sub1 PacBio CLR dataset. 
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    To account for the presence of low-coverage($0.5\\\\times$) strains, PanTax adopts a more relaxed threshold on this dataset by setting $f_{\\\\rm strain}$ to 0 and $d_{\\\\rm strain}$ to 1.
    """,
    "simlow-subsample0.2": """
    Benchmarking results of strain-level taxonomic profiling on the sim-low-sub2 datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-low-sub2 PacBio CLR dataset. 
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    To account for the presence of low-coverage($0.2\\\\times$) strains, PanTax adopted a more relaxed threshold on this dataset by setting $f_{\\\\rm strain}$ to 0 and $d_{\\\\rm strain}$ to 1.
    """,
    "simhigh-gtdb": """
    Benchmarking results of strain-level taxonomic profiling on the sim-high-gtdb datasets. 
    Note that the best score is marked in bold, and the second best score is marked in italics. 
    AUPR: area under the precision-recall curve. Note that we failed to run Ganon and KMCP on sim-high-gtdb PacBio CLR dataset.
    KMCP failed because all reference genomes were filtered out, while Ganon failed as no reads matched any reference genome.
    """,
    "general_ngs_time": """
    Runtime and memory usage of benchmarking tools on sim-low, sim-high and PD human gut NGS datasets. 
    We measured the CPU time, wall time, and maximum RAM usage required by the benchmark tool to build the database (RefSeq: 13404) and perform taxonomic profiling using 64 threads. 
    In the table, some time values are separated by ``+". For PanTax's Database build time, 
    it represents the pangenome construction time and index construction time, respectively. 
    For PanTax (fast)'s taxonomic profiling time, the time values correspond to the pangenome construction time, index construction time, 
    and the time required for performing taxonomic profiling on the respective dataset. Notably, for all tools, the taxonomic profiling time includes their Database build time.
    """,
    "general_tgs_time": """
    Runtime and memory usage of benchmarking tools on sim-low, sim-high, Healthy human gut and Omnivorous human gut TGS datasets. 
    We measured the CPU time, wall time, and maximum RAM usage required by the benchmark tool to build the database (RefSeq: 13404) and perform taxonomic profiling using 64 threads. 
    We failed to run Ganon and KMCP on sim-high-gtdb PacBio CLR dataset and Healthy human gut ONT dataset. In the table, 
    some time values are separated by ``+". For PanTax (fast)'s taxonomic profiling time, 
    the time values correspond to the pangenome construction time and the time required for performing taxonomic profiling on the respective dataset. Notably, for all tools, the taxonomic profiling time includes their Database build time. 
    """,
    "gtdb100_simhigh_all_time": """
    Runtime and memory usage of benchmarking tools on sim-high-gtdb datasets. 
    We measured the CPU time, wall time, and maximum RAM usage required by the benchmark tool to build the database (GTDB: 206273) and perform taxonomic profiling using 64 threads. 
    We failed to run Ganon and KMCP on sim-high-gtdb PacBio CLR dataset. In the table, some time values are separated by ``+". 
    For PanTax (fast)'s taxonomic profiling time on the NGS dataset, it represents the pangenome construction time, 
    index construction time, and the time required to perform taxonomic profiling on the respective dataset. 
    For PanTax (fast)'s taxonomic profiling time on TGS datasets, the time values correspond to the pangenome construction time and the time required for performing taxonomic profiling on the respective dataset. 
    Notably, for all tools, the taxonomic profiling time includes their Database build time.
    """, 
    "single_species_ngs_time": """
    Runtime and memory usage of benchmarking tools on \\\\textit{S. epidermidis} strain mixtures NGS datasets. 
    We measured the CPU time, wall time, and maximum RAM usage required by the benchmark tool to build the database (Complete genomes of \\\\textit{S. epidermidis} on RefSeq) 
    and perform taxonomic profiling using 64 threads. In the table, some time values are separated by ``+". For PanTax's Database build time, 
    it represents the pangenome construction time and index construction time, respectively. 
    Notably, for all tools, the taxonomic profiling time includes their Database build time.
    """
}



zymo1_dataset = ["zymo1", "zymo1-log"]
if dataset in zymo1_dataset:
    dataset = "zymo1"

with open(report, "r") as f:
    lines = f.readlines()

new_caption = caption.get(dataset, None)
if new_caption:
    updated_lines = [
        re.sub(r'\\caption\{.*?\}', rf'\\caption{{{new_caption}}}', line)
        for line in lines
    ]

    with open(report, "w") as f:
        f.writelines(updated_lines)


