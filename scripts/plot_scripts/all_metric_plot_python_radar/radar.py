

import matplotlib.pyplot as plt
import numpy as np
import sys
import pandas as pd
from math import pi

def radar_chart2(file_path, plot_label, output_file_path, row=1, col=1, idx=0, legend=False, get_legend=False, all_ran_tools=None, noisy_long=False):
    data = pd.read_csv(file_path, sep="\t")
    if all_ran_tools:
        data["tool_name"] = data["tool_name"].replace('PanTax(fast)', 'PanTax (fast)')
        data = data[data.iloc[:,0].isin(all_ran_tools)]
        # print(data)
    if "single_species" in output_file_path:
        data = data.drop(columns=data.columns[np.r_[1, 6:9]])
    else:
        data = data.drop(columns=data.columns[np.r_[1:4, 8:11]])
    data.columns = ["Tools", "Precision", "Recall", "F1", "AUPR", "1-L1", "1-BC"]
    cols = data.columns.tolist()
    cols.insert(1, cols.pop(cols.index('F1')))
    data = data[cols] 
    data = data[data["Tools"] != "Centrifuge"]
    data["Tools"] = data["Tools"].replace("PanTax(fast)", "PanTax (fast)")
    data = data[~data.apply(lambda row: row.astype(str).str.contains("-").any() or row.isna().any(), axis=1)]
    data.iloc[:, 1:] = data.iloc[:, 1:].apply(pd.to_numeric)

    data[["1-L1", "1-BC"]] = 1 - data[["1-L1", "1-BC"]]
    data = data.iloc[::-1].reset_index(drop=True)
    min_value = data.iloc[:, 1:].min().min()
    max_value = data.iloc[:, 1:].max().max()
    if min_value > 0: min_value = 0
    if max_value < 1: 
        max_value = 1
    elif max_value == 1:
        max_value = 1.05
    all_tools = ["PanTax", "PanTax (fast)", "Kraken2", "Bracken", "KMCP", "Ganon", "Centrifuger", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"]
    marker_list = ['o', 's', '^', 'D', 'v', 'P', '*', 'X', '<', '>', 'H']
    color_list = ['r', 'b', 'g', 'm', 'c', 'y', 'k', 'orange', '#FFCC00', '#98694E', '#4E76B4']
    tool_styles = {tool: {'marker': marker_list[i], 'color': color_list[i]} for i, tool in enumerate(all_tools)}
    tools = data["Tools"].tolist()
    feature = data.columns[1:].tolist()
    value_list = []
    for i in range(len(tools)):
        values = data.loc[i].drop('Tools').values.flatten().tolist()
        value_list.append(values)
    angles=np.linspace(0, 2*np.pi,len(feature), endpoint=False)
    angles=np.concatenate((angles,[angles[0]]))
    # plt.rcParams['svg.fonttype'] = 'none'
    plt.rcParams['pdf.fonttype'] = 42
    plt.rcParams['ps.fonttype'] = 42
    # plt.rcParams['font.family'] = 'serif'
    plt.rc('font',family='Times New Roman')
    plt.style.use('ggplot')
    if idx == 0:
        fig=plt.figure(figsize=(4,4))
        ax = fig.add_subplot(111, polar=True)
    else:
        ax = plt.subplot(row, col ,idx, polar=True)
    for i, values in enumerate(value_list):
        values=np.concatenate((values,[values[0]]))
        style = tool_styles.get(tools[i], {'marker': 'o', 'color': 'gray'})
        ax.plot(angles, values, linewidth=2, label=tools[i], marker = style['marker'], color = style['color'])
        # ax.fill(angles, values, alpha=0.25)

    ax.set_thetagrids(np.degrees(angles[:-1]), labels=feature, fontsize=20, color='black', rotation=0)
    ax.tick_params(pad=20)
    ax.set_yticks([0.2, 0.4, 0.6, 0.8, 1.0])
    ax.set_yticklabels(["0.2", "0.4", "0.6", "0.8", "1.0"], color="black", size=13)

    ax.set_ylim(min_value, max_value)
    if "simhigh_gtdb" in output_file_path:
        title_size = 24
    if "base_mut" in output_file_path and not noisy_long:
        title_size = 24    
    else:
        title_size = 28
    plt.title(plot_label, size=title_size, color="black", y=1.2, fontweight='bold')
    if legend:
        # plt.legend(loc='upper right', bbox_to_anchor=(1.8, 1.1), fontsize=13, facecolor='w')
        plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.5), fontsize=13, facecolor='w', edgecolor="w", ncol=4)

    if idx == 0:
        plt.savefig(output_file_path + "_" + plot_label.replace(" ", "") + ".pdf", dpi=300, bbox_inches='tight')

    if get_legend:
        return ax
    else:
        return None

