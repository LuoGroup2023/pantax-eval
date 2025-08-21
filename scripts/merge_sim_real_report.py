

import sys

file1 = sys.argv[1]
file2 = sys.argv[2]
out_name = sys.argv[3]

lines = []
with open(file2, "r") as f:
    count = 0
    for line in f:
        if "start" in line: count += 1
        if "bottomrule" in line: break
        if count >= 2:
            lines.append(line)

with open(file1, "r") as f_in, open(out_name, "w") as f_out:
    for line in f_in:
        if "bottomrule" in line:
            for _line in lines:
                f_out.write(_line)
            f_out.write(line)
        else:
            f_out.write(line)
            
