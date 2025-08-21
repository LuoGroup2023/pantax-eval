import sys
import pandas as pd
import numpy as np
import argparse
import matplotlib.pyplot as plt
from scipy.spatial.distance import braycurtis
import warnings
warnings.filterwarnings("ignore")
# from sklearn.metrics import precision_recall_curve, auc

def main():
    parser = argparse.ArgumentParser(prog="python strain_evaluation.py")
    parser.add_argument("predicted_abund_path", type=str, help="abundance file")
    parser.add_argument("tool", type=str, help="Tools name(lower case)")
    # parser.add_argument("read_type", type=str, help="long/short")
    parser.add_argument("data_type", type=int, help="30(species)/1000(strains)")
    parser.add_argument("true_abund_path", type=str, help="true_abund_path")
    parser.add_argument("genomes_info_file", type=str, help="genomes_info_file")
    parser.add_argument("-l", "--low", dest="low", action="store_true", help="Low abundance strain recall evaluation.")
    parser.add_argument("-c", dest="cov_file", help="real strain coverage file which extracted from camisim log file.")
    args = parser.parse_args()
    # genomes_info_file = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt"
    genomes_info_file = args.genomes_info_file
    genomes_info = pd.read_csv(genomes_info_file, sep="\t", dtype=object)
    if args.true_abund_path:
        true_abund_path = args.true_abund_path
    else:
        if args.data_type == 30:
            # true_abund_path = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/pggb_vg/big_sample/camisim_simulate/60_genome_simulate_result/distributions/distribution_0.txt"
            true_abund_path = "/home/work/wenhai/simulate_genome_data/PanTax/short_read/30_species/sim-30species-ngs/distributions/distribution_0.txt"
        elif args.data_type == 1000:
            true_abund_path = "/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt"
        elif args.data_type == 5:
            true_abund_path = "/home/work/wenhai/simulate_genome_data/PanTax/prepare/30species_low/distribution.txt"

    # true_strain_abundance = pd.read_csv(genomes_info_file, sep="\t")
    # predicted_abund_path = "strain_abundance.txt"
    if args.tool == "vg" or "pantax" in args.tool:
        try:
            predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[1,2,3,4], dtype={1:str, 2:str, 3:float,4:float})
            # print(predicted_strain_data.head(10))
        except:
            sys.exit(0)
    elif args.tool == "sylph":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[0,1])
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]        
    elif args.tool == "strainscan":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t")
        if predicted_strain_data.shape[1] == 7:
            predicted_strain_data = predicted_strain_data[["Strain_Name", "Predicted_Depth"]]
        else:
            predicted_strain_data = predicted_strain_data[["Strain_Name", "Predicted_Depth (Ab*cls_depth)"]]
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]
        predicted_strain_data["predicted_abundance"] = predicted_strain_data["predicted_abundance"]/predicted_strain_data["predicted_abundance"].sum()
        true_strain_data = pd.read_csv(args.true_abund_path, sep="\t", header=None)
        true_strain_data.columns = ["genome_ID", "true_abundance"]
        true_strain_data["genome_ID"] = true_strain_data["genome_ID"].apply(lambda row: row.split(".")[0])
    elif args.tool == "straingst":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[1, 11])
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]
        predicted_strain_data["predicted_abundance"] = predicted_strain_data["predicted_abundance"]/100
        true_strain_data = pd.read_csv(args.true_abund_path, sep="\t", header=None)
        true_strain_data.columns = ["genome_ID", "true_abundance"]
    elif args.tool == "strainest":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t")
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]
        predicted_strain_data = predicted_strain_data[predicted_strain_data["predicted_abundance"] != 0]
        predicted_strain_data["genome_ID"] = predicted_strain_data["genome_ID"].str.replace("_genomic.fna", "")
        # predicted_strain_data.to_csv("predicted_abundance.txt", sep="\t", index=False)
        true_strain_data = pd.read_csv(args.true_abund_path, sep="\t", header=None)
        true_strain_data.columns = ["genome_ID", "true_abundance"]
    elif args.tool == "uniqsketch":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[0,1])
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]
        predicted_strain_data = predicted_strain_data[predicted_strain_data["predicted_abundance"] != 0]
        predicted_strain_data["genome_ID"] = predicted_strain_data["genome_ID"].str.replace("_genomic", "")
        true_strain_data = pd.read_csv(args.true_abund_path, sep="\t", header=None)
        true_strain_data.columns = ["genome_ID", "true_abundance"]
    elif args.tool == "strainflair":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[0,1])
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]  
    elif args.tool.lower() == "metamdbg" or args.tool.lower() == "hifiasm" or args.tool.lower() == "flye" or args.tool.lower() == "myloasm":
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[0,1], header=None)
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]     
    
    else:
        # kraken2, centrifuge
        predicted_strain_data = pd.read_csv(args.predicted_abund_path, sep="\t", usecols=[0,1])
        predicted_strain_data.columns = ["genome_ID", "predicted_abundance"]
        predicted_strain_data = predicted_strain_data[predicted_strain_data.iloc[:, 1] != 0]
    if predicted_strain_data.empty:
        print("strain_precision\tstrain_recall\tf1_score\tAUPR\tl2_dist\tAFE\tRFE\tl1_dist\tbc_dist")
        print("- & - & - & - & - & - & - & - & -\n")
        return
    predicted_strain_data = predicted_strain_data.sort_values(by="predicted_abundance", ascending=False)
    if args.tool != "strainscan" and args.tool != "straingst" and args.tool != "strainest":
        true_strain_data = pd.read_csv(true_abund_path, sep="\t", header=None)
        true_strain_data.columns = ["genome_ID", "true_abundance"]
    if args.low:
        true_strain_cov_data = pd.read_csv(args.cov_file, sep="\t", header=None)
        true_strain_cov_data.columns = ["genome_ID", "true_cov"]
        strain_precision, strain_recall, l1_dist, l2_dist, bc_distance, f1_score = strain_evaluation_low(predicted_strain_data, true_strain_data, true_strain_cov_data, threshold=0)
    else:
        strain_precision, strain_recall, l1_dist, l2_dist, bc_distance, f1_score = strain_evaluation(predicted_strain_data, true_strain_data, threshold=0)
    # true_predict_strain_num, true_database_strain_num = strain_predicted_and_real(predicted_strain_data, true_strain_data, genomes_info)
    aupr = aupr_cal(predicted_strain_data, true_strain_data)
    AFE, RFE = AFE_RFE_cal(predicted_strain_data, true_strain_data)
    print("strain_precision\tstrain_recall\tf1_score\tAUPR\tl2_dist\tAFE\tRFE\tl1_dist\tbc_dist")
    print("{:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f}\n".format(strain_precision, strain_recall, f1_score, aupr, l2_dist, AFE, RFE, l1_dist, bc_distance))

