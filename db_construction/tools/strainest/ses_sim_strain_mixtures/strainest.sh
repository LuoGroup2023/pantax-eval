set -e
threads=64
result=$(cat /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level3/prepare/1282.txt | tr '\n' ' ')
strainest mapgenomes $result /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/complete_genome/complete_genome_without_plasmid/GCF_006094375.1_ASM609437v1_genomic.fna MA.fasta
strainest map2snp /home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/complete_genome/complete_genome_without_plasmid/GCF_006094375.1_ASM609437v1_genomic.fna MA.fasta snp.dgrp
strainest snpdist snp.dgrp snp_dist.txt hist.pdf
strainest snpclust snp.dgrp snp_dist.txt snp_clust.dgrp clusters.txt
bowtie2-build MA.fasta MA --threads $threads


