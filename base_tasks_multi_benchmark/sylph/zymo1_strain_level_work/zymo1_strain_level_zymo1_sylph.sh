
set -e
sylph="sylph"
tool_name="sylph"
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
