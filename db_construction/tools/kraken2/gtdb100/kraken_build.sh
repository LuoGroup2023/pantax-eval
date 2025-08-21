
set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/gtdb100
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
Kraken2_DB=$wd/kraken2_db
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/gtdb_taxonomy
threads=64

# mkdir -p $Kraken2_DB/taxonomy && cd $Kraken2_DB/taxonomy
# cp $strain_taxonomy/nodes.dmp $strain_taxonomy/names.dmp $strain_taxonomy/strain_taxid.tsv ./

# if [ ! -d $wd/prepare_genomes ]; then
#     python $scripts_dir/prepare_genomes.py $genomes_info $wd $strain_taxonomy/strain_taxid.tsv
# fi

ref_genomes=$(find $wd/prepare_genomes -name "*fna*")
for ref_genome in $ref_genomes
do
    kraken2-build --add-to-library $ref_genome --db $Kraken2_DB
done
if [ ! -f $Kraken2_DB/hash.k2d ] && [ ! -f $Kraken2_DB/opts.k2d ] && [ ! -f $Kraken2_DB/taxo.k2d ]; then
    kraken2-build --build --db $Kraken2_DB --threads $threads
fi

