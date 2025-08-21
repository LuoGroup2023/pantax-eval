perl_scripts_dir="/home/wenhai/application/MetaMaps"
genomes_info=/home/work/wenhai/PanTax/genomes_info/multi_species_for_zymo1_genomes_info_sample.txt

# awk '{print $2"\t"$NF}' $genomes_info | tail -n +2 | awk '{printf "%.0f\t%s\n", $1, $2}' > new_info.txt
# python prepare_input_list.py

mkdir -p download databases
perl $perl_scripts_dir/combineAndAnnotateReferences.pl --inputFileList input_list.txt --outputFile download/reference.fa --taxonomyInDirectory /home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/download/taxonomy_202308/ --taxonomyOutDirectory download/new_taxonomy
perl $perl_scripts_dir/buildDB.pl --DB databases/strain_level_metamaps_db --FASTAs download/reference.fa --taxonomy /home/work/enlian/pantax/13404_other_softwares_result/strain_level/metamaps/download/new_taxonomy
