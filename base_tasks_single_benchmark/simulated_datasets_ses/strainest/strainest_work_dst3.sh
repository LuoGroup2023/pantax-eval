set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
strainest_db=$wd/database_build/strainest
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
genomes_info_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/genomes_info_1282_species.txt
mkdir -p $wd/strainest/strainest_result3
reads_paths=$(find $wd/dataset3 -name "reads")

for dir in $reads_paths; do
    extracted_path=$(echo $dir | awk -F'/' '{n=NF; print $(n-4)"/"$(n-3)}' )
    mkdir -p $wd/strainest/strainest_result3/$extracted_path && cd $wd/strainest/strainest_result3/$extracted_path
    if [ ! -d outputdir ]; then
        /usr/bin/time -v -o query_time.log bash $wd/strainest/strainest_work.sh $dir $strainest_db >/dev/null 2>&1
    fi
    cd outputdir
    distribution_dir=$(echo $dir | rev | cut -d'/' -f4- | rev)
    echo $extracted_path
    python $scripts_dir/map_cluster.py $distribution_dir/distribution.txt $strainest_db/clusters.txt strainest
    python $scripts_dir/strain_evaluation.py abund.txt strainest -1 distribution.txt $genomes_info_file
done
