
import hydra, os, itertools, re, subprocess
from omegaconf import OmegaConf, ListConfig
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

dataset_register = {
    "simlow": "sim-low",
    "simhigh": "sim-high",

    "simhigh-gtdb": "sim-high-gtdb", 

    "3strains": "3 strains",
    "5strains": "5 strains",
    "10strains": "10 strains",

    "zymo1": "Zymo",

    "PD": "PD human gut",
    "rmhost": "Healthy human gut",
    "omnivore_gut": "Omnivorous human gut",
}

def is_file_non_empty(file_path):
    return os.path.isfile(file_path) and os.path.getsize(file_path) > 0

def is_file_at_least_two_lines(file_path):
    if not os.path.isfile(file_path):
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for i, _ in enumerate(f, 1):
                if i >= 2:
                    return True
    except Exception as e:
        return False
    
    return False

def get_time_and_memory_from_log(file):
    record = None
    with open(file, "r") as f:
        count = 0
        for line in f:
            if "&" in line: count += 1
            if count == 2:
                record = line.strip().split("&")
                record = [_record.strip() for _record in record]
                break
    return record

def get_all_time_metrics(config):
    all_time_metrics = {}
    wd = config.top_wd
    tools = config.report.tools
    samplesID = config.report.samplesID
    tool_database_build_time = config.tool_database_build_time
    script_path = Path(script_dir) / "time_process.py"
    for tool in tools:
        build_time_file = tool_database_build_time.get(tool, None)
        if tool == "PanTax":
            if config.report.type.lower() == "ngs":
                db_build_time_file = build_time_file[0]
                index_build_time_file = build_time_file[1]
                if db_build_time_file and index_build_time_file:
                    subprocess.run(f"python {script_path} {db_build_time_file} > tmp_time.log", shell=True)
                    db_record = get_time_and_memory_from_log("tmp_time.log")
                    subprocess.run(f"python {script_path} {index_build_time_file} > tmp_time.log", shell=True)
                    index_record = get_time_and_memory_from_log("tmp_time.log")
                    cpu_time = db_record[0] + "+" + index_record[0]
                    clock_time = db_record[1] + "+" + index_record[1]
                    memory = max(float(db_record[2]), float(index_record[2]))
                    memory = str(round(memory, 1))
                    all_time_metrics[f"{tool}-Database build time"] = [cpu_time, clock_time, memory]      
            elif config.report.type.lower() == "tgs":
                build_time_file = build_time_file[0]
                if build_time_file:
                    subprocess.run(f"python {script_path} {build_time_file} > tmp_time.log", shell=True)
                    record = get_time_and_memory_from_log("tmp_time.log")
                    all_time_metrics[f"{tool}-Database build time"] = record
                else:
                    all_time_metrics[f"{tool}-Database build time"] = ["-"] * 3
        else:
            if build_time_file:
                subprocess.run(f"python {script_path} {build_time_file} > tmp_time.log", shell=True)
                record = get_time_and_memory_from_log("tmp_time.log")
                all_time_metrics[f"{tool}-Database build time"] = record
            else:
                all_time_metrics[f"{tool}-Database build time"] = ["-"] * 3

    dst_id_list = ["Database build time"]
    for tool in tools:
        tool_lower = tool.lower()
        profile_lvl = config.report.profile_level
        datasets = config.report.query_dataset
        for dst in datasets:
            if tool_lower == "pantax":
                dst1 = dst + "_mode0"
                for sample_id in samplesID:
                    dst_id = f"{dst} {sample_id}"
                    if config.get("specified_time_path", False):
                        k = f"{tool}-{dst}-{sample_id}"
                        time_report = config.report.tools_report.get(k, None)
                        if time_report:
                            dst1_species_time_log_path = time_report[0]
                            dst1_strain_time_log_path = time_report[1]
                        else:
                            continue
                    else:
                        if config.version == 2 and "pantax" in tool_lower:
                            dst1_species_time_log_path = Path(wd) / tool_lower / profile_lvl / dst1 / sample_id / "species_query_time.log"
                            dst1_strain_time_log_path = Path(wd) / tool_lower / profile_lvl / dst1 / sample_id / "pantax_strain_query_time.log"

                        else:
                            dst1_species_time_log_path = Path(wd) / tool_lower / profile_lvl / dst1 / sample_id / "species_query_time.log"
                            dst1_strain_time_log_path = Path(wd) / tool_lower / profile_lvl / dst1 / sample_id / "strain_query_time.log"

                    if dst_id not in dst_id_list: dst_id_list.append(dst_id)

                    if Path(dst1_species_time_log_path).exists() and Path(dst1_strain_time_log_path).exists():
                        subprocess.run(f"python {script_path} {dst1_species_time_log_path} > tmp_time.log", shell=True)
                        species_record = get_time_and_memory_from_log("tmp_time.log")
                        subprocess.run(f"python {script_path} {dst1_strain_time_log_path} > tmp_time.log", shell=True)
                        strain_record = get_time_and_memory_from_log("tmp_time.log")
                        tool_db_build_time = all_time_metrics[f"{tool}-Database build time"]
                        if strain_record and strain_record[0] != "-":
                            if "+" in tool_db_build_time[0]:
                                sum_tool_db_build_cpu_time = sum(map(float, tool_db_build_time[0].split("+")))
                                sum_tool_db_build_clock_time = sum(map(float, tool_db_build_time[1].split("+")))
                            elif tool_db_build_time[0] == "-":
                                sum_tool_db_build_cpu_time = 0
                                sum_tool_db_build_clock_time = 0
                            else:
                                sum_tool_db_build_cpu_time = tool_db_build_time[0]
                                sum_tool_db_build_clock_time = tool_db_build_time[1]
                            record0 = str(round(float(species_record[0]) + float(strain_record[0]) + float(sum_tool_db_build_cpu_time), 1))
                            record1 = str(round(float(species_record[1]) + float(strain_record[1]) + float(sum_tool_db_build_clock_time), 1))
                            record2 = str(round(max(float(species_record[2]), float(strain_record[2])), 1))
                            all_time_metrics[f"{tool}-{dst} {sample_id}"] = [record0, record1, record2]
                            # print(f"{tool}-{dst} {sample_id}", [record0, record1, record2])
                        else:
                            all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3
                    else:
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3

            elif tool_lower == "pantax(fast)": 
                dst2 = dst + "_mode1"
                for sample_id in samplesID:
                    dst_id = f"{dst} {sample_id}"
                    if config.get("specified_time_path", False):
                        k = f"{tool}-{dst}-{sample_id}"
                        time_report = config.report.tools_report.get(k, None)
                        if time_report:
                            dst2_db_build_time_log_path = time_report[0]
                            dst2_index_build_time_log_path = time_report[1]
                            dst2_species_time_log_path = time_report[2]
                            dst2_strain_time_log_path = time_report[3]
                        else:
                            continue
                    else:
                        if config.version == 2 and "pantax" in tool_lower:
                            dst2_db_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "create_db_time.log"
                            dst2_index_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "create_index_time.log"
                            dst2_species_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "species_query_time.log"
                            dst2_strain_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "pantax_strain_query_time.log"
                            print(dst2_strain_time_log_path)
                        else:
                            dst2_db_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "create_db_time.log"
                            dst2_index_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "create_index_time.log"
                            dst2_species_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "species_query_time.log"
                            dst2_strain_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / sample_id / "strain_query_time.log"
                            # if sample_id == "ngs" and "gtdb" in dst2:
                            #     dst2_db_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / "ngs_old" / "create_db_time.log"
                            #     dst2_index_build_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / "ngs_old" / "create_index_time.log"
                            #     dst2_species_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / "ngs_old" / "species_query_time.log"
                            #     dst2_strain_time_log_path = Path(wd) / tool_lower.replace("(fast)", "") / profile_lvl / dst2 / "ngs_old" / "strain_query_time.log"
                                
                    if dst_id not in dst_id_list: dst_id_list.append(dst_id)

                    if config.report.type.lower() == "ngs" and Path(dst2_db_build_time_log_path).exists() and Path(dst2_index_build_time_log_path).exists() and Path(dst2_species_time_log_path).exists() and Path(dst2_strain_time_log_path).exists():
                        subprocess.run(f"python {script_path} {dst2_species_time_log_path} > tmp_time.log", shell=True)
                        species_record = get_time_and_memory_from_log("tmp_time.log")
                        subprocess.run(f"python {script_path} {dst2_strain_time_log_path} > tmp_time.log", shell=True)
                        strain_record = get_time_and_memory_from_log("tmp_time.log")
                        running_record = []
                        for i in range(len(species_record)):
                            if i != len(species_record) - 1:
                                running_record.append(str(round(float(species_record[i])+float(strain_record[i]), 1)))
                            else:
                                running_record.append(str(round(max(float(species_record[i]), float(strain_record[i])), 1)))
                        subprocess.run(f"python {script_path} {dst2_db_build_time_log_path} > tmp_time.log", shell=True)
                        db_build_record = get_time_and_memory_from_log("tmp_time.log")
                        subprocess.run(f"python {script_path} {dst2_index_build_time_log_path} > tmp_time.log", shell=True)
                        index_build_record = get_time_and_memory_from_log("tmp_time.log") 
                        cpu_time = db_build_record[0] + "+" + index_build_record[0] + "+" + running_record[0]
                        clock_time = db_build_record[1] + "+" + index_build_record[1] + "+" + running_record[1]
                        memory = str(round(max(map(float, [db_build_record[2], index_build_record[2], running_record[2]])), 1))                        
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = [cpu_time, clock_time, memory]
                    elif config.report.type.lower() == "tgs" and Path(dst2_db_build_time_log_path).exists() and Path(dst2_species_time_log_path).exists() and Path(dst2_strain_time_log_path).exists():
                        subprocess.run(f"python {script_path} {dst2_species_time_log_path} > tmp_time.log", shell=True)
                        species_record = get_time_and_memory_from_log("tmp_time.log")
                        subprocess.run(f"python {script_path} {dst2_strain_time_log_path} > tmp_time.log", shell=True)
                        strain_record = get_time_and_memory_from_log("tmp_time.log")
                        running_record = []
                        for i in range(len(species_record)):
                            if i != len(species_record) - 1:
                                running_record.append(str(round(float(species_record[i])+float(strain_record[i]), 1)))
                            else:
                                running_record.append(str(round(max(float(species_record[i]), float(strain_record[i])), 1)))
                        subprocess.run(f"python {script_path} {dst2_db_build_time_log_path} > tmp_time.log", shell=True)
                        db_build_record = get_time_and_memory_from_log("tmp_time.log")
                        cpu_time = db_build_record[0] + "+" + running_record[0]
                        clock_time = db_build_record[1] + "+" + running_record[1]
                        memory = str(round(max(map(float, [db_build_record[2], running_record[2]])), 1))                        
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = [cpu_time, clock_time, memory]                    
                    else:
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3
            elif tool_lower == "metamaps":
                for sample_id in samplesID:
                    if config.get("specified_time_path", False):
                        k = f"{tool}-{dst}-{sample_id}"
                        time_report = config.report.tools_report.get(k, None)
                        if time_report:
                            dst_time_log_path1 = time_report[0]
                            dst_time_log_path2 = time_report[1]
                        else:
                            continue
                    else:
                        dst_time_log_path1 = Path(wd) / tool_lower / profile_lvl / dst / sample_id / "query_time1.log"
                        dst_time_log_path2 = Path(wd) / tool_lower / profile_lvl / dst / sample_id / "query_time2.log"
                    if Path(dst_time_log_path1).exists() and Path(dst_time_log_path2).exists():
                        subprocess.run(f"python {script_path} {dst_time_log_path1} > tmp_time.log", shell=True)
                        record1 = get_time_and_memory_from_log("tmp_time.log")
                        subprocess.run(f"python {script_path} {dst_time_log_path2} > tmp_time.log", shell=True)
                        record2 = get_time_and_memory_from_log("tmp_time.log")
                        tool_db_build_time = all_time_metrics[f"{tool}-Database build time"]
                        if record1 and record1[0] != "-" and record2 and record2[0] != "-" and tool_db_build_time[0] != "-":
                            cpu_time = str(round(float(record1[0]) + float(record2[0]) + float(tool_db_build_time[0]), 1))
                            clock_time = str(round(float(record1[1]) + float(record2[1]) + float(tool_db_build_time[1]), 1))
                            memory = str(round(max(map(float, [record1[2], record2[2]])), 1))
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = [cpu_time, clock_time, memory]
                    else:
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3                
            else:
                for sample_id in samplesID:
                    if config.get("specified_time_path", False):
                        k = f"{tool}-{dst}-{sample_id}"
                        time_report = config.report.tools_report.get(k, None)
                        if time_report:
                            dst_time_log_path = time_report
                        else:
                            continue
                    else:
                        dst_time_log_path = Path(wd) / tool_lower / profile_lvl / dst / sample_id / "query_time.log"

                    dst_time_log_dir = Path(dst_time_log_path).parent
                    if not is_file_at_least_two_lines(dst_time_log_dir / "strain_abundance.txt"):
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3
                        continue

                    if Path(dst_time_log_path).exists():
                        subprocess.run(f"python {script_path} {dst_time_log_path} > tmp_time.log", shell=True)
                        record = get_time_and_memory_from_log("tmp_time.log")
                        tool_db_build_time = all_time_metrics[f"{tool}-Database build time"]
                        
                        if record and record[0] != "-" and tool_db_build_time[0] != "-":
                            record[0] = str(round(float(record[0]) + float(tool_db_build_time[0]), 1))
                            record[1] = str(round(float(record[1]) + float(tool_db_build_time[1]), 1))
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = record
                    else:
                        all_time_metrics[f"{tool}-{dst} {sample_id}"] = ["-"] * 3
    # print(all_time_metrics)
    return all_time_metrics, dst_id_list

