set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
strainge_db=$wd/database_build/straingst
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
genomes_info_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/genomes_info_1282_species.txt
mkdir -p $wd/straingst/straingst_result3
reads_paths=$(find $wd/dataset3 -name "reads")

for dir in $reads_paths; do
    extracted_path=$(echo $dir | awk -F'/' '{n=NF; print $(n-4)"/"$(n-3)}' )
    mkdir -p $wd/straingst/straingst_result3/$extracted_path && cd $wd/straingst/straingst_result3/$extracted_path
    # echo $(pwd)
    if [ ! -f result.strains.tsv ]; then 
        /usr/bin/time -v -o query_time.log bash $wd/straingst/straingst_work.sh $dir $strainge_db >/dev/null 2>&1
    fi
    distribution_dir=$(echo $dir | rev | cut -d'/' -f4- | rev)
    echo $extracted_path 
    python $scripts_dir/map_cluster.py $distribution_dir/distribution.txt $strainge_db/clusters.tsv straingst
    python $scripts_dir/strain_evaluation.py $wd/straingst/straingst_result3/$extracted_path/result.strains.tsv straingst -1 distribution.txt $genomes_info_file
done