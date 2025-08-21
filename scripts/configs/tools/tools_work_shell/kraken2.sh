
set -e
kraken2="kraken2"
tool_name="kraken2"
threads=64

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
$db
$tax2genome
$designated_species

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads --paired $read1 $read2
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa ${tool_name}_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
