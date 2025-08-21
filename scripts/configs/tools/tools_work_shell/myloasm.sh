
set -e
myloasm="/home/work/wenhai/tools/myloasm/bin/myloasm-0.1.0-x86_64-avx2"
tool_name="myloasm"
threads=64
minimap2="minimap2"

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
$reference_len_stat

# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f "myloasm_res/assembly_primary.fa" ]; then
    if [ $samplesID == "hifi" ]; then
        /usr/bin/time -v -o asm_time.log $myloasm $read -o myloasm_res -t $threads --hifi
    elif [ "$samplesID" = "ontR10" ]; then
        /usr/bin/time -v -o asm_time.log $myloasm $read -o myloasm_res -t $threads 
    fi
    python $scripts_dir/time_process.py asm_time.log > time_evaluation.txt
fi
if [ ! -f "asm2db.paf" ]; then
    $minimap2 -x asm5 --split-prefix=tmp -t $threads $db myloasm_res/assembly_primary.fa -o asm2db.paf
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/asm_profiling.py myloasm_res/assembly_primary.fa asm2db.paf $reference_len_stat $tool_name
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
