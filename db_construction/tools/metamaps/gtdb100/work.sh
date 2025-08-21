wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/metamaps/gtdb100
scripts_dir=$wd/scripts
perl_scripts_dir="/home/wenhai/application/MetaMaps"
genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
taxa_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy/taxa_info.tsv
taxanomy_dir=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy
output_dir=$wd/genomes

mkdir -p $wd/databases $wd/download
# mkdir -p $output_dir
# awk -F'\t' 'NR>1 {print $5}' OFS='\t' $genomes_info > input_genomes.txt
# decompress() {
#     file_path=$1
#     if [[ $file_path == *.gz ]]; then
#         gunzip -c $file_path > $output_dir/$(basename $file_path .gz)
#     else
#         cp $file_path $output_dir
#     fi
# }
# export output_dir
# export -f decompress
# cat input_genomes.txt | xargs -n 1 -P 64 bash -c 'decompress "$0"'
# python $scripts_dir/prepare_genomes_list.py $genomes_info $taxa_info $output_dir
mkdir -p $wd/taxonomy
# cp $taxanomy_dir/nodes_backup.dmp $wd/taxonomy/nodes.dmp
# cp $taxanomy_dir/names_backup.dmp $wd/taxonomy/names.dmp
# touch $wd/taxonomy/merged.dmp $wd/taxonomy/delnodes.dmp
perl $perl_scripts_dir/combineAndAnnotateReferences.pl --inputFileList $scripts_dir/genomes.txt --outputFile $wd/download/reference.fa --taxonomyInDirectory $wd/taxonomy/ --taxonomyOutDirectory $wd/download/new_taxonomy
perl $perl_scripts_dir/buildDB.pl --DB $wd/databases/strain_level_metamaps_db --FASTAs $wd/download/reference.fa --taxonomy $wd/download/new_taxonomy