def write_time_rpt(config, all_time_metrics, dst_id_list):
    if config.version == 2:
        report_dir = Path(config.top_wd) / "report_v2"
    else:
        report_dir = Path(config.top_wd) / "report"
    report_dir.mkdir(exist_ok=True)    
    model_report_path = Path(script_dir) / config.report.model_tex
    report_path = Path(report_dir) / f"{config.report.report_name}.tex"
    with open(model_report_path, "r") as f_in, open(report_path, "w") as f_out:
        record_write_flag = False
        record_write = []
        tools_list = []
        for tool_dst_id in all_time_metrics:
            tool = tool_dst_id.split("-")[0]
            if tool not in tools_list:
                tools_list.append(tool)
        for line in f_in:
            # header and end 
            if "%" not in line and not record_write_flag:
                matches = re.findall(r'\$(.*?)\$', line)
                if not matches:
                    f_out.write(line)
                elif len(matches) == 1 and "tool_num_c" in matches[0].lower():
                    tool_num_c = "c" * len(tools_list)
                    text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', tool_num_c, line)
                    f_out.write(text)
                elif len(matches) == 1 and "tools" in matches[0].lower():
                    tools_str = " & ".join(tools_list)
                    text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', tools_str, line)
                    f_out.write(text)
                elif len(matches) == 1 and "type" in matches[0].lower():
                    text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', config.report.type, line)
                    f_out.write(text)
            if line.strip().startswith("%%"):
                record_write_flag = True
            if record_write_flag and "bottomrule" not in line:
                # record the lines need to be writen more than one time
                record_write.append(line)
            if "bottomrule" in line:    
                for dst_id in dst_id_list:
                    cpu_time_list = []
                    clock_time_list = []
                    memory_list = []
                    for tool in tools_list:
                        tool_time_metrics = all_time_metrics[f"{tool}-{dst_id}"]
                        if not tool_time_metrics: tool_time_metrics = ["-"] * 3
                        cpu_time_list.append(tool_time_metrics[0])
                        clock_time_list.append(tool_time_metrics[1])
                        memory_list.append(tool_time_metrics[2])
                    cpu_time = " & ".join(cpu_time_list)
                    clock_time = " & ".join(clock_time_list)
                    memory = " & ".join(memory_list)
                    for _record in record_write:
                        matches = re.findall(r'\$(.*?)\$', _record)
                        if not matches:
                            f_out.write(_record)
                        else:
                            assert len(matches) == 2 and "col_num" in matches[0].lower() and "dataset" in matches[1].lower()
                            if dst_id != "Database build time":
                                dst_id_tokens = dst_id.split(" ", 1)
                                if len(dst_id_tokens) == 2 and dst_id_tokens[1]:
                                    try:
                                        new_dst_id = dataset_register[dst_id_tokens[0]] + " " + sample_id_register[dst_id_tokens[1].lower()]
                                    except:
                                        new_dst_id = dst_id_tokens[0] + " " + dst_id_tokens[1].lower()
                                else:
                                    new_dst_id = dataset_register[dst_id_tokens[0]]
                            else:
                                new_dst_id = dst_id
                            text = re.sub(r'\$' + re.escape(matches[0]) + r'\$', str(len(tools_list)), _record)
                            text = re.sub(r'\$' + re.escape(matches[1]) + r'\$', new_dst_id, text)
                            f_out.write(text)
                    f_out.write("\t" + "CPU(h) & " + cpu_time + "\\\\\n")
                    f_out.write("\t" + "Wall Time(h) & " + clock_time + "\\\\\n")
                    f_out.write("\t" + "Memory(G) & "+ memory + "\\\\\n")
                f_out.write(line)
                record_write_flag = False
    
    if config.report._name_ == "general_ngs_time":
        dataset = "general_ngs_time"
    elif config.report._name_ == "general_tgs_time":
        dataset = "general_tgs_time"
    elif config.report._name_ == "gtdb100_simhigh_all_time":
        dataset = "gtdb100_simhigh_all_time"
    elif config.report._name_ == "single_species_ngs_time":
        dataset = "single_species_ngs_time"    
    else:
        dataset = None
    if dataset:
        subprocess.run(f"python {script_dir}/table_caption_replace.py {dataset} {report_path}", shell=True)   