def get_all_ran_tools(file_paths):
    all_ran_tools = []
    for file_path in file_paths:
        data = pd.read_csv(file_path, sep="\t")
        tools = data.iloc[:,0].tolist()
        tools = [tool for tool in tools if tool != "Centrifuge"]
        all_ran_tools.extend(tools)
    all_ran_tools = list(set(all_ran_tools))
    all_ran_tools = [tool.replace('PanTax(fast)', 'PanTax (fast)') for tool in all_ran_tools]
    return all_ran_tools

def single_plot(file_paths, plot_labels, output_file_path, row_plots_num, col_plots_num, noisy_long=False):
    if not noisy_long:
        remove_noisy_long_file_paths = []
        remove_noisy_long_labels = []
        for file_path in file_paths:
            if "R9" not in file_path and "clr" not in file_path:
                remove_noisy_long_file_paths.append(file_path)
        for label in plot_labels:
            if "R9" not in label and "CLR" not in label:
                remove_noisy_long_labels.append(label)
        file_paths = remove_noisy_long_file_paths
        plot_labels = remove_noisy_long_labels
    print(file_paths)
    print(plot_labels)
    all_tools = ["PanTax", "PanTax (fast)", "Kraken2", "Bracken", "KMCP", "Ganon", "Centrifuger", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"]
    fig1 = plt.figure(figsize=(5,5))
    all_ran_tools = get_all_ran_tools(file_paths)
    print(all_ran_tools)
    ax1 = radar_chart2("report/example_all_tools.tsv", "all", "legend", row=1, col=1, idx=1, legend=True, get_legend=True, all_ran_tools=all_ran_tools, noisy_long=False)
    if not noisy_long:
        if "mut" in output_file_path:
            fig2 = plt.figure(figsize=(col_plots_num*4.2+2,row_plots_num*3+4))
        elif "zymo1" in output_file_path:
            fig2 = plt.figure(figsize=(col_plots_num*3.3+2,row_plots_num*3.3+2))
        else:
            fig2 = plt.figure(figsize=(col_plots_num*5+2,row_plots_num*5+2))
    else:
        if "mut" in output_file_path:
            fig2 = plt.figure(figsize=(col_plots_num*5+2,row_plots_num*5+4))
        else:
            fig2 = plt.figure(figsize=(col_plots_num*5+2,row_plots_num*5+2))
    # plt.subplots_adjust(hspace=0.1,wspace=0.1)
    for i in range(len(file_paths)):
        radar_chart2(file_paths[i], plot_labels[i], output_file_path, row=row_plots_num, col=col_plots_num, idx=i+1)
    plt.tight_layout()
    handles, labels = ax1.get_legend_handles_labels()
    tool_to_handle = dict(zip(labels, handles))
    sorted_handles = [tool_to_handle[tool] for tool in all_tools if tool in tool_to_handle]
    sorted_labels = [tool for tool in all_tools if tool in tool_to_handle]   
    if "zymo1" in output_file_path:
        legend_len = 4
    elif not noisy_long:
        legend_len = 4
    else:
        legend_len = len(all_ran_tools)
    if ("zymo1" in output_file_path or "single_species" in output_file_path) and noisy_long:
        lenged_markerscale = 3
        legend_fontsize = 20
        lenged_handlelength = 2
    elif noisy_long:
        lenged_markerscale = 4
        legend_fontsize = 24
        lenged_handlelength = 3  
    elif "zymo1" in output_file_path and not noisy_long:
        lenged_markerscale = 3
        legend_fontsize = 15
        lenged_handlelength = 2         
    elif "base_mut" in output_file_path and not noisy_long:
        lenged_markerscale = 3
        legend_fontsize = 20
        lenged_handlelength = 2         
    elif not noisy_long:
        lenged_markerscale = 4
        legend_fontsize = 24
        lenged_handlelength = 3  

    if not noisy_long and "base_mut" not in output_file_path:
        legend_vertical = -0.15
    elif "base_mut" in output_file_path:
        legend_vertical = -0.1
    else:
        legend_vertical = -0.05
    fig2.legend(sorted_handles, sorted_labels, loc='lower center', ncol=legend_len, bbox_to_anchor=(0.5, legend_vertical), frameon=False, fontsize=legend_fontsize, markerscale=lenged_markerscale, handlelength=lenged_handlelength, labelspacing=1.5)    
    plt.savefig(output_file_path + "_python_radar.pdf", dpi=300, bbox_inches='tight')

def plot():
    
    # file_paths = ["report/simlow/ngs.tsv", "report/simlow/hifi.tsv", "report/simlow/clr.tsv", 
    #                  "report/simlow/ontR9.tsv", "report/simlow/ontR10.tsv", 
    #                  "report/simhigh/ngs.tsv", "report/simhigh/hifi.tsv", "report/simhigh/clr.tsv",
    #                   "report/simhigh/ontR9.tsv", "report/simhigh/ontR10.tsv"]
    # plot_labels = ["sim-low NGS", "sim-low PacBio HiFi", "sim-low PacBio CLR", "sim-low ONT R9.4.1", "sim-low ONT R10.4",
    #                  "sim-high NGS", "sim-high PacBio HiFi", "sim-high PacBio CLR", "sim-high ONT R9.4.1", "sim-high ONT R10.4"]
    # output_file_path = "report/plots/base"
    # single_plot(file_paths, plot_labels, output_file_path, 2, 3)

    file_paths_gtdb = ["report/simhigh-gtdb/ngs.tsv", "report/simhigh-gtdb/hifi.tsv", "report/simhigh-gtdb/clr.tsv",
                        "report/simhigh-gtdb/ontR9.tsv", "report/simhigh-gtdb/ontR10.tsv"]
    dataset_label_gtdb = ["sim-high-gtdb NGS", "sim-high-gtdb PacBio HiFi", "sim-high-gtdb PacBio CLR", "sim-high-gtdb ONT R9.4.1", "sim-high-gtdb ONT R10.4"]
    output_file_path = "report/plots/simhigh_gtdb"
    single_plot(file_paths_gtdb, dataset_label_gtdb, output_file_path, 1, 3)

    # file_paths_spiked_in_eight = ["report/spiked_in_eight_species666_large_pangenome/ngs.tsv", 
    #                                 "report/spiked_in_eight_species666_large_pangenome/hifi.tsv", 
    #                                 "report/spiked_in_eight_species666_large_pangenome/clr.tsv", 
    #                                 "report/spiked_in_eight_species666_large_pangenome/ontR9.tsv", 
    #                                 "report/spiked_in_eight_species666_large_pangenome/ontR10.tsv"]
    # dataset_label_spiked_in = ["spiked-in NGS", "spiked-in PacBio HiFi", "spiked-in PacBio CLR", "spiked-in ONT R9.4.1", "spiked-in ONT R10.4"]
    # output_file_path = "report/plots/spiked_in"
    # single_plot(file_paths_spiked_in_eight, dataset_label_spiked_in, output_file_path, 1, 3)

    # file_paths_zymo1 = ["report/zymo1/ngs.tsv", "report/zymo1/ontR9.tsv", "report/zymo1/ontR10.tsv"]
    # dataset_label_zymo1 = ["Zymo1 NGS", "Zymo1 ONT R9.4.1", "Zymo1 ONT R10"]
    # output_file_path = "report/plots/zymo1"
    # single_plot(file_paths_zymo1, dataset_label_zymo1, output_file_path, 1, 2)

    # file_paths_single_species_multi_strains = ["report/3strains/3strains.tsv", 
    #                                             "report/5strains/5strains.tsv", 
    #                                             "report/10strains/10strains.tsv"]
    # dataset_label_single_species_multi_strains = ["3 strains", "5 strains", "10 strains"]
    # output_file_path = "report/plots/single_species_multi_strains"
    # single_plot(file_paths_single_species_multi_strains, dataset_label_single_species_multi_strains, output_file_path, 1, 3)

    # file_paths = ["report/simlow-sub0.001/ngs.tsv", "report/simlow-sub0.001/hifi.tsv", "report/simlow-sub0.001/clr.tsv", 
    #               "report/simlow-sub0.001/ontR9.tsv", "report/simlow-sub0.001/ontR10.tsv", 
    #               "report/simhigh-sub0.001/ngs.tsv", "report/simhigh-sub0.001/hifi.tsv", "report/simhigh-sub0.001/clr.tsv",
    #               "report/simhigh-sub0.001/ontR9.tsv", "report/simhigh-sub0.001/ontR10.tsv",
    #               "report/simlow-sub0.01/ngs.tsv", "report/simlow-sub0.01/hifi.tsv", "report/simlow-sub0.01/clr.tsv", 
    #               "report/simlow-sub0.01/ontR9.tsv", "report/simlow-sub0.01/ontR10.tsv", 
    #               "report/simhigh-sub0.01/ngs.tsv", "report/simhigh-sub0.01/hifi.tsv", "report/simhigh-sub0.01/clr.tsv",
    #               "report/simhigh-sub0.01/ontR9.tsv", "report/simhigh-sub0.01/ontR10.tsv",]
    # plot_labels = ["sim-low-mut1 NGS", "sim-low-mut1 PacBio HiFi", "sim-low-mut1 PacBio CLR", "sim-low-mut1 ONT R9.4.1", "sim-low-mut1 ONT R10.4",
    #                "sim-high-mut1 NGS", "sim-high-mut1 PacBio HiFi", "sim-high-mut1 PacBio CLR", "sim-high-mut1 ONT R9.4.1", "sim-high-mut1 ONT R10.4",
    #                "sim-low-mut2 NGS", "sim-low-mut2 PacBio HiFi", "sim-low-mut2 PacBio CLR", "sim-low-mut2 ONT R9.4.1", "sim-low-mut2 ONT R10.4",
    #                "sim-high-mut2 NGS", "sim-high-mut2 PacBio HiFi", "sim-high-mut2 PacBio CLR", "sim-high-mut2 ONT R9.4.1", "sim-high-mut2 ONT R10.4"]
    # output_file_path = "report/plots/base_mut"
    # single_plot(file_paths, plot_labels, output_file_path, 4, 3)

def main():
    # file_path = "report/simlow/ngs.tsv"
    # plot_label = "sim-low NGS"
    # output_file_path = "report/plots/base"
    # file_path2 = "report/simhigh/ngs.tsv"
    # plot_label2 = "sim-high NGS"

    # plt.figure(figsize=(10,10))
    # radar_chart2(file_path, plot_label, output_file_path, row=1, col=2, idx=1)
    # radar_chart2(file_path2, plot_label2, output_file_path, row=1, col=2, idx=2)
    # plt.tight_layout()
    plot()


if __name__ == '__main__':
    sys.exit(main())