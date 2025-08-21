
"""
This script is used to generate latex table for different datasets and tools automatically
"""

import hydra, os, itertools, re, subprocess, copy
from omegaconf import OmegaConf
from utils import *
from pathlib import Path
import pandas as pd
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
script_path = Path(__file__).resolve()
script_dir = script_path.parent

sample_id_register = {
    "ngs": "NGS",
    "hifi": "PacBio HiFi",
    "clr": "PacBio CLR",
    "ontr9": "ONT R9.4.1",
    "ontr10": "ONT R10.4",
    "pacbio": "PacBio",    
    "ont": "ONT",
}

dataset_register_for_single_dataset = {
    "simlow": "sim-low",
    "simhigh": "sim-high",
    "simlow-sub0.001": "sim-low-mut1",
    "simhigh-sub0.001": "sim-high-mut1",
    "simlow-sub0.01": "sim-low-mut2",
    "simhigh-sub0.01": "sim-high-mut2",
    "zymo1": "Zymo1",
    "zymo1-log": "Zymo2",
    "spiked_in_eight_species666_large_pangenome": "spiked-in",
    "refdiv": "SimRef",
    "zymo1div": "Zymo1",
    "simlow-subsample0.2": "sim-low-sub2",
    "simlow-subsample0.5": "sim-low-sub1",
}

dataset_register = {
    "simulated datasets": ["simlow", "simhigh"],
    "simulated datasets mut0.001": ["simlow-sub0.001", "simhigh-sub0.001"],
    "simulated datasets mut0.01": ["simlow-sub0.01", "simhigh-sub0.01"],
    "zymo1": ["zymo1"],
    "spiked_in_strain_level_species666_large_pangenome": [],
}

single_species_dst_register = {
    "3strains": "3 strains",
    "5strains": "5 strains",
    "10strains": "10 strains",
}

