
set -e
metamdbg="metaMDBG"
tool_name="metamdbg"
threads=64
minimap2="minimap2"

###### simhigh-sub0.01 hifi
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=hifi
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/hifi/mut_rate0.01/simhigh-hifi-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/Ref13404/reference.fna.gz
reference_len_stat=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/Ref13404/reference_len_stat.txt
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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###### simhigh-sub0.01 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simhigh-sub0.01
data_type=1000
read_type=long
samplesID=ontR10
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax_mutation/simhigh/ontR10/mut_rate0.01/simhigh-ontR10-mut_rate0.01.fq.gz
read1=-
read2=-
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/prepare/1000strains/distribution.txt
read_length=None
genome_length=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/long_alternative_methods/evaluation_scripts/genome_length.txt
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/Ref13404/reference.fna.gz
reference_len_stat=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/Ref13404/reference_len_stat.txt
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
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
