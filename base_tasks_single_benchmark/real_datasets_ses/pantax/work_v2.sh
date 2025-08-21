
set -e 

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/pantax2
pantax=/home/work/wenhai/wh-github/PanTax/scripts/pantax
db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/pantax5/pantax_db
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/pantax5/pantax_db/genomes_info.txt
genomes_info_all=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/pantax5/db/library/genomes_info_provided_origin.txt

# sample=ery_time1_rep3
for sample in ery_time1_rep3 ery_time2_rep3 ery_time3_rep3 noATB_time1_rep3 noATB_time2_rep3 noATB_time3_rep3; do
# for sample in ery_time3_rep3; do
    mkdir -p $wd/$sample && cd $wd/$sample
    read1=/home/work/wenhai/dataset/two_S_ep/$sample/read1.fq
    read2=/home/work/wenhai/dataset/two_S_ep/$sample/read2.fq
    # rm -f pantax_db_tmp/strain_abundance.txt
    $pantax -f $genomes_info -s -p -r $read1 -r $read2 -db $db --species --strain -v --debug -t 128 -fr 0.2 -fc 0.46 -sr 0.85 -sh false -o pantax

    # rm -rf $wd/$sample/second_pantax

    mkdir -p $wd/$sample/second_pantax && cd $wd/$sample/second_pantax
    # rm -f $wd/$sample/second_pantax/pantax_db_tmp/strain_abundance.txt
    if [ ! -d "db" ]; then
        python /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/pantax/get_filter_genomes_info.py /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/pantax5/db/hcls/hclsMap_99.0.txt ../pantax_strain_abundance.txt $genomes_info_all
        /home/work/wenhai/wh-github/PanTax/scripts/data_preprocessing -c filtered_genomes_info.txt --compute --cluster -m -1 -n -1 -p 1 -j 128 
    fi
    $pantax -f db/genomes_info.txt -s -p -r $read1 -r $read2 --species-level --strain-level -v --debug -t 128 -o pantax2 -fr 0.3
done