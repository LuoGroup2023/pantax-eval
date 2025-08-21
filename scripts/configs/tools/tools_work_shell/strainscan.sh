
set -e
strainscan="strainscan"
tool_name="strainscan"
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

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -d strainscan_result ]; then
    if [ $profile_level == "strain_level" ]; then
        /usr/bin/time -v -o query_time.log $strainscan -i $read1 -j $read2 -d $db -o strainscan_result
    fi
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    python /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/strain_evaluation.py strainscan_result/final_report.txt $true_abund strainscan > evaluation_report.txt
fi

# long