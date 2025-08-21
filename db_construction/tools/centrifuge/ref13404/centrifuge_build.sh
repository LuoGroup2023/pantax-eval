
set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/centrifuge/strain
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
genome2strain_taxid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
centrifugeDB=$wd/centrifuge_db/centrifugeDB
threads=64
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy

mkdir -p $wd/centrifuge_db
cd $wd
if [ ! -f input_genomes.txt ]; then
    python $scripts_dir/prepare_genomes_strain_taxid.py $genomes_info $genome2strain_taxid
fi

if [ ! -f $wd/centrifuge_db/centrifugeDB.4.cfr ]; then
    /usr/bin/time -v -o build_time.log centrifuge-build -p $threads --conversion-table seqid2taxid.map --taxonomy-tree $strain_taxonomy/nodes.dmp --name-table $strain_taxonomy/names.dmp reference_genomes.fna $centrifugeDB
    mv seqid2taxid.map input_genomes.txt $wd/centrifuge_db
fi
rm reference_genomes.fna
