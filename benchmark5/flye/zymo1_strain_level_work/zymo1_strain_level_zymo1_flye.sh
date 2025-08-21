
set -e
flye="flye"
tool_name="flye"
threads=64
minimap2="minimap2"

###### zymo1 ontR10
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof
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
database_genomes_info=/home/work/wenhai/PanTax/genomes_info/multi_species_for_zymo1_genomes_info_sample.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/zymo1/reference.fna.gz
reference_len_stat=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/asm2prof/asm2prof_db/res/zymo1/reference_len_stat.txt
database_genomes_info=/home/work/wenhai/PanTax/genomes_info/multi_species_for_zymo1_genomes_info_sample.txt
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
if [ ! -f "flye_res/assembly.fasta" ]; then
    if [ $samplesID == "hifi" ]; then
        /usr/bin/time -v -o asm_time.log $flye --pacbio-hifi $read --out-dir flye_res --threads $threads --meta
    elif [ "$samplesID" = "ontR10" ]; then
        /usr/bin/time -v -o asm_time.log $flye --nano-hq $read --out-dir flye_res --threads $threads --meta
    fi
    python $scripts_dir/time_process.py asm_time.log > time_evaluation.txt
fi
if [ ! -f "asm2db.paf" ]; then
    $minimap2 -x asm5 --split-prefix=tmp -t $threads $db flye_res/assembly.fasta -o asm2db.paf
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/asm_profiling.py flye_res/assembly_info.txt asm2db.paf $reference_len_stat $tool_name
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
