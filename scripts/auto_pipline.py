import hydra, os, subprocess
from omegaconf import OmegaConf
from utils import *
from pathlib import Path
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
script_path = Path(__file__).resolve()
script_dir = script_path.parent

data_type = {
    "simlow": 30,
    "simhigh": 1000,
    "cami_madness": 0,
    "gastrointestinal_tract": 3,
    "zymo1": 8,
    "zymo1-log": 8,
    "zymo1-log-sub": 8,
    "zymo1-log-sub2": 8,
    "zymo1-log-sub3": 8,
    "zymo2": 8,
    "atcc": 1,
    "nwc": 8,
    "dechat_simhigh": 1000,

    "simlow-sub0.01": 30,
    "simlow-sub0.001":30,
    "simhigh-sub0.01": 1000,
    "simhigh-sub0.001": 1000,

    "simlow-gtdb":30,
    "simhigh-gtdb":1000,
    "simlow-gtdb-mut0.01":30,
    "simhigh-gtdb-mut0.01":1000,

    "simlow-low": 30,

    "simlow-subsample0.5":30,
    "simlow-subsample0.1":30,
    "simlow-subsample0.2":30,
    "simlow-subsample0.3":30,
    "simlow-subsample0.4":30,

    "test_simlow_add_eq2":30,

    "spiked_in_single":-1,
    "spiked_in_three":-1,
    "spiked_in_five":-1,
    "spiked_in_ten":-1,

    "spiked_in_single_species666_large_pangenome":-1,
    "spiked_in_three_species666_large_pangenome":-1,
    "spiked_in_five_species666_large_pangenome":-1,
    "spiked_in_ten_species666_large_pangenome":-1,
    "spiked_in_eight_species666_large_pangenome": -1,

    "low_spiked_in_eight_species666_large_pangenome": -1,

    "refdiv": -1,

    "simhigh1000": -1,
    "simhigh2000": -1,
    "simhigh3000": -1,
    "simhigh4000": -1,
}

