import argparse, os, sys
import pandas as pd
import numpy as np
import warnings
from scipy.spatial.distance import braycurtis
warnings.filterwarnings("ignore", category=DeprecationWarning)

# import matplotlib.pyplot as plt
# from sklearn.metrics import precision_recall_curve, auc

def long_read_abundance_estimation(read_cls_file, read_length_file, genome_length_file, output_path="./"):
    readinfo=pd.read_csv(read_length_file, sep="\t", header=None, usecols=[0,1])
    readinfo.columns = ["readID", "readLen"]
    try:
        mapinfo=pd.read_csv(read_cls_file, sep="\t", header=None, usecols=[0,2],dtype=object)
    except:
        mapinfo=pd.read_csv(read_cls_file, sep=" ", header=None, usecols=[0,2],dtype=object)
    mapinfo.columns = ["readID","spyID"]
    # In some cases, it may be possible to delete some reads to prevent errors or prolonged running(vg giraffe)
    read_cls = pd.merge(mapinfo, readinfo, on='readID')
    assert len(read_cls) == len(mapinfo)
    read_cls = read_cls.sort_values(by='readID')
    read_cls = read_cls.drop_duplicates(subset='readID', keep='first')
    read_cls.to_csv(os.path.join(output_path, "read_cls_uniq.txt"), index=False, sep="\t",header=True)

    read_cls.loc[:, "spyID"] = read_cls["spyID"].fillna("0")
    read_cls = read_cls[~(read_cls[["spyID"]] == "0").any(axis=1)]
    result_df = read_cls.groupby('spyID', as_index=False).agg({'readLen': lambda x: list(x), 'readID': lambda x: list(x)})
    result_df['spyReads_Len'] = result_df['readLen'].apply(sum)
    result_df = pd.DataFrame(result_df)
    
    genome_len = pd.read_csv(genome_length_file, header=None, sep="\t",dtype={0:str,1:float})
    genome_len.columns = ["spyID", "mean_genome_length"]
    new_result_df = pd.merge(result_df, genome_len, on='spyID')
    assert len(new_result_df) == len(result_df)
    new_result_df = new_result_df.iloc[ : ,[0,3,4] ]
    
    new_result_df['coverage'] = new_result_df['spyReads_Len'] / new_result_df['mean_genome_length']
    new_result_df['abundance'] = new_result_df['coverage'] / new_result_df['coverage'].sum()
    new_result_df = new_result_df.sort_values(by="abundance", ascending=False)
    new_result_df = new_result_df[["spyID", "abundance"]]
    new_result_df.columns = ["taxonomy", "abundance"]
    new_result_df.to_csv(os.path.join(output_path, "abundance.txt"), index=False, header=True, sep="\t")
    return os.path.join(output_path, "read_cls_uniq.txt"), os.path.join(output_path, "abundance.txt")

