
set -e
ganon="ganon"
tool_name="ganon"
threads=64

###### zymo1-log ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1-log
data_type=8
read_type=short
samplesID=ngs
profile_level=strain_level
read=None
read1=/home/work/wenhai/dataset/zymo_d6310_log/illumina/in745_1_R1.fastq.gz
read2=/home/work/wenhai/dataset/zymo_d6310_log/illumina/in745_1_R2.fastq.gz
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/dataset/zymo_d6310_log/strain_abundance.txt
read_length=101
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/zymo1_strain/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
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

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### zymo1-log ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1-log
data_type=8
read_type=long
samplesID=ontR9
profile_level=strain_level
read=/home/work/wenhai/dataset/zymo_d6310_log/ontR9/Zymo-GridION-LOG-BB-SN.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/dataset/zymo_d6310_log/strain_abundance.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon/zymo1_strain/ganon_db
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