def strain_evaluation(predicted_strain_data, true_strain_data, threshold=0):
    # predicted_strain_data = predicted_strain_data[predicted_strain_data["predicted_coverage"] >= 1]
    predicted_genomeID = predicted_strain_data["genome_ID"].tolist()
    predicted_abund = predicted_strain_data["predicted_abundance"].tolist()
    true_genomeID = true_strain_data.iloc[:, 0].tolist()
    # for genome in true_genomeID:
    #     if genome not in predicted_genomeID:
    #         print(genome)
    predicted_positive = [genome for genome, abundance in zip(predicted_genomeID, predicted_abund) if abundance > threshold]
    true_positive = len(set(predicted_positive) & set(true_genomeID))
    strain_precision = true_positive/len(predicted_positive)
    strain_recall = true_positive/len(true_genomeID)
    merge_df = pd.merge(predicted_strain_data, true_strain_data, on="genome_ID", how="outer")
    merge_df.loc[:, "predicted_abundance"] = merge_df["predicted_abundance"].fillna(0)
    merge_df.loc[:, "true_abundance"] = merge_df["true_abundance"].fillna(0)
    predicted_abund = np.array(merge_df["predicted_abundance"].tolist())
    abund = np.array(merge_df["true_abundance"].tolist())
    l2_dist = np.linalg.norm(predicted_abund-abund)
    l1_dist = np.linalg.norm(predicted_abund-abund, ord=1)
    bc_distance = braycurtis(predicted_abund, abund)
    try:
        f1_score = 2*strain_precision*strain_recall/(strain_precision+strain_recall)
    except ZeroDivisionError:
        f1_score = 0
    return strain_precision, strain_recall, l1_dist, l2_dist, bc_distance, f1_score

