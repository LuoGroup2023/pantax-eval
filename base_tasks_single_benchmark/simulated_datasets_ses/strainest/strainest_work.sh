
set -e

dir=$1
db=$2
pair=${3:-true}
read_type=${4:-None}
echo $dir
echo $pair
echo $read_type
if [ $pair == "true" ]; then
    sickle pe -f $dir/read1.fq -r $dir/read2.fq -t sanger -o reads1.trim.fastq -p reads2.trim.fastq -s reads.singles.fastq -q 20
    bowtie2 --very-fast --no-unal -x $db/MA -1 reads1.trim.fastq -2 reads2.trim.fastq -S reads.sam
else
    # bwa index $db/MA.fasta
    bwa mem -x $read_type $db/MA.fasta $dir/anonymous_reads.fq.gz > reads.sam
fi

samtools view -b reads.sam > reads.bam
samtools sort reads.bam -o reads.sorted.bam
samtools index reads.sorted.bam
strainest est $db/snp_clust.dgrp reads.sorted.bam outputdir