class PrecisionRecall:
    def __init__(self, read_cls_path, camisim_reads_mapping_path, predicted_abund_path, true_abund_path):
        self.read_cls_path = read_cls_path
        self.camisim_reads_mapping_path = camisim_reads_mapping_path
        self.predicted_species_abund_path = predicted_abund_path
        self.true_species_abund_path = true_abund_path

    def merge(self, strain2species_taxid=None):
        read_cls = pd.read_csv(self.read_cls_path, sep="\t", usecols=[0,1], dtype=object)
        read_cls.columns = ["#anonymous_read_id", "predicted_taxid"]
        #print(read_cls.head())
        # It seems that the strains in the camisim mapping file may not necessarily correspond to the species. Retrieve the species taxid corresponding to the strains again
        if strain2species_taxid:
            camisim_reads_mapping = pd.read_csv(self.camisim_reads_mapping_path, sep="\t", usecols=[0,1],dtype=object)
            strain2species_taxid_df = pd.read_csv(strain2species_taxid, sep="\t", dtype=object)
            strain2species_taxid_df.columns = ["genome_id", "tax_id"]
            readID2species_taxid = pd.merge(camisim_reads_mapping,strain2species_taxid_df,how="left",on="genome_id")
            camisim_reads_mapping = readID2species_taxid.drop(columns=["genome_id"])
        else:
            camisim_reads_mapping = pd.read_csv(self.camisim_reads_mapping_path, sep="\t", usecols=[0,2],dtype=object)
        # print(camisim_reads_mapping.head())
        # print(read_cls.head())
        merge_df = pd.merge(camisim_reads_mapping, read_cls, how="outer", on="#anonymous_read_id")
        print(len(camisim_reads_mapping), len(read_cls), len(merge_df))
        # print(merge_df.head())
        assert len(merge_df) == len(camisim_reads_mapping)
        return merge_df

    def reads_level_cal(self, merge_df):
        merge_df.loc[:, "predicted_taxid"] = merge_df["predicted_taxid"].fillna("0")
        # merge_df.loc[:, "tax_id"] = merge_df["tax_id"].astype(int).astype(str)
        correct_predictions = len(merge_df[merge_df["tax_id"] == merge_df["predicted_taxid"]])
        reads_mapped = (merge_df["predicted_taxid"] != "0").sum()
        true_reads = len(merge_df)
        reads_precision = correct_predictions/reads_mapped
        reads_recall = correct_predictions/true_reads
        return reads_precision, reads_recall
    
    def species_level_cal(self, threshold=0):
        predicted_data = pd.read_csv(self.predicted_species_abund_path, sep="\t", dtype={0:str,1:float})
        predicted_data = predicted_data[predicted_data.iloc[:, 1] != 0]
        predicted_species = predicted_data.iloc[:,0].tolist()
        predicted_abund = predicted_data.iloc[:,1].tolist()
        true_species_data = pd.read_csv(self.true_species_abund_path, sep="\t", usecols=[0],dtype=object)
        true_species = true_species_data.iloc[:, 0].tolist()
        predicted_positive = [species for species, abundance in zip(predicted_species, predicted_abund) if abundance > threshold]
        true_positive = len(set(predicted_positive) & set(true_species))
        species_precision = true_positive/len(predicted_positive) if len(predicted_positive) > 0 else 0
        species_recall = true_positive/len(true_species) if len(true_species) > 0 else 0
        f1_score = 2*species_precision*species_recall/(species_precision+species_recall)
        return species_precision, species_recall, f1_score


    def AUPR_plot(self):
        predicted_data = pd.read_csv(self.predicted_species_abund_path, sep="\t", dtype={0:str,1:float})
        predicted_data = predicted_data[predicted_data.iloc[:, 1] != 0]
        predicted_species = predicted_data.iloc[:,0].tolist()
        predicted_abund = predicted_data.iloc[:,1].tolist()
        true_species_data = pd.read_csv(self.true_species_abund_path, sep="\t", usecols=[0],dtype=object)
        true_species = true_species_data.iloc[:, 0].tolist()
        ## abundunce cutoff (all possible cutoff)
        precision_list = []
        recall_list = []
        min_abund = min(predicted_abund)
        max_abund = max(predicted_abund)
        for threshold in np.linspace(min_abund, max_abund, 1000):
            predicted_positive = [species for species, abundance in zip(predicted_species, predicted_abund) if abundance >= threshold]
            true_positive = len(set(predicted_positive) & set(true_species))
            precision = true_positive/len(predicted_positive) if len(predicted_positive) > 0 else 0
            recall = true_positive/len(true_species) if len(true_species) > 0 else 0
            precision_list.append(precision)
            recall_list.append(recall)
        if recall_list[-1] != 0:
            recall_list.append(0)
            precision_list.append(precision_list[-1])
        if recall_list[0] != 1:
            recall_list.append(1)
            precision_list.insert(0, precision_list[0])
        aupr1 = abs(np.trapz(precision_list, recall_list))
        # plt.figure()
        # plt.plot(recall_list, precision_list, color='b', lw=2, label=f'AUPR = {aupr1:.2f}')
        # plt.xlabel('Recall')
        # plt.ylabel('Precision')
        # plt.ylim([0.0, 1.05])
        # plt.xlim([0.0, 1.0])
        # plt.title('Precision-Recall Curve')
        # plt.legend(loc='lower left')
        # plt.savefig('precision_recall_curve_ac.png')

        # base on sklearn is similar with species cutoff
        # predicted_species_one_hot = []
        # for predicted_sp in predicted_species:
        #     if predicted_sp in true_species:
        #         predicted_species_one_hot.append(1)
        #     else:
        #         predicted_species_one_hot.append(0)
        # precision, recall, thresholds = precision_recall_curve(np.array(predicted_species_one_hot), np.array(predicted_abund))
        # print(precision)
        # print(recall)
        # print(len(thresholds))
        # aupr = auc(recall, precision)
        # plt.plot(recall, precision, color='b', lw=2, label='Precision-Recall curve')
        # plt.xlabel('Recall')
        # plt.ylabel('Precision')
        # plt.ylim([0.0, 1.05])
        # plt.xlim([0.0, 1.0])
        # plt.title('Precision-Recall Curve')
        # plt.legend(loc='lower left')
        # plt.show()

        ## species cutoff
        precision_list = []
        recall_list = []
        for i in range(len(predicted_species), 0, -1):
            predicted_positive = predicted_species[:i]
            true_positive = len(set(predicted_positive) & set(true_species))
            precision = true_positive/len(predicted_positive) if len(predicted_positive) > 0 else 0
            recall = true_positive/len(true_species) if len(true_species) > 0 else 0
            if i == len(predicted_species) and recall != 1:
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
        aupr2 = abs(np.trapz(precision_list, recall_list))  
        # try:
        #     assert aupr == aupr2 
        # except:     
        #     print(f"aupr:{aupr}, aupr2:{aupr2}\n") 
        # plt.figure()                  
        # plt.plot(recall_list, precision_list, color='b', lw=2, label=f'AUPR = {aupr2:.2f}')
        # plt.xlabel('Recall')
        # plt.ylabel('Precision')
        # plt.ylim([0.0, 1.05])
        # plt.xlim([0.0, 1.0])
        # plt.title('Precision-Recall Curve')
        # plt.legend(loc='lower left') 
        # plt.savefig('precision_recall_curve_as_2.png')
        return aupr1, aupr2
    
    def l2_dist(self):
        predicted_data = pd.read_csv(self.predicted_species_abund_path, sep="\t", usecols=[0,1], dtype={0:str,1:float})
        predicted_data = predicted_data[predicted_data.iloc[:, 1] != 0]
        predicted_data.columns = ["NCBI_ID", "predict_abundance"]
        true_species_data = pd.read_csv(self.true_species_abund_path, sep="\t", dtype={0:str,1:float})
        merge_df = pd.merge(predicted_data, true_species_data, how="outer", on="NCBI_ID")
        merge_df.loc[:, "predict_abundance"] = merge_df["predict_abundance"].fillna(0)
        merge_df.loc[:, "abundance"] = merge_df["abundance"].fillna(0)
        predicted_abund = np.array(merge_df["predict_abundance"].tolist())
        abund = np.array(merge_df["abundance"].tolist())
        l2_dist = np.linalg.norm(predicted_abund-abund)
        l1_dist = np.linalg.norm(predicted_abund-abund, ord=1)
        bc_dist = braycurtis(predicted_abund, abund)
        merge_df = pd.merge(true_species_data, predicted_data, how="left", on="NCBI_ID")
        merge_df.loc[:, "predict_abundance"] = merge_df["predict_abundance"].fillna(0)
        AFE = abs(merge_df["abundance"]-merge_df["predict_abundance"]).mean()
        RFE = (abs(merge_df["abundance"]-merge_df["predict_abundance"])/merge_df["abundance"]).mean()
        return l2_dist, AFE, RFE, l1_dist, bc_dist

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="python metrics_eval.py")
    parser.add_argument("-i", "--read_cls_path", dest="read_cls_path",type=str, help="read classification file")
    parser.add_argument("-t", "--tool", dest="tool",type=str, help="Tools name(lower case)")
    parser.add_argument("-rt", "--read_type", dest="read_type", type=str, help="long/short")
    parser.add_argument("-s", "--samplesID", dest='samplesID', type=str, help="samplesID.")
    parser.add_argument("-e", "--threshold", dest="threshold", default=1e-04, type=int, help="abundance threshold")
    parser.add_argument("-dt", "--data_type", dest="data_type", type=int, help="30(species)/1000(strains)")
    parser.add_argument("-pa", "--predicted_abund_path", dest="predicted_abund_path", default="species_abundance.txt", type=str, help="predicted abundance file")
    parser.add_argument("-ta", "--true_abund_path", dest="true_abund_path", default="true_species_abundance.txt", type=str, help="true abundance file")
    parser.add_argument("-m", "--camisim_reads_mapping_path", dest="camisim_reads_mapping_path", default=None, type=str, help="camisim reads mapping path")
    ## for long read
    parser.add_argument("-rl", "--read_length", dest='read_length', type=str, help="Input file for read length.")
    parser.add_argument("-gl", "--genome_length", dest='genome_length', type=str, help="Input file for genome length.")
    args = parser.parse_args()
    read_cls_path = args.read_cls_path
    predicted_abund_path = args.predicted_abund_path
    if args.camisim_reads_mapping_path:
        camisim_reads_mapping_path = args.camisim_reads_mapping_path
    else:
        if args.read_type == "short":
            if args.data_type == 30:
                # camisim_reads_mapping_path = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/pggb_vg/big_sample/camisim_simulate/60_genome_simulate_result/2023.11.25_22.07.21_sample_0/reads/reads_mapping.tsv"
                camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/short_read/30_species/sim-30species-ngs/2024.02.02_23.36.27_sample_0/reads/reads_mapping.tsv"
            elif args.data_type == 1000:
                # camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000_strains_ngs/2024.01.24_11.27.18_sample_0/reads/reads_mapping.tsv"
                camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/short_read/1000strains/1000_strains_ge1_ngs/2024.02.03_21.19.31_sample_0/reads/reads_mapping.tsv"
            elif args.data_type == 0:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/madness_dataset/short_read/2018.09.07_11.43.52_sample_0/reads/reads_mapping.tsv"
            elif args.data_type == 3:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/2nd_HMP/Gastrointestinal_tract/2017.12.04_18.45.54_sample_0/reads/reads_mapping.tsv"
            elif args.data_type == 4:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/toy_mouse_gut/2017.12.29_11.37.26_sample_0/reads/reads_mapping.tsv"
            elif args.data_type == 5:
                camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/short_read/30species_low/sim-30species-low-ngs/2024.02.28_14.57.25_sample_0/reads/reads_mapping.tsv"
            else:
                # just the role of placeholder
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/madness_dataset/short_read/2018.09.07_11.43.52_sample_0/reads/reads_mapping.tsv"
        elif args.read_type == "long":
            if args.data_type == 30:
                if args.samplesID == "hifi":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-hifi-ge1/2024.02.02_23.37.51_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "clr":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-CLR-ge1/2024.02.03_01.07.37_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR104":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR104raw-ge1/2024.02.03_00.36.03_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR941":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR941raw-ge1/2024.02.08_00.51.21_sample_0/reads/reads_mapping.tsv.gz"
            elif args.data_type == 305:
                if args.samplesID == "ontR104":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR104raw-ge1/2024.02.03_00.36.03_sample_0/reads/subsample5_read_mapping.tsv"
                elif args.samplesID == "hifi":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-hifi-ge1/2024.02.02_23.37.51_sample_0/reads/subsample5_read_mapping.tsv"
                elif args.samplesID == "clr":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-CLR-ge1/2024.02.03_01.07.37_sample_0/reads/subsample5_read_mapping.tsv"
                elif args.samplesID == "ontR941":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR941raw-ge1/2024.02.08_00.51.21_sample_0/reads/subsample5_read_mapping.tsv"


            elif args.data_type == 301:
                if args.samplesID == "ontR104":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR104raw-ge1/2024.02.03_00.36.03_sample_0/reads/subsample1_read_mapping.tsv"
                elif args.samplesID == "hifi":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-hifi-ge1/2024.02.02_23.37.51_sample_0/reads/subsample1_read_mapping.tsv"
                elif args.samplesID == "clr":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-CLR-ge1/2024.02.03_01.07.37_sample_0/reads/subsample1_read_mapping.tsv"
                elif args.samplesID == "ontR941":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species/sim-30species-ontR941raw-ge1/2024.02.08_00.51.21_sample_0/reads/subsample1_read_mapping.tsv"
                

            elif args.data_type == 1000:
                if args.samplesID == "hifi":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-hifi/2024.02.04_21.23.26_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "clr":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-CLR/2024.02.03_21.18.55_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR104":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR104raw/2024.02.04_16.11.39_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR941":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/new_1000strains/sim-1000strains-ge1-ontR941raw/2024.06.08_23.57.40_sample_0/reads/reads_mapping.tsv.gz"
            elif args.data_type == 5:
                if args.samplesID == "hifi":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species_low/sim-30species-hifi-low/2024.06.27_22.00.01_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "clr":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species_low/sim-30species-clr-low/2024.06.27_21.07.47_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR104":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species_low/sim-30species-ontR10-low/2024.06.27_21.24.30_sample_0/reads/reads_mapping.tsv.gz"
                elif args.samplesID == "ontR941":
                    camisim_reads_mapping_path = "/home/work/wenhai/simulate_genome_data/PanTax/long_read/30_species_low/sim-30species-ontR9-low/2024.06.27_21.40.24_sample_0/reads/reads_mapping.tsv.gz"

            elif args.data_type == 0:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/madness_dataset/long_read/2018.09.20_11.17.07_sample_0/reads/reads_mapping.tsv.gz"
            elif args.data_type == 3:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/2nd_HMP/Gastrointestinal_tract_long/2018.01.23_11.53.11_sample_0/reads/reads_mapping.tsv.gz"
            elif args.data_type == 4:
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/toy_mouse_gut/2017.12.29_11.37.26_sample_0/reads/reads_mapping.tsv"
            else:
                # just the role of placeholder
                camisim_reads_mapping_path = "/home/work/wenhai/dataset/cami/madness_dataset/short_read/2018.09.07_11.43.52_sample_0/reads/reads_mapping.tsv"

    if args.read_type == "long" and read_cls_path != "-":
        read_cls_path, predicted_abund_path = long_read_abundance_estimation(read_cls_path, args.read_length, args.genome_length)
    precision_recall = PrecisionRecall(read_cls_path, camisim_reads_mapping_path, predicted_abund_path, args.true_abund_path)
    # if args.data_type != 1 and args.data_type != 8 and args.tool != "bracken" and args.tool != "sylph":
    #     if args.data_type == 3:
    #         strain2species_taxid = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208/tool/pantax/species_level/Gastrointestinal_tract/strain2species_taxid_df.txt"
    #         merge_df = precision_recall.merge(strain2species_taxid)
    #     elif args.data_type == 4:
    #         strain2species_taxid = "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208/tool/pantax/species_level/mouse_gut/strain2species_taxid_df.txt"
    #         merge_df = precision_recall.merge(strain2species_taxid)                
    #     else:
    #         merge_df = precision_recall.merge()
    species_precision, species_recall, f1_score = precision_recall.species_level_cal(threshold=args.threshold)
    # if args.data_type != 1 and args.data_type != 8 and args.tool != "bracken" and args.tool != "sylph":
    #     reads_precision, reads_recall = precision_recall.reads_level_cal(merge_df)
    abund_aupr, species_aupr = precision_recall.AUPR_plot()
    l2_dist, AFE, RFE, l1_dist, bc_dist = precision_recall.l2_dist()
    # with open(os.path.join("./", "evaluation_report.txt"), "a") as file:
    #     print(f"{args.tool}\t{args.data_type}\t{args.samplesID}\tthreshold:{args.threshold}")
    #     if args.data_type != 1 and args.data_type != 8 and args.tool != "bracken" and args.tool != "sylph":
    #         print(f"tool\treads_precision\treads_recall\tspecies_precision\tspecies_recall\tf1_score\tspecies_aupr\tL2_distance\tAFE\tRFE")
    #         print("{} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} \t".format(args.tool, reads_precision, reads_recall, species_precision, species_recall, f1_score, species_aupr, l2_dist, AFE, RFE))
    #         print(f"{args.tool}\t{args.data_type}\t{args.samplesID}\tthreshold:{args.threshold}", file=file)
    #         print(f"tool\treads_precision\treads_recall\tspecies_precision\tspecies_recall\tf1_score\tspecies_aupr\tL2_distance\tAFE\tRFE", file=file)
    #         print("{} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} \t".format(args.tool, reads_precision, reads_recall, species_precision, species_recall, f1_score, species_aupr, l2_dist, AFE, RFE), file=file)
    #     else:
    #         print(f"tool\treads_precision\treads_recall\tspecies_precision\tspecies_recall\tf1_score\tspecies_aupr\tL2_distance\tAFE\tRFE")
    #         print("{} & - & - & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} \t".format(args.tool, species_precision, species_recall, f1_score, species_aupr, l2_dist, AFE, RFE))
    #         print(f"{args.tool}\t{args.data_type}\t{args.samplesID}\tthreshold:{args.threshold}", file=file)
    #         print(f"tool\treads_precision\treads_recall\tspecies_precision\tspecies_recall\tf1_score\tspecies_aupr\tL2_distance\tAFE\tRFE", file=file)
    #         print("{} & - & - & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} \t".format(args.tool, species_precision, species_recall, f1_score, species_aupr, l2_dist, AFE, RFE), file=file)

    print(f"{args.tool}\tthreshold:{args.threshold}")
    print(f"tool\tspecies_precision\tspecies_recall\tf1_score\tspecies_aupr\tAFE\tRFE\tL2_distance\tL1_dist\tbc_dist")
    print("{} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} & {:.3f} \n".format(args.tool, species_precision, species_recall, f1_score, species_aupr, AFE, RFE, l2_dist, l1_dist, bc_dist))