
set -e
dir=$1
db=$2
pair=${3:-true}
if [ $pair == "true" ]; then
    straingst kmerize -k 23 -o result.hdf5 $dir/read1.fq $dir/read2.fq
else
    straingst kmerize -k 23 -o result.hdf5 $dir/anonymous_reads.fq.gz
fi

straingst run -O -o result $db/pan-genome-db.hdf5 result.hdf5
