
set -e
centrifuger="centrifuger"
tool_name="centrifuger"
threads=64

###### simlow-low ngs
# para
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods_0208_auto
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=simlow-low
data_type=30
read_type=short
samplesID=ngs
profile_level=strain_level
read=/home/work/wenhai/simulate_genome_data/PanTax/short_read/30species_low/sim-30species-low-ngs/2024.02.28_14.57.25_sample_0/reads/anonymous_reads.fq.gz
read1=/home/work/wenhai/simulate_genome_data/PanTax/short_read/30species_low/sim-30species-low-ngs/2024.02.28_14.57.25_sample_0/reads/read1.fq
read2=/home/work/wenhai/simulate_genome_data/PanTax/short_read/30species_low/sim-30species-low-ngs/2024.02.28_14.57.25_sample_0/reads/read2.fq
camisim_reads_mapping_path=None
true_abund=/home/work/wenhai/simulate_genome_data/PanTax/short_read/30species_low/sim-30species-low-ngs/distributions/distribution_0.txt
read_length=150
genome_length=-
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
database_genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
db='-'
designated_genomes_info='-'
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuger/strain/centrifuger_db/centrifugerDB
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# short
if [ ! -f centrifuger_report.tsv ]; then
    /usr/bin/time -v -o query_time.log $centrifuger -k 1 -x $db -1 $read1 -2 $read2 -t $threads > cls.tsv
    centrifuger-quant -x $db -c cls.tsv > centrifuger_report.tsv
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/centrifuger_strain_process.py centrifuger_report.tsv $designated_genomes_info
        python $scripts_dir/strain_evaluation.py strain_abundance.txt $tool_name $data_type $true_abund $database_genomes_info > evaluation_report.txt
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