def single_dataset_strain_get_metrics(config):
    wd = config.top_wd

    if config.mode == "simlow-sub0.01":
        tool_order = config.tool_order_for_sub001
    elif config.mode == "simlow-sub0.001":
        tool_order = config.tool_order_for_sub0001
    else:
        tool_order = config.tool_order
    tool_order_list = [tool for tool in tool_order]
    tool_dict_replace = True
    tool_dict = {tool.lower():tool for tool in tool_order}
    if config.get("version", None) and config.version == 2:
        pantax_eval_report_paths = list(Path(wd).rglob("pantax_" + config.report_name))
        eval_report_paths = list(Path(wd).rglob(config.report_name))
        eval_report_paths = [path for path in eval_report_paths if "pantax" not in str(path)]
        eval_report_paths = eval_report_paths + pantax_eval_report_paths
    else:
        eval_report_paths = list(Path(wd).rglob(config.report_name))
    if config.get("asm2prof_wd", None):
        eval_report_paths_asm = list(Path(config.asm2prof_wd).rglob(config.report_name))
        eval_report_paths = [path for path in eval_report_paths if "pantax" in str(path)]
        eval_report_paths.extend(eval_report_paths_asm)
        # print(eval_report_paths)
    # print(eval_report_paths)
    all_metrics = []
    for eval_report_path in eval_report_paths:
        # print(str(eval_report_path))
        if "dechat" in str(eval_report_path) or "old" in str(eval_report_path) or "test" in str(eval_report_path): continue
        if "sylph" in str(eval_report_path):            
            if all(x not in str(eval_report_path) for x in ["simlow", "simhigh", "zymo1"]): continue
            if "simlow-low" in str(eval_report_path): continue
        # if config.mode == "general":
        #     if "simlow-sub" in str(eval_report_path) or "sylph-pantax" in str(eval_report_path): continue
        # elif config.mode == "simlow-sub0.01" or config.mode == "simlow-sub0.001":
        #     if "simlow" not in str(eval_report_path): continue
        #     if "sylph-pantax" in str(eval_report_path): continue
        # elif config.mode == "sylph-pantax":
        #     if "simlow-sub" in str(eval_report_path) or "pantax" not in str(eval_report_path): continue
        if config.mode == "gtdb":
            if "gtdb" not in str(eval_report_path): continue
        elif config.mode == "subsample":
            if "subsample" not in str(eval_report_path): continue
            if "0.2" not in str(eval_report_path) and "0.5" not in str(eval_report_path): continue

            # if "0.3" in str(eval_report_path) or "0.4" in str(eval_report_path): continue
        elif config.mode == "general":
            if "gtdb" in str(eval_report_path): continue
            if "subsample" in str(eval_report_path): continue
            # if "sylph" in str(eval_report_path): continue
        elif config.mode == "zymo1":
            if "zymo" not in str(eval_report_path) or "sub" in str(eval_report_path) or "sylph" in str(eval_report_path): continue

        path_tokens = str(eval_report_path).split("/")
        sample_id = path_tokens[-2]
        dataset = path_tokens[-3]
        profile_level = path_tokens[-4]
        tool_name = path_tokens[-5]
        # if "simlow-sub" in config.mode:
        #     dataset_tokens = dataset.split("-")
        #     if len(dataset_tokens) == 2:
        #         tool_name = tool_name + "-" + dataset_tokens[1]
        #         dataset = dataset_tokens[0]
        if "mode" in dataset:
            dataset_tokens = dataset.split("_")
            # print(dataset_tokens)
            assert len(dataset_tokens) == 2
            if "mode0" in dataset:
                tool_name = "PanTax"
            elif "mode1" in dataset:
                tool_name = "PanTax (fast)"
            dataset = dataset_tokens[0]

        # reference diversity
        if "ref" in dataset:
            dataset_tokens = dataset.split("-") 
            assert len(dataset_tokens) == 2
            dataset = dataset_tokens[0]
            tool_name = dataset_tokens[1]
            if dataset == "zymo1":
                dataset = "zymo1div"
            if dataset == "refdiv":
                tool_name = tool_name.replace("ref", "SimRef")
            elif dataset == "zymo1div":
                tool_name = tool_name.replace("ref", "ZymoRef")
            # tool_dict_replace = False
            
            # print(dataset, tool_name)
        # if tool_name == "sylph" and "zymo1" in str(eval_report_path):
        #     print(eval_report_path)

        if config.get("asm2prof_wd", None):
            # test_dst = ["simlow", "simhigh", "simlow-sub0.001", "simhigh-sub0.001", "simlow-sub0.01", "simhigh-sub0.01"]
            test_dst = ["simlow", "simhigh", "simhigh-sub0.01", "zymo1"]
            if dataset not in test_dst: 
                # print(eval_report_path)
                continue
            samples = ["hifi", "ontR10"]
            if sample_id not in samples:
                continue

        record_flag = False
        if "strain_level" in profile_level:
            profile_level = "strain_level"
            record = []
            with open(eval_report_path, "r") as f:
                for line in f:
                    if line.strip().startswith("strain_precision"):
                        record_flag = True
                    elif record_flag:
                        record = line.strip().split("&")
                        record = [_record.strip() for _record in record]
                        if not record: print(eval_report_path)
                        break
            if record:
                all_metrics.append([profile_level, dataset, sample_id, tool_name] + record)
                # print([profile_level, dataset, sample_id, tool_name])
            # if "centrifuge" in str(eval_report_path) and "centrifuger" not in str(eval_report_path):
            #     print([profile_level, dataset, sample_id, tool_name] + record)
            #     print(eval_report_path)
    # print(all_metrics)
    all_metrics_df = pd.DataFrame(all_metrics)
    base_col_names = ["profile_level", "dataset", "sample_id", "tool_name"]
    record_col_names = [str(i) for i in range(all_metrics_df.shape[1]-len(base_col_names))]
    all_metrics_df.columns = base_col_names + record_col_names
    
    if tool_dict_replace:
        all_metrics_df["tool_name"] = all_metrics_df["tool_name"].str.lower()
        all_metrics_df["tool_name"] = all_metrics_df["tool_name"].replace(tool_dict)
        tool_df = pd.DataFrame(tool_order_list, columns=["tool_name"])
        all_metrics_df = pd.merge(tool_df, all_metrics_df, on="tool_name")
    all_metrics_df.to_csv("all_metrics_df.tsv", sep="\t", index=False)
    # print(all_metrics_df["tool_name"].tolist())
    profile_level_set = set(all_metrics_df["profile_level"].tolist())
    dataset_set = set(all_metrics_df["dataset"].tolist())
    sample_id_set = set(all_metrics_df["sample_id"].tolist())
    cartesian_product = list(itertools.product(profile_level_set, dataset_set, sample_id_set))
    all_metrics_dict = {}
    for product in cartesian_product:
        filter_metrics_df = all_metrics_df[(all_metrics_df["profile_level"] == product[0]) & (all_metrics_df["dataset"] == product[1]) & (all_metrics_df["sample_id"] == product[2])]
        if filter_metrics_df.empty:
            continue
        # filter_metrics_df_copy = filter_metrics_df.copy(deep=True)
        # filter_metrics_df_copy.columns.values[4] = "precision"
        # filter_metrics_df_copy.columns.values[5] = "recall"
        # filter_metrics_df_copy.columns.values[6] = "f1_score"
        # filter_metrics_df_copy.columns.values[7] = "AUPR"
        # filter_metrics_df_copy.columns.values[8] = "l2_dist"
        # filter_metrics_df_copy.columns.values[9] = "AFE"
        # filter_metrics_df_copy.columns.values[10] = "RFE"
        # filter_metrics_df_copy.columns.values[11] = "l1_dist"
        # filter_metrics_df_copy.columns.values[12] = "bc_dist"
        df_report_path = Path(f"report/{product[1]}")
        if not df_report_path.exists(): df_report_path.mkdir(parents=True, exist_ok=True)
        filter_metrics_df.to_csv(f"{str(df_report_path)}/{product[2]}.tsv", sep="\t", index=False)
        if config.mode != "sylph": filter_metrics_df = filter_metrics_df[filter_metrics_df["tool_name"].str.lower() != "sylph"]
        for i in record_col_names: 
            value = filter_metrics_df[i].tolist()
            value = [_value for _value in value if _value != "-"]
            value = map(float, value)
            sorted_value = sorted(set(value))
            peak_value = -1
            second_peak_value = -1
            if int(i) in [0, 1, 2, 3]:
                # target_value = max(value)
                try:
                    peak_value = sorted_value[-1]
                except:
                    print(sorted_value, product, filter_metrics_df)
                if len(sorted_value) >= 2:
                    second_peak_value = sorted_value[-2]
            else:
                # target_value = min(value)
                peak_value = sorted_value[0]
                if len(sorted_value) >= 2:
                    second_peak_value = sorted_value[1]                
            # print(target_value)
            if peak_value != -1:
                filter_metrics_df.loc[:, i] = filter_metrics_df[i].apply(
                    lambda x: f"\\textbf{{{x}}}" if x != "-" and float(x) == peak_value else x
                )
            if second_peak_value != -1:
                filter_metrics_df.loc[:, i] = filter_metrics_df[i].apply(
                    lambda x: f"\\textit{{{x}}}" if x != "-" and "textbf" not in x and float(x) == second_peak_value else x
                )                

            # tool_df = pd.DataFrame(tool_order_list, columns=["tool_name"])
            # filter_metrics_df2 = pd.merge(tool_df, filter_metrics_df, on="tool_name")
            # if config.mode != "simlow-sub0.01" and config.mode != "simlow-sub0.001":
            #     assert len(filter_metrics_df2) == len(filter_metrics_df)
            # filter_metrics_df3 = filter_metrics_df2.drop(["profile_level", "dataset", "sample_id"], axis=1)
            filter_metrics_df3 = filter_metrics_df.drop(["profile_level", "dataset", "sample_id"], axis=1)
            new_column_order = ["tool_name","0","1","2","3","5","6","7","4","8"]
            filter_metrics_df3 = filter_metrics_df3[new_column_order]
            data_list = filter_metrics_df3.values.tolist()
            for j in range(len(data_list)):
                data_list[j] = " & ".join(data_list[j])
            all_metrics_dict[f"{product[0]}-{product[1]}-{product[2]}"] = data_list
    return all_metrics_dict, dataset_set