def get_tool_work_shell_para(config):
    tool = config.tool._name_
    branch = config.tool.get("branch", None)
    top_wd = config.top_wd
    if branch:
        tool_wd_dir = Path(top_wd) / f"{branch}"
    else:
        tool_wd_dir = Path(top_wd) / f"{tool}"
    tool_wd_dir.mkdir(parents=True, exist_ok=True)
    tool_work_shell_origin_path = Path(script_dir) / f"configs/tools/tools_work_shell/{tool}.sh"
    profile_level = config.tool.profile_level
    read_type =  config.tool.read_type
    read_type2sample_id_map = []
    samplesID = config.dataset.samplesID
    tool_samplesID_limit = config.tool.get("samplesID", None)
    for _read_type in read_type:
        if _read_type in samplesID:
            if tool_samplesID_limit:
                _read_type2sample_id = [(_read_type, sample_id) for sample_id in samplesID[_read_type] if sample_id in tool_samplesID_limit]
            else:
                _read_type2sample_id = [(_read_type, sample_id) for sample_id in samplesID[_read_type]]
            read_type2sample_id_map.extend(_read_type2sample_id)
    # print(read_type2sample_id_map)
    reads_path = config.dataset.reads_path
    if tool == "pantax":
        genome_length = config.genomes_avg_length
    else:
        genome_length = config.genomes_length
    rt_sample_read = []
    for _read_type2sample_id_map in read_type2sample_id_map:
        _read_type, sample_id = _read_type2sample_id_map
        if sample_id in reads_path and sample_id == "ngs":
            read = config.dataset.reads_path.ngs.ngs_reads_fq
            read1 = config.dataset.reads_path.ngs.ngs_reads_fq1
            read2 = config.dataset.reads_path.ngs.ngs_reads_fq2
            if not read:
                if not (read1 and read2): continue
            read_length = config.dataset.reads_path.ngs.ngs_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.ngs.camisim_reads_mapping_path
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, "-", config.dataset.reads_path.ngs.pantax_db])
        elif sample_id in reads_path and sample_id == "hifi":
            read = config.dataset.reads_path.hifi.hifi_reads_fq
            if not read: continue
            read1 = "-"
            read2 = "-"
            read_length = config.dataset.reads_path.hifi.hifi_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.hifi.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])
        elif sample_id in reads_path and sample_id == "ontR9":
            read = config.dataset.reads_path.ontR9.ontR9_reads_fq
            read1 = "-"
            read2 = "-"
            if not read: continue
            read_length = config.dataset.reads_path.ontR9.ontR9_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.ontR9.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])
        elif sample_id in reads_path and sample_id == "ontR10":
            read = config.dataset.reads_path.ontR10.ontR10_reads_fq
            read1 = "-"
            read2 = "-"
            if not read: continue
            read_length = config.dataset.reads_path.ontR10.ontR10_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.ontR10.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])
        elif sample_id in reads_path and sample_id == "clr":
            read = config.dataset.reads_path.clr.clr_reads_fq
            read1 = "-"
            read2 = "-"
            if not read: continue
            read_length = config.dataset.reads_path.clr.clr_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.clr.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])            
        elif sample_id in reads_path and sample_id == "ont":
            read = config.dataset.reads_path.ont.ont_reads_fq
            read1 = "-"
            read2 = "-"
            if not read: continue
            read_length = config.dataset.reads_path.ont.ont_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.ont.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])
        elif sample_id in reads_path and sample_id == "pacbio":
            read = config.dataset.reads_path.pacbio.pacbio_reads_fq
            read1 = "-"
            read2 = "-"
            if not read: continue
            read_length = config.dataset.reads_path.pacbio.pacbio_read_length
            camisim_reads_mapping_path = config.dataset.reads_path.pacbio.get("camisim_reads_mapping_path", "-")
            rt_sample_read.append([_read_type, sample_id, read, read1, read2, camisim_reads_mapping_path, read_length, genome_length, config.dataset.reads_path.ngs.pantax_db])
    # print(rt_sample_read)
    species_all_tool_shell_paras = []
    strain_all_tool_shell_paras = []
    for _profile_level in profile_level:
        for _rt_sample_read in rt_sample_read:
            if _profile_level == "species_level" and config.species_level:
                # db = config.tool.species_level.db
                # seq2tax = config.tool.species_level.seq2tax
                # _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [db, seq2tax]
                last_object = config.tool.species_level
                _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.true_abund, "-", "-"] + [last_object]
                species_all_tool_shell_paras.append(_all_paras)  
            elif _profile_level == "strain_level" and config.strain_level:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.strain_level
                _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                strain_all_tool_shell_paras.append(_all_paras)  
            elif _profile_level == "zymo1_strain_level" and config.zymo1_strain_level:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.zymo1_strain_level
                if config.tool.zymo1_strain_level.database_genomes_info:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.tool.zymo1_strain_level.database_genomes_info] + [last_object]
                else:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                strain_all_tool_shell_paras.append(_all_paras) 
                
            elif _profile_level == "spiked_in_strain_level" and config.spiked_in_strain_level:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.spiked_in_strain_level
                if config.tool.spiked_in_strain_level.database_genomes_info:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                else:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                strain_all_tool_shell_paras.append(_all_paras)
            elif _profile_level == "spiked_in_strain_level_species666_large_pangenome" and config.spiked_in_strain_level_species666_large_pangenome:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.spiked_in_strain_level_species666_large_pangenome
                _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                strain_all_tool_shell_paras.append(_all_paras)
            elif _profile_level == "gtdb_strain_level" and config.gtdb_strain_level:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.gtdb_strain_level
                if config.tool.gtdb_strain_level.database_genomes_info:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.tool.gtdb_strain_level.database_genomes_info] + [last_object]
                else:
                    _all_paras = [top_wd, config.scripts_dir, config.dataset._name_, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, config.database_genomes_info] + [last_object]
                strain_all_tool_shell_paras.append(_all_paras)
            elif _profile_level == "reference_diversity_strain_level" and config.reference_diversity_strain_level:
                if not config.dataset.get("strain_true_abund", None):
                    continue
                last_object = config.tool.reference_diversity_strain_level
                db = config.tool.reference_diversity_strain_level.db[config.tool.reference_diversity_strain_level_ref_num-1]
                database_genomes_info = Path(db) / "genomes_info.txt"
                dataset_name =  config.dataset._name_ + f"-ref{config.tool.reference_diversity_strain_level_ref_num}"
                _all_paras = [top_wd, config.scripts_dir, dataset_name, data_type[config.dataset._name_], _profile_level] + _rt_sample_read + [config.dataset.strain_true_abund, config.genomes_length_for_strains, database_genomes_info] + [{"db": db}]
                strain_all_tool_shell_paras.append(_all_paras)
    print(f"dataset:{config.dataset._name_}\tspecies tasks number: {len(species_all_tool_shell_paras)}\tstrain tasks number: {len(strain_all_tool_shell_paras)}")
    return species_all_tool_shell_paras, strain_all_tool_shell_paras, tool_work_shell_origin_path, tool_wd_dir

