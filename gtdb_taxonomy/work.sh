
wd=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy
taxonomy_file=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/bac120_taxonomy.tsv
all_genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
scripts_dir=$wd/scripts

mkdir -p $wd && cd $wd

taxa_edit_script=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/scripts/taxdump_edit.py
python $scripts_dir/gtdb_taxonomy_build.py $taxonomy_file
python $scripts_dir/prepare_gtdb_modification_file.py $taxonomy_file $all_genomes_info $wd
python $taxa_edit_script --nodes $wd/nodes.dmp --names $wd/names.dmp --output strain_taxid.tsv taxa_info.tsv