def write_metrics(config, all_metrics_dict, dataset_set, profile_level):
    if config.get("asm2prof_wd", None):
        config.top_wd = config.asm2prof_wd
    if config.get("version", None):
        report_dir = Path(config.top_wd) / f"report_v{config.version}"
    else:
        report_dir = Path(config.top_wd) / "report"
    report_dir.mkdir(exist_ok=True)
    
    if not config.get("is_merge", None):
        print(f"This will return {len(dataset_set)} reports: {dataset_set}.")
        for dataset in dataset_set:
            if config.report.model_tex: 
                model_report_path = Path(script_dir) / config.report.model_tex
                if config.report_output_name:
                    report_path = Path(report_dir) / f"{dataset}_{profile_level}_{config.report_output_name}.tex"
                else:
                    if config.report_number_suffix:
                        if config.mode == "general":
                            report_path = Path(report_dir) / f"{dataset}_{profile_level}_{config.report_number_suffix}.tex"
                        else:
                            report_path = Path(report_dir) / f"{dataset}_{profile_level}_{config.mode}_{config.report_number_suffix}.tex"                
                    else:
                        if config.mode == "general":
                            report_path = Path(report_dir) / f"{dataset}_{profile_level}.tex"
                        else:
                            report_path = Path(report_dir) / f"{dataset}_{profile_level}_{config.mode}.tex"
                if report_path.exists() and not config.rebuild:
                    continue
                with open(model_report_path, "r") as f_in, open(report_path, "w") as f_out:
                    record_write_flag = False
                    record_write = []
                    for line in f_in:
                        # header and end 
                        if "%" not in line and not record_write_flag:
                            matches = re.findall(r'\$(.*?)\$', line)
                            if not matches:
                                f_out.write(line)
                            else:
                                # sub $dataset$
                                assert len(matches) == 1 and "dataset" in matches[0].lower()
                                text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', dataset_register_for_single_dataset.get(dataset, dataset), line)
                                f_out.write(text)
                        if line.strip().startswith("%%"):
                            record_write_flag = True
                        if record_write_flag and "bottomrule" not in line:
                            # record the lines need to be writen more than one time
                            record_write.append(line)
                        if "bottomrule" in line:
                            for i, sample_id in enumerate(config.samplesID):
                                metrics = all_metrics_dict.get(f"{profile_level}-{dataset}-{sample_id}", None)
                                sample_id = sample_id_register[sample_id.lower()]
                                if metrics:
                                    if i != 0:
                                        f_out.write("\t\hline\n")
                                    for _record in record_write:
                                        matches = re.findall(r'\$(.*?)\$', _record)
                                        if not matches:
                                            f_out.write(_record)
                                        else:
                                            assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', sample_id, _record)
                                            f_out.write(text)
                                    for metric in metrics:
                                        f_out.write("\t" + metric + "\\\\\n")
                                    
                            f_out.write(line)
                            record_write_flag = False
            elif config.report.model_tex_split:
                model_report_paths = config.report.model_tex_split
                assert len(model_report_paths) == 2
                model1_report_path = Path(script_dir) / model_report_paths[0]
                if config.report_output_name:
                    report1_path = Path(report_dir) / f"{config.report_output_name}_cls_bc.tex"
                else:
                    report1_path = Path(report_dir) / f"{dataset}_{profile_level}_report_cls_bc.tex"
                model2_report_path = Path(script_dir) / model_report_paths[1]
                if config.report_output_name:
                    report2_path = Path(report_dir) / f"{config.report_output_name}_profiling.tex"
                else:
                    report2_path = Path(report_dir) / f"{dataset}_{profile_level}_report_profiling.tex"
                if report1_path.exists() and report2_path.exists() and not config.rebuild:
                    return 
                model_report_paths = [model1_report_path, model2_report_path]
                report_paths = [report1_path, report2_path]
                for j in range(2):
                    with open(model_report_paths[j], "r") as f_in, open(report_paths[j], "w") as f_out:                  
                        record_write_flag = False
                        record_write = []
                        for line in f_in:
                            # header and end 
                            if "%" not in line and not record_write_flag:
                                matches = re.findall(r'\$(.*?)\$', line)
                                if not matches:
                                    f_out.write(line)
                                else:
                                    # sub $dataset$
                                    assert len(matches) == 1 and "dataset" in matches[0].lower()
                                    text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', dataset, line)
                                    f_out.write(text)
                            if line.strip().startswith("%%"):
                                record_write_flag = True
                            if record_write_flag and "bottomrule" not in line:
                                # record the lines need to be writen more than one time
                                record_write.append(line)
                            if "bottomrule" in line:
                                for i, sample_id in enumerate(config.samplesID):
                                    metrics_all_tools = all_metrics_dict.get(f"{profile_level}-{dataset}-{sample_id}", None)
                                    sample_id = sample_id_register[sample_id.lower()]
                                    metrics = []
                                    if metrics_all_tools:
                                        for _metrics in metrics_all_tools:
                                            if j == 0:
                                                part_metrics = _metrics.split("&")[:5] + [_metrics.split("&")[9]]
                                            elif j == 1:
                                                part_metrics = [_metrics.split("&")[0]] + _metrics.split("&")[5:9] 
                                            part_metrics = "&".join(part_metrics)
                                            metrics.append(part_metrics)
                                    if metrics:
                                        if i != 0:
                                            f_out.write("\t\hline\n")
                                        for _record in record_write:
                                            matches = re.findall(r'\$(.*?)\$', _record)
                                            if not matches:
                                                f_out.write(_record)
                                            else:
                                                assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                                text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', sample_id, _record)
                                                f_out.write(text)
                                        for metric in metrics:
                                            f_out.write("\t" + metric + "\\\\\n")
                                        
                                f_out.write(line)
                                record_write_flag = False
            subprocess.run(f"python {script_dir}/table_caption_replace.py {dataset} {report_path}", shell=True)
    else:
        print(f"This will return 1 reports: {dataset_set}.")
        zymo1_dataset = {'zymo1', 'zymo1-log'} 
        asm2prof_dataset = {"simlow", "simhigh", "zymo1", "simhigh-sub0.01"}
        ref_div = {'refdiv', 'zymo1div'}
        if len(dataset_set & zymo1_dataset) == 2:
            label = "zymo1"
        elif len(dataset_set & asm2prof_dataset) == 4:
            label = "asm2prof"
        elif len(dataset_set & ref_div) == 2:
            label = "refdiv"            
        else:
            label = "merged"
        print(label)
        model_report_path = Path(script_dir) / config.report.model_tex
        report_path = Path(report_dir) / f"{label}_merged_{profile_level}.tex"
        if report_path.exists() and not config.rebuild:
            return
        with open(model_report_path, "r") as f_in, open(report_path, "w") as f_out:
            record_write_flag = False
            record_write = []
            for line in f_in:
                # header and end 
                if "%" not in line and not record_write_flag:
                    matches = re.findall(r'\$(.*?)\$', line)
                    if not matches:
                        f_out.write(line)
                    else:
                        # sub $dataset$
                        assert len(matches) == 1 and "dataset" in matches[0].lower()
                        text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', label, line)
                        f_out.write(text)
                if line.strip().startswith("%%"):
                    record_write_flag = True
                if record_write_flag and "bottomrule" not in line:
                    # record the lines need to be writen more than one time
                    record_write.append(line)
                if "bottomrule" in line:
                    custom_order = ['simlow', 'simhigh', 'zymo1', 'simhigh-sub0.01', 'refdiv', 'zymo1div']
                    dataset_set_order = sorted(dataset_set, key=lambda x: custom_order.index(x) if x in custom_order else len(custom_order))
                    for dataset in dataset_set_order:
                        for i, sample_id in enumerate(config.samplesID):
                            metrics = all_metrics_dict.get(f"{profile_level}-{dataset}-{sample_id}", None)
                            sample_id = sample_id_register[sample_id.lower()]
                            if metrics:
                                if i != 0 or dataset != dataset_set_order[0]:
                                    f_out.write("\t\hline\n")
                                for _record in record_write:
                                    matches = re.findall(r'\$(.*?)\$', _record)
                                    if not matches:
                                        f_out.write(_record)
                                    else:
                                        assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                        if "zymo1" in dataset and "R10" in sample_id: sample_id = "ONT R10"
                                        text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', f"{dataset_register_for_single_dataset.get(dataset, dataset)} {sample_id}", _record)
                                        f_out.write(text)
                                for metric in metrics:
                                    f_out.write("\t" + metric + "\\\\\n")
                                
                    f_out.write(line)
                    record_write_flag = False
        # dataset_set = list(dataset_set)
        subprocess.run(f"python {script_dir}/table_caption_replace.py {label} {report_path}", shell=True)

