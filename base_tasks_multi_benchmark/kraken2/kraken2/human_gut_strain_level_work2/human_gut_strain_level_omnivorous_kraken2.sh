
set -e
kraken2="kraken2"
tool_name="kraken2"
threads=64

# para
wd=/home/work/gyli/real_human_gut/
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=hifi
samplesID=omnivorous_human_gut
profile_level=strain_level
read="/home/work/gyli/real_dataset/hifi/minimap2_nohuman/SRR17687125_fp_rmhost_0.2sample.fastq.gz"
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db
tax2genome=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f kraken2_query_report ]; then
    /usr/bin/time -v -o query_time.log kraken2 --db $db --output kraken2_query_reads --report kraken2_query_report --threads $threads $read
fi
if [ ! -f "evaluation_report.txt" ]; then
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
    # not yet test, maybe can't work at species level
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/kraken_format_strain_abundance_est.py kraken2_query_report kraken2_query_reads S1 $genomes_length_for_strains $tax2genome
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