def write_shell(all_tool_shell_paras, tool_work_shell_origin_path, tool_wd_dir, profile_level, config):
    shell_number_suffix, isolate, dataset_name, rebuild = config.shell_number_suffix, config.isolate, config.dataset._name_, config.rebuild
    branch = config.tool.get("branch", None)
    shell_name = Path(tool_work_shell_origin_path).stem
    if config.tool.get("version", None):
        tool_wd_shell_new_path = Path(tool_wd_dir) / f"{profile_level}_work{config.tool.version}"
    else:
        tool_wd_shell_new_path = Path(tool_wd_dir) / f"{profile_level}_work"
    
    if config.tool.get("sensitivity_analysis", None):
        tool_wd_shell_new_path = Path(config.tool.sensitivity_analysis_wd) / f"{profile_level}_work"

    if config.tool.get("more_sensitivity_analysis", None):
        tool_wd_shell_new_path = Path(config.tool.sensitivity_analysis_wd) / f"{profile_level}_more_sensitivity_analysis_work"

    if config.tool.get("rescue_sensitivity_analysis", None):
        tool_wd_shell_new_path = Path(config.tool.sensitivity_analysis_wd) / f"{profile_level}_rescue_sensitivity_analysis_work"

    if config.tool.get("low_cov_eval", None):
        tool_wd_shell_new_path = Path(tool_wd_dir) / f"{profile_level}_low_eval_work"

    tool_wd_shell_new_path.mkdir(parents=True, exist_ok=True)
    if isolate:
        if shell_number_suffix or config.tool.get("reference_diversity_strain_level_ref_num", None):
            if not shell_number_suffix and config.tool.reference_diversity_strain_level_ref_num: shell_number_suffix = config.tool.reference_diversity_strain_level_ref_num
            tool_wd_shell = Path(tool_wd_shell_new_path) / f"{profile_level}_{dataset_name}_{shell_name}{shell_number_suffix}.sh"
        else:
            if config.tool.get("sensitivity_analysis", None) or config.tool.get("more_sensitivity_analysis", None) or config.tool.get("rescue_sensitivity_analysis", None):
                if config.tool.read_type[0] == "short":
                    sample_id = config.dataset.samplesID.short[0]
                elif config.tool.read_type[0] == "long":
                    sample_id = config.dataset.samplesID.long[0]
                tool_wd_shell = Path(tool_wd_shell_new_path) / f"{profile_level}_{dataset_name}_{sample_id}_{shell_name}.sh"
            else:
                tool_wd_shell = Path(tool_wd_shell_new_path) / f"{profile_level}_{dataset_name}_{shell_name}.sh"        
    else:
        if shell_number_suffix or config.tool.get("reference_diversity_strain_level_ref_num", None):
            if not shell_number_suffix and config.tool.reference_diversity_strain_level_ref_num: shell_number_suffix = config.tool.reference_diversity_strain_level_ref_num
            tool_wd_shell = Path(tool_wd_shell_new_path) / f"{profile_level}_{shell_name}{shell_number_suffix}.sh"
        else:
            tool_wd_shell = Path(tool_wd_shell_new_path) / f"{profile_level}_{shell_name}.sh"
    if rebuild:
        tool_wd_shell.unlink(missing_ok=True)
    if not tool_wd_shell.is_file():
        with open(tool_work_shell_origin_path, "r") as f_in, open(tool_wd_shell, "w") as f_out:
            for line in f_in:
                if line.startswith("#"):
                    break
                else:
                    f_out.write(line)

    for paras in all_tool_shell_paras:
        paras_dict = {
            "wd": paras[0],
            "scripts_dir": paras[1],
            "dataset": paras[2],
            "data_type": paras[3],
            "read_type": paras[5],
            "samplesID": paras[6],
            "profile_level": paras[4],
            "read": paras[7],
            "read1": paras[8],
            "read2": paras[9],
            "camisim_reads_mapping_path": paras[10],
            "read_length": paras[11],
            "genome_length": paras[12],
            "pantax_db": paras[13],
            "true_abund": paras[14],
            "genomes_length_for_strains": paras[15],
            "database_genomes_info": paras[16],
        }
        if "strain" in paras_dict.get("profile_level"):
            paras_dict["profile_level"] = "strain_level"
        with open(tool_work_shell_origin_path, "r") as f_in, open(tool_wd_shell, "a") as f_out:
            f_out.write(f"###### {paras[2]} {paras[6]}\n")
            parts_code = {}
            part_flag = None
            for line in f_in:
                if line.startswith("# para"):
                    part_flag = "para"
                    parts_code[part_flag] = []
                elif line.startswith("# dir"):
                    part_flag = "dir"
                    parts_code[part_flag] = []                     
                elif line.startswith("# short"):
                    part_flag = "short"
                    parts_code[part_flag] = []  
                elif line.startswith("# long"):
                    part_flag = "long"
                    parts_code[part_flag] = []
                elif line.startswith("# low"):
                    part_flag = "low"
                    parts_code[part_flag] = []
                elif line.startswith("# sensitivity"):
                    part_flag = "sensitivity"
                    parts_code[part_flag] = []
                elif line.startswith("# sen_low"):
                    part_flag = "sen_low"
                    parts_code[part_flag] = []
                elif line.startswith("# more_sensitivity"):
                    part_flag = "more_sensitivity"
                    parts_code[part_flag] = []    
                elif line.startswith("# rescue_sensitivity"):
                    part_flag = "rescue_sensitivity"
                    parts_code[part_flag] = []            
                elif line.startswith("# graph_mapq"):
                    part_flag = "graph_mapq"
                    parts_code[part_flag] = []         
                if part_flag and not line.startswith("#"):
                    parts_code[part_flag].append(line)
            f_out.write("# para\n")
            for i, _para in enumerate(parts_code["para"], start=1):
                _para = _para.strip()[1:].split("#")[0].strip() # $dataset #simlow -> dataset
                if _para in paras_dict:
                    f_out.write(f"{_para}={paras_dict[_para]}\n") # dataset=simlow
                else:
                    f_out.write(f"{_para}='-'\n")
                if i == len(paras_dict):
                    break
            f_out.write("designated_genomes_info='-'\n")
            # if config.dataset.get("ncbi_taxid2gtdb_taxid", None):
            #     f_out.write(f"ncbi_taxid2gtdb_taxid={config.dataset.ncbi_taxid2gtdb_taxid}\n")
            # else:
            #     f_out.write(f"ncbi_taxid2gtdb_taxid='-'\n")
            for _para_key, _para_val in paras[-1].items(): # database extra paras
                f_out.write(f"{_para_key}={_para_val}\n")

            # strain profiling paras
            if config.tool.get("extra_strain_profiling_paras", None):
                f_out.write(f"extra_strain_profiling_paras='{config.tool.extra_strain_profiling_paras}'\n")
            else:
                f_out.write(f"extra_strain_profiling_paras=''\n")

            # for pantax version 2.0
            if config.tool.get("version", None):
                f_out.write(f"version={config.tool.version}\n")
            else:
                f_out.write("version=1\n")

            # graph_parsing_format
            if config.tool.get("graph_parsing_format", None):
                f_out.write(f"graph_parsing_format={config.tool.graph_parsing_format}\n")
            else:
                f_out.write(f"graph_parsing_format=None\n")

            # is_debug
            if config.tool.get("is_debug", None):
                f_out.write(f"is_debug=true\n")
            else:
                f_out.write(f"is_debug=false\n")

            # sensitivity_analysis
            if config.tool.get("sensitivity_analysis", None):
                f_out.write(f"sensitivity_analysis_wd={config.tool.sensitivity_analysis_wd}\n")

            # more_sensitivity_analysis
            if config.tool.get("more_sensitivity_analysis", None):
                f_out.write(f"sensitivity_analysis_wd={config.tool.sensitivity_analysis_wd}\n")

            # rescue_sensitivity_analysis
            if config.tool.get("rescue_sensitivity_analysis", None):
                f_out.write(f"sensitivity_analysis_wd={config.tool.sensitivity_analysis_wd}\n")
            
            # strain_real_cov
            if config.dataset.get("strain_true_cov", None):
                f_out.write(f"strain_true_cov={config.dataset.strain_true_cov}\n")            

            f_out.write("# dir\n")
            for token in parts_code["dir"]:
                if branch and token.strip().startswith("mkdir"):
                    token = token.replace("$tool_name", branch)
                f_out.write(token)
            if paras_dict["read_type"] == "short":
                f_out.write("# short\n")
                for token in parts_code["short"]:
                    f_out.write(token) 
            elif paras_dict["read_type"] == "long": 
                f_out.write("# long\n")                  
                for token in parts_code["long"]:
                    f_out.write(token)
            if config.tool.get("low_cov_eval", None):
                f_out.write("# low_cov_eval\n")                  
                for token in parts_code["low"]:
                    f_out.write(token) 
            if config.tool.get("sensitivity_analysis", None):
                f_out.write("# sensitivity\n")                  
                for token in parts_code["sensitivity"]:
                    f_out.write(token)  
            if config.tool.get("sensitivity_analysis_low", None):
                f_out.write("# sen_low\n")                  
                for token in parts_code["sen_low"]:
                    f_out.write(token) 
            if config.tool.get("more_sensitivity_analysis", None):
                f_out.write("# more_sensitivity\n")                  
                for token in parts_code["more_sensitivity"]:
                    f_out.write(token)   
            if config.tool.get("rescue_sensitivity_analysis", None):
                f_out.write("# rescue_sensitivity\n")                  
                for token in parts_code["rescue_sensitivity"]:
                    f_out.write(token)      
            if config.tool.get("graph_mapq", None):
                f_out.write("# graph_mapq\n")                  
                for token in parts_code["graph_mapq"]:
                    f_out.write(token)                             
            f_out.write(f"#{'-' * 200}#\n")
    print(f"tool {config.tool._name_} work shell path: {tool_wd_shell}")
    if config.tool._name_.lower() == "pantax" and (config.tool.mode or config.tool.sensitivity_analysis or config.tool.more_sensitivity_analysis or config.tool.rescue_sensitivity_analysis or config.tool.low_cov_eval):
        generate_diff_mode_shell_script = Path(script_dir) / "pantax_two_mode_shell_generate.sh"
        subprocess.run(f"bash {generate_diff_mode_shell_script} {tool_wd_shell} {config.tool.mode}", shell=True)
        subprocess.run(f"rm {tool_wd_shell}", shell=True)


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
    species_all_tool_shell_paras, strain_all_tool_shell_paras, tool_work_shell_origin_path, tool_wd_dir = get_tool_work_shell_para(config)
    if config.species_level and species_all_tool_shell_paras:
        write_shell(species_all_tool_shell_paras, tool_work_shell_origin_path, tool_wd_dir, species_all_tool_shell_paras[0][4], config)
    if (config.strain_level or config.zymo1_strain_level or config.spiked_in_strain_level or config.spiked_in_strain_level_species666_large_pangenome or config.gtdb_strain_level or config.reference_diversity_strain_level) and strain_all_tool_shell_paras:
        write_shell(strain_all_tool_shell_paras, tool_work_shell_origin_path, tool_wd_dir, strain_all_tool_shell_paras[0][4], config)


if __name__ == "__main__":
    main()