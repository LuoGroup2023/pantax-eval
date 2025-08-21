
set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/zymo1_strain
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/multi_species_single_strain_zymo/genomes_info_sample.txt
Kraken2_DB=$wd/kraken2_db
species_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/species/kraken2_db/taxonomy
threads=64

# # download taxonomy
# # nohup kraken2-build --download-taxonomy --db $Kraken2_DB --threads 32 > download_taxonomy.log 2>&1 &

# mkdir -p $Kraken2_DB/taxonomy && cd $Kraken2_DB/taxonomy
# if [ ! -f species_taxid2name.tsv ]; then
#     awk -F'\t' 'NR > 1 {print $3}' $genomes_info | sort | uniq > species_taxid.txt
#     taxonkit lineage -c species_taxid.txt > species_taxid2name.tsv
# fi
# if [ ! -f ncbi.fdb ]; then
#     cp $species_taxonomy/nodes.dmp $species_taxonomy/names.dmp ./
#     python $scripts_dir/prepare_modification_file.py $genomes_info species_taxid2name.tsv 1 ./ multi
#     python $scripts_dir/taxdump_edit.py --nodes nodes.dmp --names names.dmp --output strain_taxid.tsv taxa_info.tsv
#     yes "" | flextaxd --db ncbi.fdb --taxonomy_file nodes.dmp --taxonomy_type NCBI
#     flextaxd --db ncbi.fdb --debug --validate
# fi

# if [ ! -d $wd/prepare_genomes ]; then
#     python $scripts_dir/prepare_genomes.py $genomes_info $wd strain_taxid.tsv
# fi
# rm -f names_backup.dmp nodes_backup.dmp

ref_genomes=$(find $wd/prepare_genomes -name "*fna*")
for ref_genome in $ref_genomes
do
    kraken2-build --add-to-library $ref_genome --db $Kraken2_DB
done
if [ ! -f $Kraken2_DB/hash.k2d ] && [ ! -f $Kraken2_DB/opts.k2d ] && [ ! -f $Kraken2_DB/taxo.k2d ]; then
    kraken2-build --build --db $Kraken2_DB --threads $threads
fi

rm -rf $wd/prepare_genomes