def strain_evaluation_low(predicted_strain_data, true_strain_data, true_strain_cov_data, threshold=0):
    predicted_genomeID = predicted_strain_data["genome_ID"].tolist()
    predicted_abund = predicted_strain_data["predicted_abundance"].tolist()
    true_strain_data = pd.merge(true_strain_data, true_strain_cov_data, on="genome_ID", how="inner")
    true_strain_data = true_strain_data[true_strain_data["true_cov"] <= 3]
    true_genomeID = true_strain_data.iloc[:, 0].tolist()
    predicted_positive = [genome for genome, abundance in zip(predicted_genomeID, predicted_abund) if abundance > threshold]
    true_positive = len(set(predicted_positive) & set(true_genomeID))
    strain_precision = true_positive/len(predicted_positive)
    strain_recall = true_positive/len(true_genomeID)
    merge_df = pd.merge(predicted_strain_data, true_strain_data, on="genome_ID", how="inner")
    merge_df.loc[:, "predicted_abundance"] = merge_df["predicted_abundance"].fillna(0)
    merge_df.loc[:, "true_abundance"] = merge_df["true_abundance"].fillna(0)
    predicted_abund = np.array(merge_df["predicted_abundance"].tolist())
    abund = np.array(merge_df["true_abundance"].tolist())
    l2_dist = np.linalg.norm(predicted_abund-abund)
    l1_dist = np.linalg.norm(predicted_abund-abund, ord=1)
    bc_distance = braycurtis(predicted_abund, abund)
    try:
        f1_score = 2*strain_precision*strain_recall/(strain_precision+strain_recall)
    except ZeroDivisionError:
        f1_score = 0
    return strain_precision, strain_recall, l1_dist, l2_dist, bc_distance, f1_score   

def strain_predicted_and_real(predicted_strain_data, true_strain_data, genomes_info):
    true_strain = true_strain_data["genome_ID"].tolist()
    predicted_strain = predicted_strain_data["genome_ID"].tolist()
    true_predict_strain_num = len(set(true_strain) & set(predicted_strain))
    database_strain = genomes_info["genome_ID"].tolist()
    true_database_strain_num = len(set(true_strain) & set(database_strain))
    return true_predict_strain_num, true_database_strain_num

def aupr_cal(predicted_strain_data, true_strain_data):
    true_strain = true_strain_data["genome_ID"].tolist()
    predicted_strain = predicted_strain_data["genome_ID"].tolist()
    predicted_abund = predicted_strain_data["predicted_abundance"].tolist()
    # predicted_strain_one_hot = []
    # for predicted in predicted_strain:
    #     if predicted in true_strain:
    #         predicted_strain_one_hot.append(1)
    #     else:
    #         predicted_strain_one_hot.append(0)
    # precision, recall, thresholds = precision_recall_curve(np.array(predicted_strain_one_hot), np.array(predicted_abund))
    # aupr = auc(recall, precision)
    # print(len(predicted_strain_one_hot))
    # print(len(recall), len(precision))
    # print(f"recall:{recall}")
    # print(f"precision:{precision}")
    # print(f"thresholds:{thresholds}")
    # plt.plot(recall, precision, color='b', lw=2, label=f'AUPR_sk = {aupr:.2f}')
    # plt.xlabel('Recall')
    # plt.ylabel('Precision')
    # plt.ylim([0.0, 1.05])
    # plt.xlim([0.0, 1.0])
    # plt.title('Precision-Recall Curve')
    # plt.legend(loc='lower left')
    # plt.show()

    precision_list = []
    recall_list = []
    for i in range(len(predicted_strain), 0, -1):
        predicted_positive = predicted_strain[:i]
        true_positive = len(set(predicted_positive) & set(true_strain))
        precision = true_positive/len(predicted_positive) if len(predicted_positive) > 0 else 0
        recall = true_positive/len(true_strain) if len(true_strain) > 0 else 0
        if i == len(predicted_strain) and recall != 1:
            precision_list.append(0)
            recall_list.append(recall)
            precision_list.append(precision)
            recall_list.append(recall)
        else:
            precision_list.append(precision)
            recall_list.append(recall)
    if recall_list[-1] != 0:
        recall_list.append(0)
        precision_list.append(precision_list[-1])
    # if recall_list[0] != 1:
    #     recall_list.append(1)
    #     precision_list.insert(0, precision_list[0])
    aupr2 = abs(np.trapz(precision_list, recall_list))
    # print(f"recall_list:{recall_list}")
    # print(f"precision_list:{precision_list}")
    # plt.plot(recall_list, precision_list, color='b', lw=2, label=f'AUPR = {aupr2:.2f}')
    # plt.xlabel('Recall')
    # plt.ylabel('Precision')
    # plt.ylim([0.0, 1.05])
    # plt.xlim([0.0, 1.0])
    # plt.title('Precision-Recall Curve')
    # plt.legend(loc='lower left')
    # plt.show()
    # plt.savefig('precision_recall_curve_as_m.png')
    return aupr2

def AFE_RFE_cal(predicted_strain_data, true_strain_data):
    merge_df = pd.merge(true_strain_data, predicted_strain_data, how="left", on="genome_ID")
    merge_df.loc[:, "predicted_abundance"] = merge_df["predicted_abundance"].fillna(0)
    AFE = abs(merge_df["true_abundance"]-merge_df["predicted_abundance"]).mean()
    RFE = (abs(merge_df["true_abundance"]-merge_df["predicted_abundance"])/merge_df["true_abundance"]).mean()
    return AFE, RFE


if __name__ == "__main__":
    sys.exit(main())