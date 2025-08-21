
"""
This script is used to supplement empty metrics for tools that cannot run on certain datasets
"""

import sys, os
from pathlib import Path

wd = sys.argv[1]

def find_deepest_subdirs(root_dir):
    dir_depth = {}
    max_depth = 0
    for root, dirs, files in os.walk(root_dir):
        depth = root.count(os.sep)  
        for d in dirs:
            dir_depth[os.path.join(root, d)] = depth
            if not max_depth and "ngs" in d:
                path = os.path.join(root, d)
                tokens = path.split("/")
                idx = tokens.index("ngs")
                max_depth = idx - 1
    
    # max_depth = max(dir_depth.values(), default=-1)
    deepest_dirs = [k for k, v in dir_depth.items() if v == max_depth]
    
    return deepest_dirs


deepest_subdirs = find_deepest_subdirs(wd)
for dir in deepest_subdirs:
    if "dechat" in dir: continue
    eval_report = Path(dir) / "evaluation_report.txt"
    if not eval_report.exists():
        with open(eval_report, "w") as f:
            f.write("strain_precision\tstrain_recall\tf1_score\tAUPR\tl2_dist\tAFE\tRFE\tl1_dist\tbc_dist\n")
            f.write("- & - & - & - & - & - & - & - & -\n")