def general_write_metrics(config, all_metrics_dict, dataset_set, profile_level):
    report_dir = Path(config.top_wd) / "report"
    report_dir.mkdir(exist_ok=True)
    for written_dataset, written_dataset_name_list in dataset_register.items():
        if not written_dataset_name_list: continue
        if len(written_dataset_name_list) == 1:
            model_report_paths = [Path(script_dir) / _report for _report in config.report.model_tex.one]
        elif len(written_dataset_name_list) == 2:
            model_report_paths = [Path(script_dir) / _report for _report in config.report.model_tex.two]            
        written_dataset_string = written_dataset.replace(" ", "_")
        report_path1 = Path(report_dir) / f"{written_dataset_string}_{profile_level}_binning.tex"
        report_path2 = Path(report_dir) / f"{written_dataset_string}_{profile_level}_profiling.tex"
        report_path3 = Path(report_dir) / f"{written_dataset_string}_{profile_level}_distance.tex"
        
        report_paths = [report_path1, report_path2, report_path3]    
        for report_path in report_paths:
            if report_path.exists() and not config.rebuild:
                continue 
        this_written_dataset_all_sample_id = []
        this_written_dataset_all_tool = []
        # binning report written
        for j in range(2):
            with open(model_report_paths[j], "r") as f_in, open(report_paths[j], "w") as f_out:
                record_write_flag = False
                record_write = []
                for line in f_in:
                    # header and end 
                    if "%" not in line and not record_write_flag:
                        matches = re.findall(r'\$(.*?)\$', line)
                        if not matches:
                            f_out.write(line)
                        else:
                            # sub $dataset$
                            assert len(matches) == 1 and "dataset" in matches[0].lower()
                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', written_dataset, line)
                            f_out.write(text)
                    if line.strip().startswith("%%"):
                        record_write_flag = True
                    if record_write_flag and "bottomrule" not in line:
                        # record the lines need to be writen more than one time
                        record_write.append(line)
                    if "bottomrule" in line:
                        for i, sample_id in enumerate(config.samplesID):
                            metrics1 = all_metrics_dict.get(f"{profile_level}-{written_dataset_name_list[0]}-{sample_id}", None)
                            metrics = []
                            if len(written_dataset_name_list) == 2:
                                metrics2 = all_metrics_dict.get(f"{profile_level}-{written_dataset_name_list[1]}-{sample_id}", None)
                                assert (metrics1 is None and metrics2 is None) or (metrics1 is not None and metrics2 is not None)
                                if metrics1 is None and metrics2 is None: continue
                                # print(written_dataset_name_list, metrics1, metrics2)
                                for elem1, elem2 in zip(metrics1, metrics2):
                                    if j == 0:
                                        parts1 = elem1.split("&")[:5]
                                        parts2 = elem2.split("&")[1:5]
                                    elif j == 1:
                                        parts1 = [elem1.split("&")[0]] + elem1.split("&")[5:9]
                                        parts2 = elem2.split("&")[5:9]
                                    try:
                                        assert elem1.split("&")[0] == elem2.split("&")[0]
                                    except:
                                        print(elem1.split("&")[0], elem2.split("&")[0])
                                        exit(0)
                                    if elem1.split("&")[0] not in this_written_dataset_all_tool: this_written_dataset_all_tool.append(elem1.split("&")[0])
                                    merged = "&".join(parts1 + parts2)
                                    metrics.append(merged)
                            elif len(written_dataset_name_list) == 1:
                                if metrics1 is None: continue
                                for _metric in metrics1:
                                    if j == 0:
                                        split_metric = _metric.split("&")[:5]
                                    elif j == 1:
                                        split_metric = [_metric.split("&")[0]] + _metric.split("&")[5:9]
                                    if _metric.split("&")[0] not in this_written_dataset_all_tool: this_written_dataset_all_tool.append(_metric.split("&")[0])
                                    metrics.append("&".join(split_metric))
                            this_written_dataset_all_sample_id.append(sample_id)
                            sample_id = sample_id_register[sample_id.lower()]
                            if metrics:
                                if i != 0:
                                    f_out.write("\t\hline\n")
                                for _record in record_write:
                                    matches = re.findall(r'\$(.*?)\$', _record)
                                    if not matches:
                                        f_out.write(_record)
                                    else:
                                        assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                        text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', sample_id, _record)
                                        f_out.write(text)
                                for metric in metrics:
                                    f_out.write("\t" + metric + "\\\\\n")
                                
                        f_out.write(line)
                        record_write_flag = False 
        with open(model_report_paths[-1], "r") as f_in, open(report_paths[-1], "w") as f_out:
            sample_id_list1 = []
            sample_id_list2 = []
            tool_metrics_dict = {}
            for line in f_in:
                # header and end 
                if "%" not in line:
                    matches = re.findall(r'\$(.*?)\$', line)
                    if not matches:
                        f_out.write(line)
                    else:
                        # sub $dataset$
                        if len(matches) == 1 and "dataset" in matches[0].lower():
                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', written_dataset, line)
                            f_out.write(text) 
                        # sub $samplesID$
                        elif len(matches) == 1 and "samplesid" in matches[0].lower():
                            this_written_dataset_all_sample_id = list(set(this_written_dataset_all_sample_id))
                            sample_id_list = []
                            # for sample_id in list(sample_id_register.values()):
                            #     if sample_id in this_written_dataset_all_sample_id:
                            #         sample_id_list.append(sample_id)
                            lower_this_written_dataset_all_sample_id = [_x.lower() for _x in this_written_dataset_all_sample_id]
                            for sample_id in sample_id_register:
                                if sample_id in lower_this_written_dataset_all_sample_id:
                                    idx = lower_this_written_dataset_all_sample_id.index(sample_id)
                                    sample_id_list.append(this_written_dataset_all_sample_id[idx])

                            if len(written_dataset_name_list) == 1:
                                
                                sample_id_list1 = sample_id_list
                                tool_metrics_dict = {tool:["N/A"]*len(sample_id_list1) for tool in this_written_dataset_all_tool}
                                # for i in range(len(sample_id_list1)):
                                #     for k, v in sample_id_register.items():
                                #         if v == sample_id_list1[i]:
                                #             sample_id_list1[i] = k
                                upper_sample_id_list1 = []
                                for _si in sample_id_list1:
                                    if _si.lower() in sample_id_register:
                                        upper_sample_id_list1.append(sample_id_register[_si.lower()])
                                written = " & ".join(upper_sample_id_list1)
                            elif len(written_dataset_name_list) == 2:
                                sample_id_list1 = sample_id_list
                                sample_id_list2 = sample_id_list
                                upper_sample_id_list1 = []
                                upper_sample_id_list2 = []
                                for _si in sample_id_list1:
                                    if _si.lower() in sample_id_register:
                                        upper_sample_id_list1.append(sample_id_register[_si.lower()])
                                for _si in sample_id_list2:
                                    if _si.lower() in sample_id_register:
                                        upper_sample_id_list2.append(sample_id_register[_si.lower()])                                    
                                tool_metrics_dict = {tool:["N/A"]*(len(sample_id_list1) + len(sample_id_list2)) for tool in this_written_dataset_all_tool}
                                written = " & ".join(upper_sample_id_list1) + " & " + " & ".join(upper_sample_id_list2)
                                # for i in range(len(sample_id_list1)):
                                #     for k, v in sample_id_register.items():
                                #         if v == sample_id_list1[i]:
                                #             sample_id_list1[i] = k
                                # for i in range(len(sample_id_list2)):
                                #     for k, v in sample_id_register.items():
                                #         if v == sample_id_list2[i]:
                                #             sample_id_list2[i] = k
                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', written, line)
                            f_out.write(text)
                
                if "%" in line: 
                    f_out.write(line)
                    for i, sample_id in enumerate(sample_id_list1):
                        metrics1 = all_metrics_dict.get(f"{profile_level}-{written_dataset_name_list[0]}-{sample_id}", None)
                        if metrics1:
                            for elem1 in metrics1:
                                tokens = elem1.split("&")
                                tool_metrics_dict[tokens[0]][i] = tokens[-1]
                    if len(written_dataset_name_list) == 2:
                        for i, sample_id in enumerate(sample_id_list2, start=len(sample_id_list1)):
                            metrics2 = all_metrics_dict.get(f"{profile_level}-{written_dataset_name_list[1]}-{sample_id}", None)
                            if metrics2:
                                for elem1 in metrics2:
                                    tokens = elem1.split("&")
                                    tool_metrics_dict[tokens[0]][i] = tokens[-1] 
                    for tool, tool_metric in tool_metrics_dict.items():
                        string = tool.strip() + " & " + " & ".join(tool_metric)
                        f_out.write("\t" + string + "\\\\\n")
                    


