import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.colors import LinearSegmentedColormap

def main():
    pantax_eval = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/pantax/pantax_v2_eval.log"
    outdir = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"
    records = eval_process("PanTax", pantax_eval)
    records_df = pd.DataFrame(records)
    records_df.columns = ["ANI(%)", "Coverage ratio", "tool", "strain_precision", "strain_recall", "F1 score", "AUPR", "L2 distance", "AFE", "RFE", "L1 distance", "BC distance"]
    genomes_ANI = {"GCF_009769125.1_ASM976912v1-GCF_000751035.1_PM221":98.0376, "GCF_011038575.1_ASM1103857v1-GCF_000751035.1_PM221":99.1194,"GCF_024204725.1_ASM2420472v1-GCF_000751035.1_PM221":96.8418, "GCF_025558705.1_ASM2555870v1-GCF_000751035.1_PM221":96.9067, "GCF_026153315.1_ASM2615331v1-GCF_000751035.1_PM221":99.7788}
    records_df["ANI(%)"] = records_df["ANI(%)"].replace(genomes_ANI)
    records_df["Coverage ratio"] = records_df["Coverage ratio"].str.replace("dataset","").str.replace("-",":")
    records_df.to_csv("test.tsv", index=False, sep="\t")
    val_cols = ["F1 score", "AUPR", "L2 distance"]
    heatmap(records_df, "Coverage ratio", "ANI(%)", val_cols, outdir, merge=True)
    # for val_col in ["F1 score", "AUPR", "L2 distance"]:
    #     if val_col == "L2 distance":
    #         heatmap(records_df, "Coverage ratio", "ANI(%)", val_col, reverse=True)
    #     else:
    #         heatmap(records_df, "Coverage ratio", "ANI(%)", val_col)


def heatmap(data, x_col, y_col, val_cols, outdir, merge=False):
    colors = [(0.4, 0.6, 0.9), (0.8, 0.9, 1.0)]  
    cmap = LinearSegmentedColormap.from_list("CustomBlue", colors)
    if merge:
        fig, axs = plt.subplots(1, 3, figsize=(18, 6))
        i = 0
        for val_col in val_cols:
            if val_col == "L2 distance":
                reverse=True
            else:
                reverse=False
            data0 = data.loc[:, [x_col, y_col, val_col]]
            matrix = data0.pivot(index=y_col, columns=x_col, values=val_col)
            sorted_columns = sorted(matrix.columns, key=lambda x: int(x.split(':')[0]))
            matrix = matrix.reindex(columns=sorted_columns)
            matrix = matrix.sort_index(ascending=False)   
            matrix = matrix.astype(float)   
            if reverse:
                sns.heatmap(matrix, cmap=cmap, annot=True, fmt=".3f", cbar=False, ax=axs[i], annot_kws={"size": 14, "color": "black", "weight": "bold"})
            else:
                sns.heatmap(matrix, cmap=cmap, annot=True, fmt=".3f", cbar=False, ax=axs[i], annot_kws={"size": 14, "color": "black", "weight": "bold"})
            axs[i].set_title(f"{val_col}", fontsize=18, fontweight='bold')
            axs[i].set_xlabel("Coverage ratio", fontsize=16, fontweight='bold')
            axs[i].set_ylabel("ANI(%)", fontsize=16, fontweight='bold')
            i += 1
        plt.tight_layout()
        plt.savefig(f"{outdir}/PanTax_eval_heatmap.pdf", dpi=600)
        # plt.savefig("PanTax_eval_heatmap.png", dpi=600)
        plt.show()
    else:
        for val_col in val_cols:
            if val_col == "L2 distance":
                reverse=True
            else:
                reverse=False
            data = data.loc[:, [x_col, y_col, val_col]]
            matrix = data.pivot(index=y_col, columns=x_col, values=val_col)
            matrix.columns = sorted(matrix.columns, key=lambda x: int(x.split(':')[0]))
            matrix = matrix.sort_index(ascending=False)   
            matrix = matrix.astype(float)
            # plt.figure(figsize=(8, 6))
            # plt.imshow(matrix, cmap='Blues', interpolation='nearest')
            # plt.colorbar(label=val_col)
            # plt.xlabel(x_col)
            # plt.ylabel(y_col)
            # plt.xticks(np.arange(len(matrix.columns)), matrix.columns)
            # plt.yticks(np.arange(len(matrix.index)), matrix.index)
            # for y in range(matrix.shape[0]):
            #     for x in range(matrix.shape[1]):
            #         plt.text(x, y, '{:.1f}'.format(matrix.iloc[y, x]), ha='center', va='center', color='white')
            # plt.title('Heatmap')
            # plt.tight_layout()
            # plt.show()

            plt.figure(figsize=(8, 6))
            if reverse:
                sns.heatmap(matrix, cmap='Blues_r', annot=True, fmt=".3f", cbar=True)
            else:
                sns.heatmap(matrix, cmap='Blues', annot=True, fmt=".3f", cbar=True)
            plt.title(f"{val_col}")
            plt.savefig(f"{outdir}/{val_col}.png", dpi=600)
            plt.show()


def eval_process(tool, file):
    records = []
    with open(file, "r") as f:
        record = []
        for line in f:
            if line.strip().startswith("GCF"):
                tokens = line.strip().split("/")
                genomes = tokens[0]
                cov = tokens[1]
                assert len(record) == 0
                record.extend([genomes, cov, tool])
            elif "&" in line:
                assert len(record) == 3
                # record.append(line.strip())
                record.extend(line.strip().split("&"))
                records.append(record)
                record = []
    return records

if __name__ == "__main__":
    sys.exit(main())
  