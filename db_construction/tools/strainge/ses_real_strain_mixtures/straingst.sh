
threads=64
strainge_db=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all/database_build/straingst/1282
for f in $strainge_db/*.fna; do
    straingst kmerize -o ${f%_genomic.fna}.hdf5 $f;
done;
straingst kmersim --all-vs-all -t $threads -S jaccard -S subset $strainge_db/*.hdf5 > similarities.tsv
straingst cluster -i similarities.tsv -d -C 0.99 -c 0.90 --clusters-out clusters.tsv $strainge_db/*.hdf5 > references_to_keep.txt
straingst createdb -f references_to_keep.txt -o pan-genome-db.hdf5

