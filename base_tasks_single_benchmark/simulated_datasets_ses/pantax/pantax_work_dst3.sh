
set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3
pantax_db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/pantax/species_1282_strain/pantax_db
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
genomes_info_file=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/genomes_info_1282_species.txt
mkdir -p $wd/pantax/pantax_result3
reads_paths=$(find $wd/dataset3 -name "reads")

READS_1="read1.fq"
READS_2="read2.fq"
for dir in $reads_paths; do
    # echo $dir
    cd $dir
    # # zcat anonymous_reads.fq.gz | paste - - - - - - - - | tee >(cut -f 1-4 | tr "\t" "\n" > "$READS_1") | cut -f 5-8 | tr "\t" "\n" > "$READS_2"
    # seqkit grep -n -r -p 1$ anonymous_reads.fq.gz -o read1.fq
    # seqkit grep -n -r -p 2$ anonymous_reads.fq.gz -o read2.fq

    # extracted_path=$(echo $dir | awk -F'/' '{n=NF; print $(n-4)"/"$(n-3)}' )
    # mkdir -p $wd/pantax/pantax_result3/$extracted_path && cd $wd/pantax/pantax_result3/$extracted_path
    # if [ ! -f strain_abundance.txt ]; then
    #     /usr/bin/time -v -o query_time.log /home/work/wenhai/wh-github/PanTax/scripts/pantax -s -p -r $dir/anonymous_reads.fq.gz --species-level --strain-level -db $pantax_db --debug > eval.log
    # fi
    # distribution_dir=$(echo $dir | rev | cut -d'/' -f4- | rev)
    # echo $extracted_path
    # python $scripts_dir/map_cluster.py $distribution_dir/distribution.txt /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/hclsMap_99.txt pantax
    # python $scripts_dir/strain_evaluation.py strain_abundance.txt pantax -1 distribution.txt $genomes_info_file 
    
    extracted_path=$(echo $dir | awk -F'/' '{n=NF; print $(n-4)"/"$(n-3)}' )
    mkdir -p $wd/pantax/pantax_result3/$extracted_path && cd $wd/pantax/pantax_result3/$extracted_path
    # rm -f pantax2_strain_abundance.txt pantax_strain_abundance.txt pantax2_species_abundance.txt strain_abundance.txt species_abundance.txt eval2.log
    if [ ! -f pantax_strain_abundance.txt ]; then
        /usr/bin/time -v -o query_time.log /home/work/wenhai/wh-github/PanTax/scripts/pantax -s -p -r $dir/anonymous_reads.fq.gz --species-level --strain-level -db $pantax_db --debug -o pantax -t 64 > eval.log
    fi

    distribution_dir=$(echo $dir | rev | cut -d'/' -f4- | rev)
    echo $extracted_path
    python $scripts_dir/map_cluster.py $distribution_dir/distribution.txt /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/hclsMap_99.txt pantax
    python $scripts_dir/strain_evaluation.py pantax_strain_abundance.txt pantax -1 distribution.txt $genomes_info_file 

done