
set -e
pantax="metamaps"
tool_name="metamaps"
threads=64

# para
wd=/home/work/gyli/real_human_gut/
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
dataset=ont
samplesID=healthy_human_gut
profile_level=strain_level
read="/home/work/gyli/real_dataset/ont/ont_head/minimap2_nohuman/rmhost/rmhost_fq/SRR18490940_alignment_rmhost.fastq.gz"
read_length="/home/work/gyli/real_dataset/ont/ont_head/minimap2_nohuman/rmhost/rmhost_fq/strain_level_work/SRR18490940_read_length.txt"
genomes_length_for_strains=/home/work/wenhai/PanTax/data_preprocessing/genome_statics.txt
db=/home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/databases/strain_level_metamaps_db
genome2seqid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/fna_seqID_taxid.txt
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f classification_results.EM ] && [ ! -f strain_classification.csv ]; then
    /usr/bin/time -v -o query_time1.log metamaps mapDirectly -r $db/DB.fa -q $read -t $threads -o classification_results
    /usr/bin/time -v -o query_time2.log metamaps classify --mappings classification_results --DB $db -t $threads
    python $scripts_dir/time_process.py query_time1.log > time_evaluation1.txt
    python $scripts_dir/time_process.py query_time2.log > time_evaluation2.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    # not yet test, maybe can't work at species level
    if [ $profile_level == "strain_level" ]; then
        if [ ! -f strain_classification.csv ]; then
            python $scripts_dir/metamaps_strain_process.py classification_results.EM $genome2seqid
        fi
        python $scripts_dir/strain_abundance_estimate.py -rc strain_classification.csv -rl $read_length -gl $genomes_length_for_strains -s $samplesID -o .
    fi
fi

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#