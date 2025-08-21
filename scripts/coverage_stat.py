
import sys
import pandas as pd

data = pd.read_csv(sys.argv[1], sep="\t", header=None)

data.columns = ["genome", "cov"]

data1 = data[data["cov"] <= 3 ]

print(f"genome coverage less than 3x number: {len(data1)}")

data2 = data[data["cov"] <= 5 ]

print(f"genome coverage less than 5x number: {len(data2)}")