set -e 
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/ganon
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
genome2strain_taxid=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/data/kraken2_strain_taxid.tsv
ganonDB=$wd/ganon_db
threads=64
strain_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/strain/kraken2_db/taxonomy

mkdir -p $wd && cd $wd
if [ ! -f input_genomes.txt ]; then
    python $scripts_dir/prepare_input_genomes.py $genomes_info $genome2strain_taxid
fi

if [ ! -f ${ganonDB}.hibf ]; then
    /usr/bin/time -v -o build_time.log ganon build-custom --input-file input_genomes.txt --taxonomy-files $strain_taxonomy/nodes.dmp $strain_taxonomy/names.dmp --db-prefix $ganonDB --level strain -t $threads
fi

