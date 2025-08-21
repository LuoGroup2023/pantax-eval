
import sys
import pandas as pd

abundance_file = sys.argv[1]
e = sys.argv[2]
data = pd.read_csv(abundance_file, sep="\t")

data = data[data["predicted_coverage"] >= float(e)]
data["predicted_abundance"] = data["predicted_coverage"]/sum(data["predicted_coverage"])
data.to_csv(f"filter{e}_strain_abundance.txt", sep="\t", index=False)