def single_species_report(config):
    all_metrics = []
    for tool, report_path in config.report.report_path.items():
        if not report_path: continue
        with open(report_path) as f:
            write_flag = False
            for line in f:
                if "dataset" in line:
                    write_flag = True
                    dataset = line.strip().split("/")[1]
                elif write_flag and "&" in line:
                    record = line.strip().split("&")
                    record = [_record.strip() for _record in record] 
                    if record:
                        all_metrics.append([tool, dataset] + record)
                    write_flag = False
    all_metrics_df = pd.DataFrame(all_metrics)
    base_col_names = ["tool_name", "dataset"]
    record_col_names = [str(i) for i in range(all_metrics_df.shape[1]-len(base_col_names))]
    all_metrics_df.columns = base_col_names + record_col_names  
    tool_set = set(all_metrics_df["tool_name"].tolist())
    dataset_set = set(all_metrics_df["dataset"].tolist())
    sorted_strains = sorted(dataset_set, key=lambda x: int(re.search(r'\d+', x).group()))
    all_metrics_dict = {}
    for dst in dataset_set:
        filter_metrics_df = all_metrics_df[all_metrics_df["dataset"] == dst]
        df_report_path = Path(f"report/{dst}")
        if not df_report_path.exists(): df_report_path.mkdir(parents=True, exist_ok=True)
        filter_metrics_df.to_csv(f"{str(df_report_path)}/{dst}.tsv", sep="\t", index=False)
        for i in record_col_names:
            value = filter_metrics_df[i].tolist()
            value = [_value for _value in value if _value != "-"]
            value = map(float, value)
            sorted_value = sorted(set(value))
            peak_value = -1
            second_peak_value = -1
            if int(i) in [0, 1, 2, 3]:
                # target_value = max(value)
                peak_value = sorted_value[-1]
                if len(sorted_value) >= 2:
                    second_peak_value = sorted_value[-2]
            else:
                # target_value = min(value)
                peak_value = sorted_value[0]
                if len(sorted_value) >= 2:
                    second_peak_value = sorted_value[1]                
            # print(target_value)
            if peak_value != -1:
                filter_metrics_df.loc[:, i] = filter_metrics_df[i].apply(
                    lambda x: f"\\textbf{{{x}}}" if x != "-" and float(x) == peak_value else x
                )
            if second_peak_value != -1:
                filter_metrics_df.loc[:, i] = filter_metrics_df[i].apply(
                    lambda x: f"\\textit{{{x}}}" if x != "-" and "textbf" not in x and float(x) == second_peak_value else x
                )          
            filter_metrics_df3 = filter_metrics_df.drop(["dataset"], axis=1)
            new_column_order = ["tool_name","0","1","2","3","5","6","7","4","8"]
            filter_metrics_df3 = filter_metrics_df3[new_column_order]
            data_list = filter_metrics_df3.values.tolist()
            for j in range(len(data_list)):
                data_list[j] = " & ".join(data_list[j])
            all_metrics_dict[dst] = data_list
    
    report_dir = Path(config.top_wd) / "report"
    report_dir.mkdir(exist_ok=True) 
    
    if config.report.model_tex:   
        model_report_path = Path(script_dir) / config.report.model_tex
        if config.report_output_name:
            report_path = Path(report_dir) / f"{config.report_output_name}.tex"
        else:
            report_path = Path(report_dir) / "single_species_report.tex"

        if report_path.exists() and not config.rebuild:
            return
        with open(model_report_path, "r") as f_in, open(report_path, "w") as f_out:    
            record_write_flag = False
            record_write = []
            for line in f_in:
                # header and end 
                if "%" not in line and not record_write_flag:
                    matches = re.findall(r'\$(.*?)\$', line)
                    if not matches:
                        f_out.write(line)
                    else:
                        # sub $dataset$
                        assert len(matches) == 1 and "dataset" in matches[0].lower()
                        text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', "S. epidermidis strain mixtures", line)
                        f_out.write(text)
                if line.strip().startswith("%%"):
                    record_write_flag = True
                if record_write_flag and "bottomrule" not in line:
                    # record the lines need to be writen more than one time
                    record_write.append(line)
                if "bottomrule" in line:
                    for i, dst in enumerate(single_species_dst_register):
                        metrics = all_metrics_dict.get(dst, None)
                        if metrics:
                            if i != 0:
                                f_out.write("\t\hline\n")
                            for _record in record_write:
                                matches = re.findall(r'\$(.*?)\$', _record)
                                if not matches:
                                    f_out.write(_record)
                                else:
                                    assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                    text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', single_species_dst_register[dst], _record)
                                    f_out.write(text)
                            for metric in metrics:
                                f_out.write("\t" + metric + "\\\\\n")
                            
                    f_out.write(line)
                    record_write_flag = False        
        subprocess.run(f"python {script_dir}/table_caption_replace.py single-species {report_path}", shell=True)
    elif config.report.model_tex_split:
        model_report_paths = config.report.model_tex_split
        assert len(model_report_paths) == 2
        model1_report_path = Path(script_dir) / model_report_paths[0]
        if config.report_output_name:
            report1_path = Path(report_dir) / f"{config.report_output_name}_cls_bc.tex"
        else:
            report1_path = Path(report_dir) / "single_species_report_cls_bc.tex"
        model2_report_path = Path(script_dir) / model_report_paths[1]
        if config.report_output_name:
            report2_path = Path(report_dir) / f"{config.report_output_name}_profiling.tex"
        else:
            report2_path = Path(report_dir) / "single_species_report_profiling.tex"
        if report1_path.exists() and report2_path.exists() and not config.rebuild:
            return 
        model_report_paths = [model1_report_path, model2_report_path]
        report_paths = [report1_path, report2_path]
        for j in range(2):
            with open(model_report_paths[j], "r") as f_in, open(report_paths[j], "w") as f_out:                  
                record_write_flag = False
                record_write = []
                for line in f_in:
                    # header and end 
                    if "%" not in line and not record_write_flag:
                        matches = re.findall(r'\$(.*?)\$', line)
                        if not matches:
                            f_out.write(line)
                        else:
                            # sub $dataset$
                            assert len(matches) == 1 and "dataset" in matches[0].lower()
                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', "single species", line)
                            f_out.write(text)
                    if line.strip().startswith("%%"):
                        record_write_flag = True
                    if record_write_flag and "bottomrule" not in line:
                        # record the lines need to be writen more than one time
                        record_write.append(line)
                    if "bottomrule" in line:
                        for i, dst in enumerate(single_species_dst_register):
                            metrics_all_tools = all_metrics_dict.get(dst, None)
                            metrics = []
                            if metrics_all_tools:
                                for _metrics in metrics_all_tools:
                                    if j == 0:
                                        part_metrics = _metrics.split("&")[:5] + [_metrics.split("&")[9]]
                                    elif j == 1:
                                        part_metrics = [_metrics.split("&")[0]] + _metrics.split("&")[5:9] 
                                    part_metrics = "&".join(part_metrics)
                                    metrics.append(part_metrics)
                            if metrics:
                                if i != 0:
                                    f_out.write("\t\hline\n")
                                for _record in record_write:
                                    matches = re.findall(r'\$(.*?)\$', _record)
                                    if not matches:
                                        f_out.write(_record)
                                    else:
                                        assert len(matches) == 1 and "samplesid" in matches[0].lower()
                                        text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', single_species_dst_register[dst], _record)
                                        f_out.write(text)
                                for metric in metrics:
                                    f_out.write("\t" + metric + "\\\\\n")
                                
                        f_out.write(line)
                        record_write_flag = False                       



@hydra.main(config_path="configs", config_name="config.yaml", version_base="1.3")
def main(config: OmegaConf):
    # print(config)
    # Process config:
    # - register evaluation resolver
    # - filter out keys used only for interpolation
    # - optional hooks, including disabling python warnings or debug friendly configuration
    OmegaConf.set_struct(config, False)
    OmegaConf.resolve(config)

    # Pretty print config using Rich library
    # print_config(config, resolve=True)
    if not config.report.get("report_path", None):
        supplement_empty_indicators_script = Path(script_dir) / "supplement_empty_indicators.py"
        if supplement_empty_indicators_script.exists():
            subprocess.run(f"python {supplement_empty_indicators_script} {config.top_wd}", shell=True)
        else:
            raise ValueError(f"{supplement_empty_indicators_script} does not exist.")
        all_metrics_dict, dataset_set = single_dataset_strain_get_metrics(config)
        if config.report_mode == "single":
            write_metrics(config, all_metrics_dict, dataset_set, config.report.profile_level)
        elif config.report_mode == "general":
            general_write_metrics(config, all_metrics_dict, dataset_set, config.report.profile_level)
    else:
        single_species_report(config)

if __name__ == "__main__":
    main()
