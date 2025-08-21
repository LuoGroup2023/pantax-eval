
set -e
centrifuger="centrifuger"
tool_name="centrifuger"
threads=64

# para
wd=/home/work/gyli/real_human_gut/
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
profile_level=strain_level
dataset=ont
samplesID=healthy_human_gut
read="/home/work/gyli/real_dataset/ont/ont_head/minimap2_nohuman/rmhost/rmhost_fq/SRR18490940_alignment_rmhost.fastq.gz"
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuger/strain/centrifuger_db/centrifugerDB
# dir
echo "###########################################################################################"
echo "Running $tool_name..."
mkdir -p $wd/$tool_name/$profile_level && cd $wd/$tool_name/$profile_level
mkdir -p $wd/$tool_name/$profile_level/$dataset/$samplesID && cd $wd/$tool_name/$profile_level/$dataset/$samplesID

# long
if [ ! -f centrifuger_report.tsv ]; then
    /usr/bin/time -v -o query_time.log $centrifuger -k 1 -x $db -u $read -t $threads > cls.tsv
    centrifuger-quant -x $db -c cls.tsv > centrifuger_report.tsv
    python $scripts_dir/time_process.py query_time.log > time_evaluation.txt
fi
if [ ! -f "evaluation_report.txt" ]; then
    if [ $profile_level == "strain_level" ]; then
        python $scripts_dir/centrifuger_strain_process.py centrifuger_report.tsv
    fi
fi
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#