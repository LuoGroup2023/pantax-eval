
set -e
sylph="sylph"
tool_name="sylph"
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
$seq2tax

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f "result.tsv" ]; then
    /usr/bin/time -v -o query_time.log $sylph profile $db -1 $read1 -2 $read2 -o result.tsv
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/sylph_convert.py result.tsv $seq2tax species
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa sylph_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa sylph_abundance.txt -ta $true_abund -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/sylph_convert.py result.tsv $seq2tax strain
        python $scripts_dir/strain_evaluation.py sylph_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

# long
if [ ! -f "result.tsv" ]; then
    /usr/bin/time -v -o query_time.log $sylph profile $db $read -o result.tsv
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "species_level" ]; then
        python $scripts_dir/sylph_convert.py result.tsv $seq2tax species
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa sylph_abundance.txt -ta $true_abund -rl $read_length -gl $genome_length -m $camisim_reads_mapping_path
        python $scripts_dir/species_metrics_eval.py -i - -t $tool_name -rt $read_type -s $samplesID -dt $data_type -pa sylph_abundance.txt -ta $true_abund -rl $read_length -gl $genome_length -m $camisim_reads_mapping_path -e 0
    elif [ $profile_level == "strain_level" ] || [ $profile_level == "zymo1_strain_level" ]; then
        python $scripts_dir/sylph_convert.py result.tsv $seq2tax strain
        python $scripts_dir/strain_evaluation.py sylph_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi    
fi

