set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/13404_strain_genomes_info.txt
threads=64
kmcpDB=$wd/kmcpDB
species_taxonomy=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kraken2/species/kraken2_db/taxonomy

mkdir -p $wd && cd $wd

awk -F'\t' 'NR>1 {print $5}' OFS='\t' $genomes_info > input_genomes.txt
kmcp compute -i input_genomes.txt \
    --kmer 21 \
    --split-number 10 \
    --split-overlap 150 \
    --ref-name-regexp "^(.+)_genomic\.fna(?:\.gz)?$" \
    --out-dir $kmcpDB/kmcp_refs_k21  \
    -j $threads

kmcp index \
    --in-dir $kmcpDB/kmcp_refs_k21/\
    --num-hash 1 \
    --false-positive-rate 0.3 \
    --out-dir $kmcpDB/kmcp_refs_k21.kmcp \
    -j $threads

# rm -rf $kmcpDB/kmcp_refs_k21