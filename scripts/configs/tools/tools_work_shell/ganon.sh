
set -e
ganon="ganon"
tool_name="ganon"
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
$designated_genomes_info

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db --paired-reads $read1 $read2 --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

# long
if [ ! -f results.rep ]; then
    /usr/bin/time -v -o query_time.log $ganon classify --db-prefix $db -s $read --output-prefix results --report-type abundance -t $threads || true
fi
if [ -f results.all ] && [ ! -s results.all ]; then
    echo "all reads unclassified"
elif [ ! -f "evaluation_report.txt" ]; then
    $ganon report -i results.rep --db-prefix $db --output-prefix tax_profile --report-type abundance -r all
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        if [ $read_length == "None" ]; then
            python $scripts_dir/get_read_len.py -fq $read -s long
            read_length=long_read_length.txt
        fi
        python $scripts_dir/ganon_strain_process.py tax_profile.tre $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
