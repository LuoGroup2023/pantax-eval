
set -e

wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity
all_genomes_info=$wd/preprocess/res/db/genomes_info.txt
genome2id=$wd/simulation/prepare/genome_to_id.tsv

mkdir -p $wd/reference/metadata && cd $wd/reference/metadata
python $wd/reference/scripts/reference_diversity_select.py $all_genomes_info $genome2id

pantax="bash /home/work/wenhai/wh-github/PanTax/scripts/pantax"
# $pantax -f /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/reference/metadata/ref1_genomes.tsv -db ref1_pantax_db --create --index -t 64 -g --lz 
