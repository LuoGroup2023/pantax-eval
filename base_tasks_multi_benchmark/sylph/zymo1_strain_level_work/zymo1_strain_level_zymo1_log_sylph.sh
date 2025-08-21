
set -e
sylph="sylph"
tool_name="sylph"
threads=64

###### zymo1_log ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1_log
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/sylph/zymo1_strain_database/database.syldb
seq2tax=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/zymo1_fna_seqID_taxid.txt
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

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### zymo1_log ontR9
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=zymo1_log
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
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/sylph/zymo1_strain_database/database.syldb
seq2tax=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/zymo1_fna_seqID_taxid.txt
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

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
