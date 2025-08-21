
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

# paras
$wd
$scripts_dir
$dataset #simlow
$data_type #30/1000
$read_type #short/long
$samplesID #ngs/hifi
$profile_level
$read
$read1
$read2
$camisim_reads_mapping_path
$true_abund
$read_length
$genome_length
$genomes_length_for_strains
$database_genomes_info
$pantax_db
$designated_species
$extra_strain_profiling_paras
$version
$graph_parsing_format
$is_debug
$sensitivity_analysis_wd
$strain_true_cov

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

# short
if [ ! -f $strain_abundance ]; then
    if [ -d pantax_db_tmp ] && [ $version == "2" ] && [ ! -f $species_abundance ]; then
        rm -f pantax_db_tmp/reads_classification.tsv pantax_db_tmp/species_abundance.txt pantax_db_tmp/strain_abundance.txt
    fi
    if [ -f ori_strain_abundance.txt ] && [ $version == "2" ]; then
        mv ori_strain_abundance.txt old_ori_strain_abundance.txt
    fi
    if [ $need_create == "False" ]; then
        if [ $read == "None" ]; then
            # two paired end file
            if [ ! -f $species_abundance ]; then
                /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -db $db -s -p -r $read1 -r $read2 --species-level -t $threads -n --mode $mode -ds $designated_species --test $debug_flag $output_flag
            fi
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -db $db -s -p -r $read1 -r $read2 --strain-level -t $threads -n --mode $mode -ds $designated_species $extra_strain_profiling_paras --test $debug_flag $output_flag $zip_paras
            fi
        else
            # single paired end file
            if [ ! -f $species_abundance ]; then
                /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -db $db -s -p -r $read --species-level -t $threads -n --mode $mode -ds $designated_species --test $debug_flag $output_flag
            fi
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -db $db -s -p -r $read --species-level --strain-level -t $threads -n --mode $mode -ds $designated_species $extra_strain_profiling_paras --test $debug_flag $output_flag $zip_paras
            fi
        fi
    elif [ $need_create == "True" ] && [ $mode == "1" ]; then
        if [ $read == "None" ]; then
            /usr/bin/time -v -o create_db_time.log $pantax -f $database_genomes_info -s -p -r $read1 -r $read2 --create --mode 1 -t $threads $zip_paras
        else
            /usr/bin/time -v -o create_db_time.log $pantax -f $database_genomes_info -s -p -r $read --create --mode 1 -t $threads
        fi
        # python $scripts_dir/time_process.py create_db_time.log > create_db_time.txt
        /usr/bin/time -v -o create_index_time.log $pantax -f $database_genomes_info --index -t $threads
        # python $scripts_dir/time_process.py create_index_time.log > create_index_time.txt
        if [ $read == "None" ]; then
            /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -s -p -r $read1 -r $read2 --species-level --test $debug_flag -t $threads -n $output_flag
        else
            /usr/bin/time -v -o $species_query_log $pantax -f $database_genomes_info -s -p -r $read --species-level --test $debug_flag -t $threads -n $output_flag
        fi
        if [ $HSTN == "node002" ]; then
            if [ $read == "None" ]; then
                /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -s -p -r $read1 -r $read2 --strain-level --test $debug_flag -t $threads -n $extra_strain_profiling_paras $output_flag $zip_paras
            else
                /usr/bin/time -v -o $strain_query_log $pantax -f $database_genomes_info -s -p -r $read --strain-level --test $debug_flag -t $threads -n $extra_strain_profiling_paras $output_flag $zip_paras
            fi
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
if [ $filter = true ] && [ -f $strain_abundance ] && [ $version != "2" ] ; then
    python $scripts_dir/cov_filter.py $strain_abundance $e
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py filter${e}_strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > filter${e}_evaluation_report.txt
    fi
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

# low coverage (1~3x) strain eval
evaluation_report=pantax_low_evaluation_report.txt
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID
if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info -l -c $strain_true_cov > $evaluation_report
    fi
fi

# sensitivity
ori_extra_strain_profiling_paras=$extra_strain_profiling_paras
mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID
for fr in $(seq 0 0.1 1); do
    for fc in $(seq 0 0.1 1); do
# for fr in $(seq 0.3 0.1 0.5); do
#     for fc in $(seq 0.4 0.1 0.5); do
        echo "Running with -fr $fr -fc $fc"
        if [ -n "$ori_extra_strain_profiling_paras" ]; then
            extra_strain_profiling_paras="-fr $fr -fc $fc $ori_extra_strain_profiling_paras"
        else
            extra_strain_profiling_paras="-fr $fr -fc $fc"
        fi
        output_flag="-o $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}"
        strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}_strain_abundance.txt
        rm -f $wd/$tool_name/$profile_level/$dataset/$samplesID/$(basename "$db")_tmp/strain_abundance.txt
        if [ $read_type == "short" ]; then
            if [ $read == "None" ]; then
                # two paired end file
                if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                    $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read1 -r $read2 --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
                fi
            else
                # single paired end file
                if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                    $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
                fi
            fi
        elif [ $read_type == "long" ]; then
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -l -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
            fi
        fi        

        evaluation_report=pantax_fr${fr}_fc${fc}_evaluation_report.txt
        if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
            if [ $profile_level == "strain_level" ]; then
                python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
            fi
        fi 

    done
done

# sen_low
mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/low_eval && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID
for fr in $(seq 0 0.1 1); do
    for fc in $(seq 0 0.1 1); do
        echo "Running with -fr $fr -fc $fc (low)"     
        evaluation_report=pantax_fr${fr}_fc${fc}_low_evaluation_report.txt
        strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}_strain_abundance.txt
        if [ ! -f "low_eval/$evaluation_report" ] && [ -f $strain_abundance ]; then
            if [ $profile_level == "strain_level" ]; then
                python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info -l -c $strain_true_cov > "low_eval/$evaluation_report"
            fi
        fi 

    done
