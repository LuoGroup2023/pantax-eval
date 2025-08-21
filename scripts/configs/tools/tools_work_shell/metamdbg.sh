
set -e
metamdbg="metaMDBG"
tool_name="metamdbg"
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
if [ ! -f "metaMDBG_res/contigs.fasta.gz" ]; then
    if [ $samplesID == "hifi" ]; then
        /usr/bin/time -v -o asm_time.log $metamdbg asm --out-dir metaMDBG_res --in-hifi $read --threads $threads
    elif [ "$samplesID" = "ontR10" ]; then
        /usr/bin/time -v -o asm_time.log $metamdbg asm --out-dir metaMDBG_res --in-ont $read --threads $threads
    fi
    python $scripts_dir/time_process.py asm_time.log > time_evaluation.txt
fi
if [ ! -f "asm2db.paf" ]; then
    $minimap2 -x asm5 --split-prefix=tmp -t $threads $db metaMDBG_res/contigs.fasta.gz -o asm2db.paf
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/asm_profiling.py metaMDBG_res/contigs.fasta.gz asm2db.paf $reference_len_stat $tool_name
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