def single_species_report(config):
    all_time_metrics = {}
    wd = config.top_wd
    tool_database_build_time = config.tool_database_build_time
    script_path = Path(script_dir) / "time_process.py"
    tools = list(config.tool_database_build_time.keys())
    for tool in tools:
        build_time_file = tool_database_build_time[tool]
        if tool == "PanTax":
            db_build_time_file = build_time_file[0]
            index_build_time_file = build_time_file[1]
            if db_build_time_file and index_build_time_file:
                subprocess.run(f"python {script_path} {db_build_time_file} > tmp_time.log", shell=True)
                db_record = get_time_and_memory_from_log("tmp_time.log")
                subprocess.run(f"python {script_path} {index_build_time_file} > tmp_time.log", shell=True)
                index_record = get_time_and_memory_from_log("tmp_time.log")
                cpu_time = db_record[0] + "+" + index_record[0]
                clock_time = db_record[1] + "+" + index_record[1]
                memory = max(float(db_record[2]), float(index_record[2]))
                memory = str(round(memory, 1))
                all_time_metrics[f"{tool}-Database build time"] = [cpu_time, clock_time, memory]      
            else:
                all_time_metrics[f"{tool}-Database build time"] = ["-"] * 3 
        else:
            if build_time_file:
                subprocess.run(f"python {script_path} {build_time_file} > tmp_time.log", shell=True)
                record = get_time_and_memory_from_log("tmp_time.log")
                all_time_metrics[f"{tool}-Database build time"] = record
            else:
                all_time_metrics[f"{tool}-Database build time"] = ["-"] * 3    
    dst_id_list = ["Database build time"]
    for tool, tool_time_report in config.report.time_report.items():
        for dst in config.report.query_dataset:
            if dst not in dst_id_list: dst_id_list.append(dst)
            query_time_log_path = Path(tool_time_report) / dst / "query_time.log"
            if Path(query_time_log_path).exists():
                subprocess.run(f"python {script_path} {query_time_log_path} > tmp_time.log", shell=True)
                record = get_time_and_memory_from_log("tmp_time.log")   
                tool_db_build_time = all_time_metrics[f"{tool}-Database build time"]
                if record and record[0] != "-" and tool_db_build_time[0] != "-":
                    if tool.lower() == "pantax":
                        sum_tool_cpu_build_time = sum(map(float, tool_db_build_time[0].split("+")))
                        sum_tool_clock_build_time = sum(map(float, tool_db_build_time[1].split("+")))                    
                        record[0] = str(round(float(record[0]) + sum_tool_cpu_build_time, 1))
                        record[1] = str(round(float(record[1]) + sum_tool_clock_build_time, 1))
                    else:
                        record[0] = str(round(float(record[0]) + float(tool_db_build_time[0]), 1))
                        record[1] = str(round(float(record[1]) + float(tool_db_build_time[1]), 1))
                all_time_metrics[f"{tool}-{dst}"] = record
            else:
                all_time_metrics[f"{tool}-{dst}"] = ["-"] * 3                         
    return all_time_metrics, dst_id_list
          
