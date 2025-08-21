
set -e
pantax="bash /home/work/wenhai/PanTax/dev_branch/PanTax/scripts/pantax"
tool_name="pantax"
threads=64
filter=true
e=0.9
mode="0"
need_create="False"
designated_species=None
HSTN=$(hostname)

###### zymo1 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1_mode0
data_type=8
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/dataset/zymo/ontR9/ERR3152364.fastq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/dataset/zymo/strain_abundance.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/zymo_R9_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/avg_genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
pantax_db=None
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/pantax_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
extra_strain_profiling_paras='-gt 64'
version=2
graph_parsing_format=None
is_debug=true
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID
if [ $mode == "1" ]; then
    if [ $pantax_db != "None" ]; then
        db=$pantax_db
    elif [ -d $wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db ]; then
        db=$wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db
    elif [ $pantax_db == "None" ] && [ ! -d $wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db ]; then
        db=$wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db
        need_create="True"        
    fi
fi
echo $db
if [ $version == "2" ]; then
    filter=false
    pantax="bash /home/work/wenhai/wh-github/PanTax/scripts/pantax"
    output_flag="-o pantax"
    species_query_log=pantax_species_query_time.log
    strain_query_log=pantax_strain_query_time.log
    species_abundance=pantax_species_abundance.txt
    strain_abundance=pantax_strain_abundance.txt
    evaluation_report=pantax_evaluation_report.txt
    if [ $graph_parsing_format == "h5" ] && [ $mode == "1" ]; then
        zip_paras="-g --h5"
    elif [ $graph_parsing_format == "lz" ]; then
        zip_paras="-g --lz"
    else
        zip_paras=""
    fi
else
    output_flag=""
    zip_paras="-g"
    species_query_log=species_query_time.log
    strain_query_log=strain_query_time.log
    species_abundance=species_abundance.txt
    strain_abundance=strain_abundance.txt
    evaluation_report=evaluation_report.txt
    ori_strain_abundance=ori_strain_abundance.txt
fi
if [ $is_debug = true ]; then
    debug_flag="--debug"
else
    debug_flag=""
fi

# long
if [ ! -f $strain_abundance ]; then
    if [ -d pantax_db_tmp ] && [ $version == "2" ] && [ ! -f $species_abundance ]; then
        rm -f pantax_db_tmp/reads_classification.tsv pantax_db_tmp/species_abundance.txt pantax_db_tmp/strain_abundance.txt
    fi
    if [ -f ori_strain_abundance.txt ] && [ $version == "2" ]; then
        mv ori_strain_abundance.txt old_ori_strain_abundance.txt
    fi
    if [ $need_create == "False" ]; then
        if [ ! -f $species_abundance ]; then
            /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -db $db -l -r $read --species-level -t $threads -n --mode $mode -ds $designated_species --test $debug_flag $output_flag
        fi
        if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
            /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -db $db -l -r $read --strain-level -t $threads -n --mode $mode -ds $designated_species $extra_strain_profiling_paras --test $debug_flag $output_flag $zip_paras
        fi
    elif [ $need_create == "True" ] && [ $mode == "1" ]; then
        /usr/bin/time -v -o create_db_time.log $pantax -f $database_genomes_info -l -r $read --create --mode 1 -t $threads $zip_paras
        python $scripts_dir/time_process.py create_db_time.log > create_db_time.txt
        /usr/bin/time -v -o create_index_time.log $pantax -f $database_genomes_info --index -t $threads
        python $scripts_dir/time_process.py create_index_time.log > create_index_time.txt
        /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -l -r $read --species-level --test -t $threads -n $debug_flag $output_flag
        if [ $HSTN == "node002" ]; then
            /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -l -r $read --strain-level --test -t $threads -n $debug_flag $extra_strain_profiling_paras $output_flag $zip_paras
        fi
    fi
    if [ $version == "2" ] && [ -f ori_strain_abundance.txt ]; then
        mv ori_strain_abundance.txt pantax_ori_strain_abundance.txt
    fi
fi
log_files=("create_db_time.log" "create_index_time.log" $species_query_log $strain_query_log)
for log_file in "${log_files[@]}"; do
    if [ -f $log_files ]; then
        python $scripts_dir/time_process.py $log_file > ${log_file%.log}_evaluation.txt
    fi
done
if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
    fi
fi
if [ $filter = true ] && [ -f $strain_abundance ] && [ $version != "2" ]; then
    python $scripts_dir/cov_filter.py $strain_abundance $e
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py filter${e}_strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > filter${e}_evaluation_report.txt
    fi
fi

