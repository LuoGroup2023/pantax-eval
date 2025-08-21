
set -e 
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
strainscan_db=$wd/database_build/strainscan/1282_strainscan_db/
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
genomes_info_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/genomes_info_1282_species.txt

mkdir -p $wd/strainscan/strainscan_result3
reads_paths=$(find $wd/dataset3 -name "reads")
for dir in $reads_paths; do
    extracted_path=$(echo $dir | awk -F'/' '{n=NF; print $(n-4)"/"$(n-3)}' )
    mkdir -p $wd/strainscan/strainscan_result3/$extracted_path && cd $wd/strainscan/strainscan_result3/$extracted_path
    if [ ! -d strainscan_result ];then
        /usr/bin/time -v -o strainscan_query_time.log strainscan -i $dir/read1.fq -j $dir/read2.fq -d $strainscan_db -o strainscan_result >/dev/null 2>&1
    fi
    cd strainscan_result
    distribution_dir=$(echo $dir | rev | cut -d'/' -f4- | rev)
    echo $extracted_path
    python $scripts_dir/strain_evaluation.py final_report.txt strainscan -1 $distribution_dir/distribution.txt $genomes_info_file
done