done

# more_sensitivity
ori_extra_strain_profiling_paras=$extra_strain_profiling_paras
if [ $read_type == "long" ]; then
    mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID
    for fr in $(seq 0.4 0.01 0.6); do
        for fc in $(seq 0.3 0.01 0.5); do
            echo "Running with -fr $fr -fc $fc"
            if [ -n "$ori_extra_strain_profiling_paras" ]; then
                extra_strain_profiling_paras="-fr $fr -fc $fc $ori_extra_strain_profiling_paras"
            else
                extra_strain_profiling_paras="-fr $fr -fc $fc"
            fi
            output_flag="-o $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}"
            strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}_strain_abundance.txt
            rm -f $wd/$tool_name/$profile_level/$dataset/$samplesID/$(basename "$db")_tmp/strain_abundance.txt
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -l -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
            fi      

            evaluation_report=pantax_fr${fr}_fc${fc}_evaluation_report.txt
            if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
                if [ $profile_level == "strain_level" ]; then
                    python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
                fi
            fi 

        done
    done
elif [ $read_type == "short" ]; then
    mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID
    for fr in $(seq 0.2 0.01 0.4); do
        for fc in $(seq 0.4 0.01 0.5); do
            echo "Running with -fr $fr -fc $fc"
            if [ -n "$ori_extra_strain_profiling_paras" ]; then
                extra_strain_profiling_paras="-fr $fr -fc $fc $ori_extra_strain_profiling_paras"
            else
                extra_strain_profiling_paras="-fr $fr -fc $fc"
            fi
            output_flag="-o $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}"
            strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/pantax_fr${fr}_fc${fc}_strain_abundance.txt
            rm -f $wd/$tool_name/$profile_level/$dataset/$samplesID/$(basename "$db")_tmp/strain_abundance.txt
            if [ $read == "None" ]; then
                # two paired end file
                if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                    $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read1 -r $read2 --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
                fi
            else
                # single paired end file
                if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                    $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
                fi
            fi     

            evaluation_report=pantax_fr${fr}_fc${fc}_evaluation_report.txt
            if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
                if [ $profile_level == "strain_level" ]; then
                    python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
                fi
            fi 

        done
    done
fi

# rescue_sensitivity
if [ $read_type == "long" ]; then
    mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity
    fr=0.5
    fc=0.46
    for rescue_cutoff in $(seq 0.05 0.1 0.95); do
        echo "Running with -fr $fr -fc $fc -sr $rescue_cutoff"
        if [ -n "$ori_extra_strain_profiling_paras" ]; then
            extra_strain_profiling_paras="-fr $fr -fc $fc -sr $rescue_cutoff $ori_extra_strain_profiling_paras"
        else
            extra_strain_profiling_paras="-fr $fr -fc $fc -sr $rescue_cutoff"
        fi
        output_flag="-o $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity/pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}"
        strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity/pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}_strain_abundance.txt
        rm -f $wd/$tool_name/$profile_level/$dataset/$samplesID/$(basename "$db")_tmp/strain_abundance.txt
        if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
            $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -l -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
        fi      

        evaluation_report=pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}_evaluation_report.txt
        if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
            if [ $profile_level == "strain_level" ]; then
                python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
            fi
        fi 
    done

elif [ $read_type == "short" ]; then
    mkdir -p $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity && cd $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity
    fr=0.3
    fc=0.46
    for rescue_cutoff in $(seq 0.05 0.1 0.95); do
        echo "Running with -fr $fr -fc $fc -sr $rescue_cutoff"
        if [ -n "$ori_extra_strain_profiling_paras" ]; then
            extra_strain_profiling_paras="-fr $fr -fc $fc -sr $rescue_cutoff $ori_extra_strain_profiling_paras"
        else
            extra_strain_profiling_paras="-fr $fr -fc $fc -sr $rescue_cutoff"
        fi
        output_flag="-o $sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity/pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}"
        strain_abundance=$sensitivity_analysis_wd/$profile_level/${dataset%%_*}/$samplesID/rescue_sensitivity/pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}_strain_abundance.txt
        rm -f $wd/$tool_name/$profile_level/$dataset/$samplesID/$(basename "$db")_tmp/strain_abundance.txt
        if [ $read == "None" ]; then
            # two paired end file
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read1 -r $read2 --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
            fi
        else
            # single paired end file
            if [ ! -f $strain_abundance ] && [ $HSTN == "node002" ]; then
                $pantax -f $database_genomes_info -db $db -T $wd/$tool_name/$profile_level/$dataset/$samplesID -s -p -r $read --strain-level -t $threads -n $extra_strain_profiling_paras $debug_flag $output_flag 
            fi
        fi     

        evaluation_report=pantax_fr${fr}_fc${fc}_rescue${rescue_cutoff}_evaluation_report.txt
        if [ ! -f $evaluation_report ] && [ -f $strain_abundance ]; then
            if [ $profile_level == "strain_level" ]; then
                python $scripts_dir/strain_evaluation.py $strain_abundance $tool_name $data_type $true_abund $database_genomes_info > $evaluation_report
            fi
        fi 
    done
fi

# graph_mapq
mkdir -p $wd/graph_mapq_eval && cd $wd/graph_mapq_eval
python $scripts_dir/graph_mapq_eval.py $dataset $samplesID $db/reference_pangenome.gfa $wd/$tool_name/$profile_level/$dataset/$samplesID/*/reads_classification.tsv $wd/graph_mapq_eval/refdiv_stat.tsv
