set -e
scripts_dir=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity
# all complete genomes which has removed plasmid
all_complete_genome_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/pggb_vg/big_sample/camisim_simulate/provided_genomes_info/genomes_info_provided_origin.txt

mkdir -p $wd/preprocess/res && cd $wd/preprocess/res

# bash $scripts_dir/reference_diversity_select.sh
python $wd/preprocess/scripts/strain_num.py $all_complete_genome_info reference_diversity_species.tsv

# sc_taxid=$(paste -sd, reference_diversity_species.tsv)

# bash /home/work/wenhai/wh-github/PanTax/scripts/data_preprocessing \
#   --custom "$all_complete_genome_info" \
#   --compute --cluster -sc "$sc_taxid" -m -1 -n -1 -p 1 -j 128

python $wd/preprocess/scripts/strain_select.py $wd/preprocess/res/db/genomes_info.txt
