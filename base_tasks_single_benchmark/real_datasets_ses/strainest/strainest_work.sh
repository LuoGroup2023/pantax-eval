
set -e

read1=$1
read2=$2
db=$3

sickle pe -f $read1 -r $read2 -t sanger -o reads1.trim.fastq -p reads2.trim.fastq -s reads.singles.fastq -q 20
bowtie2 --very-fast --no-unal -x $db/MA -1 reads1.trim.fastq -2 reads2.trim.fastq -S reads.sam
samtools view -b reads.sam > reads.bam
samtools sort reads.bam -o reads.sorted.bam
samtools index reads.sorted.bam
strainest est $db/snp_clust.dgrp reads.sorted.bam outputdir
