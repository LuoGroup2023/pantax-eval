set -e
wd=/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/alternative_methods/kmcp/gtdb100
scripts_dir=$wd/scripts
genomes_info=/home/work/wenhai/metaprofiling/bacteria_GTDB/data/genomes_info.txt
threads=64
kmcpDB=$wd/kmcpDB

mkdir -p $wd && cd $wd

awk -F'\t' 'NR>1 {print $5}' OFS='\t' $genomes_info > input_genomes.txt
kmcp compute -i input_genomes.txt \
    --kmer 21 \
    --split-number 10 \
    --split-overlap 150 \
    --ref-name-regexp "^([^_]*_[^_]*)" \
    --out-dir $kmcpDB/kmcp_refs_k21  \
    -j $threads

kmcp index \
    --in-dir $kmcpDB/kmcp_refs_k21/\
    --num-hash 1 \
    --false-positive-rate 0.3 \
    --out-dir $kmcpDB/kmcp_refs_k21.kmcp \
    -j $threads

# rm -rf $kmcpDB/kmcp_refs_k21