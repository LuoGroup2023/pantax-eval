
set -e
read1=$1
read2=$2
db=$3
straingst kmerize -k 23 -o result.hdf5 $1 $2 
straingst run -O -o result $db/pan-genome-db.hdf5 result.hdf5
