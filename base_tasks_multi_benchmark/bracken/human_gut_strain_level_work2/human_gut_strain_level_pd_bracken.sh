
set -e
kraken2="bracken"
tool_name="bracken"
threads=64

# para
wd=/home/work/gyli/real_human_gut/
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=ngs
samplesID=pd_human_gut
profile_level=strain_level
read="/home/work/gyli/PD_qc/Low_Complexity_Filtered_Sequences/modified_data_for_pantax/SRR19064874_qc3_modified.fastq.gz"
read_length=151
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f bracken_query_report ]; then
    if [ $profile_level == "strain_level" ]; then
        /usr/bin/time -v -o query_time.log bracken -d $db -i $wd/$profile_level/kraken2/kraken2_query_report -o bracken_query_report -r $read_length -l S1
    fi
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/bracken_strain_abundance_est.py bracken_query_report $genomes_length_for_strains $read_length $tax2genome
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#