# graph_mapq
origin_dataset=$dataset
origin_wd=$wd
dataset=zymo1-ref3
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
mkdir -p $wd/graph_mapq_eval && cd $wd/graph_mapq_eval
python $scripts_dir/graph_mapq_eval.py $dataset $samplesID $db/reference_pangenome.gfa $origin_wd/$tool_name/$profile_level/$origin_dataset/$samplesID/*/reads_classification.tsv $wd/graph_mapq_eval/refdiv_stat.tsv
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### zymo1 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1_mode0
data_type=8
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/dataset/zymo/ontR10/Zymo-GridION-EVEN-BB-SN-PCR-R10HC-flipflop.fq
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/dataset/zymo/strain_abundance.txt
read_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/read_length/zymo_read_length.txt
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/avg_genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
pantax_db=None
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/pantax_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
extra_strain_profiling_paras='-gt 64'
version=2
graph_parsing_format=None
is_debug=true
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID
if [ $mode == "1" ]; then
    if [ $pantax_db != "None" ]; then
        db=$pantax_db
    elif [ -d $wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db ]; then
        db=$wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db
    elif [ $pantax_db == "None" ] && [ ! -d $wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db ]; then
        db=$wd/$tool_name/$profile_level/$dataset/$samplesID/pantax_db
        need_create="True"        
    fi
fi
echo $db
if [ $version == "2" ]; then
    filter=false
    pantax="bash /home/work/wenhai/wh-github/PanTax/scripts/pantax"
    output_flag="-o pantax"
    species_query_log=pantax_species_query_time.log
    strain_query_log=pantax_strain_query_time.log
    species_abundance=pantax_species_abundance.txt
    strain_abundance=pantax_strain_abundance.txt
    evaluation_report=pantax_evaluation_report.txt
    if [ $graph_parsing_format == "h5" ] && [ $mode == "1" ]; then
        zip_paras="-g --h5"
    elif [ $graph_parsing_format == "lz" ]; then
        zip_paras="-g --lz"
    else
        zip_paras=""
    fi
else
    output_flag=""
    zip_paras="-g"
    species_query_log=species_query_time.log
    strain_query_log=strain_query_time.log
    species_abundance=species_abundance.txt
    strain_abundance=strain_abundance.txt
    evaluation_report=evaluation_report.txt
    ori_strain_abundance=ori_strain_abundance.txt
fi
if [ $is_debug = true ]; then
    debug_flag="--debug"
else
    debug_flag=""
fi

# long
if [ ! -f $strain_abundance ]; then
    if [ -d pantax_db_tmp ] && [ $version == "2" ] && [ ! -f $species_abundance ]; then
        rm -f pantax_db_tmp/reads_classification.tsv pantax_db_tmp/species_abundance.txt pantax_db_tmp/strain_abundance.txt
    fi
    if [ -f ori_strain_abundance.txt ] && [ $version == "2" ]; then
        mv ori_strain_abundance.txt old_ori_strain_abundance.txt
    fi
    if [ $need_create == "False" ]; then
        if [ ! -f $species_abundance ]; then
            /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -db $db -l -r $read --species-level -t $threads -n --mode $mode -ds $designated_species --test $debug_flag $output_flag
        fi
        if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
            /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -db $db -l -r $read --strain-level -t $threads -n --mode $mode -ds $designated_species $extra_strain_profiling_paras --test $debug_flag $output_flag $zip_paras
        fi
    elif [ $need_create == "True" ] && [ $mode == "1" ]; then
        /usr/bin/time -v -o create_db_time.log $pantax -f $database_genomes_info -l -r $read --create --mode 1 -t $threads $zip_paras
        python $scripts_dir/time_process.py create_db_time.log > create_db_time.txt
        /usr/bin/time -v -o create_index_time.log $pantax -f $database_genomes_info --index -t $threads
        python $scripts_dir/time_process.py create_index_time.log > create_index_time.txt
        /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -l -r $read --species-level --test -t $threads -n $debug_flag $output_flag
        if [ $HSTN == "node002" ]; then
            /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -l -r $read --strain-level --test -t $threads -n $debug_flag $extra_strain_profiling_paras $output_flag $zip_paras
        fi
    fi
    if [ $version == "2" ] && [ -f ori_strain_abundance.txt ]; then
        mv ori_strain_abundance.txt pantax_ori_strain_abundance.txt
    fi
fi
log_files=("create_db_time.log" "create_index_time.log" $species_query_log $strain_query_log)
for log_file in "${log_files[@]}"; do
    if [ -f $log_files ]; then
        python $scripts_dir/time_process.py $log_file > ${log_file%.log}_evaluation.txt
    fi
done
if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
    fi
fi
if [ $filter = true ] && [ -f $strain_abundance ] && [ $version != "2" ]; then
    python $scripts_dir/cov_filter.py $strain_abundance $e
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py filter${e}_strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > filter${e}_evaluation_report.txt
    fi
fi

# graph_mapq
origin_dataset=$dataset
origin_wd=$wd
dataset=zymo1-ref3
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval
mkdir -p $wd/graph_mapq_eval && cd $wd/graph_mapq_eval
python $scripts_dir/graph_mapq_eval.py $dataset $samplesID $db/reference_pangenome.gfa $origin_wd/$tool_name/$profile_level/$origin_dataset/$samplesID/*/reads_classification.tsv $wd/graph_mapq_eval/refdiv_stat.tsv
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
