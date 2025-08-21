
set -e
kmcp="kmcp"
tool_name="kmcp"
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
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db -1 $read1 -2 $read2 --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

# long
if [ ! -f result.kmcp.gz ]; then
    /usr/bin/time -v -o query_time.log $kmcp search --db-dir $db $read --out-file result.kmcp.gz --log result.kmcp.gz.log -j $threads
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f result.kmcp.profile ] && [ ! -f result.kmcp.profile.log ]; then
    awk -F'\t' 'NR>1 {print $3,$1}' OFS='\t' $tax2genome > taxid.map
    $kmcp profile --taxid-map taxid.map --taxdump $strain_taxonomy result.kmcp.gz --out-file result.kmcp.profile --metaphlan-report result.metaphlan.profile --sample-id 0 --cami-report result.cami.profile --binning-result result.binning.gz --log result.kmcp.profile.log --level strain
fi
if [ ! -f "evaluation_report.txt" ] && [ -f result.kmcp.profile ] && [ $(wc -l < result.kmcp.profile) -gt 1 ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kmcp_strain_process.py result.kmcp.profile $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
