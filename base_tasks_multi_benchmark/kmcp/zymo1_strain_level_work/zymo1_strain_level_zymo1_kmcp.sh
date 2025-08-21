
set -e
kmcp="kmcp"
tool_name="kmcp"
threads=64

###### zymo1 ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1
data_type=8
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/dataset/zymo/illumina/zymo_illumina_rename.fq
read1=/home/work/wenhai/dataset/zymo/illumina/ERR2984773_1.fastq
read2=/home/work/wenhai/dataset/zymo/illumina/ERR2984773_2.fastq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/dataset/zymo/strain_abundance.txt
read_length=151
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/zymo1_strain/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/zymo1_strain_taxid.tsv
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/zymo1_strain/kraken2_db/taxonomy
extra_strain_profiling_paras=''
version=1
graph_parsing_format=None
is_debug=false
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

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### zymo1 ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1
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
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/zymo1_strain/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/zymo1_strain_taxid.tsv
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/zymo1_strain/kraken2_db/taxonomy
extra_strain_profiling_paras=''
version=1
graph_parsing_format=None
is_debug=false
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### zymo1 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1
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
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/zymo1_strain/kmcpDB/kmcp_refs_k21.kmcp
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/zymo1_strain_taxid.tsv
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/zymo1_strain/kraken2_db/taxonomy
extra_strain_profiling_paras=''
version=1
graph_parsing_format=None
is_debug=false
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