def ngs_and_tgs_all_metrics(config):
    assert len(config.report.type) == 2
    config.report.type = "NGS"    
    config.report.samplesID = ["ngs"]
    ngs_all_time_metrics, ngs_dst_id_list = get_all_time_metrics(config)
    config.report.type = "TGS"
    config.report.samplesID = ["hifi", "clr", "ontR9", "ontR10"]
    tgs_all_time_metrics, tgs_dst_id_list = get_all_time_metrics(config)
    all_time_metrics = ngs_all_time_metrics.copy()
    for key, value in tgs_all_time_metrics.items():
        if key in all_time_metrics:
            if all_time_metrics[key] != value:
                print(f"Warnings: Key '{key}' is different. ngs_all_time_metrics: {all_time_metrics[key]}, tgs_all_time_metrics: {value}")
        else:
            all_time_metrics[key] = value 
    # dst_id_list = list(set(ngs_dst_id_list + tgs_dst_id_list)) # the order is disturbed
    dst_id_list = ngs_dst_id_list.copy()
    for token in tgs_dst_id_list:
        if token not in dst_id_list:
            dst_id_list.append(token)
    # print(all_time_metrics)
    # print(dst_id_list)
    return all_time_metrics, dst_id_list

def time_report_df_output(config, all_time_metrics, dst_id_list, type_num):
    # print(all_time_metrics, dst_id_list)
    time_report_df_output_path = Path(config.time_report_df_output_path)
    time_report_df_output_path.mkdir(exist_ok=True)

    tools_list = []
    for tool_dst_id in all_time_metrics:
        tool = tool_dst_id.split("-")[0]
        if tool not in tools_list:
            tools_list.append(tool)    
    
    db_build = dst_id_list[0]
    assert db_build == "Database build time"
    print(config.report.query_dataset)
    for query_dst in config.report.query_dataset:
        # df_list = [("tool", "dataset", "sample_id", "cpu_time", "wall_time", "memory")]
        df_list = []
        for dst_id in dst_id_list[1:]:
            dst_id_tokens = dst_id.split(" ", 1)
            dst = dst_id_tokens[0]
            if dst != query_dst: continue
            sample_id = dst_id_tokens[1]
            for tool in tools_list:
                tool2db_build = all_time_metrics[f"{tool}-{db_build}"]
                tool2dst_id = all_time_metrics[f"{tool}-{dst_id}"]
                # print(f"{tool}-{dst_id}")
                cpu_time = tool2dst_id[0]
                if "+" in cpu_time:
                    cpu_time_list = cpu_time.split("+")
                    cpu_time_list = [float(time.strip()) for time in cpu_time_list]
                    cpu_time = str(round(sum(cpu_time_list), 1))

                wall_time = tool2dst_id[1]
                if "+" in wall_time:
                    wall_time_list = wall_time.split("+")
                    wall_time_list = [float(time.strip()) for time in wall_time_list]
                    wall_time = str(round(sum(wall_time_list), 1))

                if tool2db_build[2] != "-" and tool2dst_id[2] != "-":
                    memory = str(round(max(float(tool2db_build[2]), float(tool2dst_id[2])), 1))
                elif tool2db_build[2] == "-" and tool2dst_id[2] != "-":
                    memory = tool2dst_id[2]
                else:
                    memory = "-"
                df_list.append((tool, dst, sample_id, cpu_time, wall_time, memory))
        df = pd.DataFrame(df_list)
        df.columns = ["tool", "dataset", "sample_id", "cpu_time", "wall_time", "memory"]
        
        dst_time_report_df_output_path = time_report_df_output_path / f"{query_dst}"
        dst_time_report_df_output_path.mkdir(exist_ok=True)
        if type_num == 1:
            df.to_csv(f"{dst_time_report_df_output_path}/{query_dst}_{config.report.type.lower()}.txt", index=False, sep="\t")
        else:
            df.to_csv(f"{dst_time_report_df_output_path}/{query_dst}_all.txt", index=False, sep="\t")


    

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
    if not config.report.get("time_report", None):
        if isinstance(config.report.type, ListConfig):
            type_num = len(config.report.type)
        else:
            type_num = 1
        if type_num == 2:
            all_time_metrics, dst_id_list = ngs_and_tgs_all_metrics(config)
        else:
            all_time_metrics, dst_id_list = get_all_time_metrics(config)
        write_time_rpt(config, all_time_metrics, dst_id_list)
        if config.time_report_df_output:
            time_report_df_output(config, all_time_metrics, dst_id_list, type_num)
    else:
        all_time_metrics, dst_id_list = single_species_report(config)
        write_time_rpt(config, all_time_metrics, dst_id_list)


if __name__ == "__main__":
    main()