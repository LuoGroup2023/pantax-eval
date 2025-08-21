
set -e
instrain="inStrain"
tool_name="instrain"
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
$strain_taxonomy
$designated_genomes_info

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f bt_result.sam ]; then
    /usr/bin/time -v -o query_time1.log bowtie2 -p $threads -x $db -1 $read1 -2 $read2 > bt_result.sam
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
fi
if [ ! -d result ]; then
    /usr/bin/time -v -o query_time2.log $instrain profile bt_result.sam $reference_fna -o result -p $threads -s $strain_stb --database_mode
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi

if [ ! -f "evaluation_report.txt" ] && [ -f result/output/result_genome_info.tsv ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/instrain_strain_process.py result/output/result_genome_info.tsv $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

# long

